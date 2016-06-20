
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_GeneralHeading_u_Copy]
	@PB_ID int,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@SuperUserGlobal bit,
	@IdList varchar(max),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 28-Apr-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@GeneralHeadingObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @GeneralHeadingObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('General Heading')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Publication given ?
END ELSE IF @PB_ID IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, @GeneralHeadingObjectName)
-- Publication exists ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_Publication WHERE PB_ID=@PB_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PB_ID AS varchar), @PublicationObjectName)
-- Publication belongs to Member ?
END ELSE IF NOT EXISTS(SELECT *
		FROM CIC_Publication pb WHERE (pb.MemberID IS NULL AND (@SuperUserGlobal=1 OR pb.CanEditHeadingsShared=1)) OR pb.MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END

DECLARE @GHIDMap TABLE (
	New_GH_ID int NOT NULL PRIMARY KEY,
	GH_ID int NOT NULL
)
		
DECLARE @GHTaxIDMap TABLE (
	New_GH_TAX_ID int NOT NULL PRIMARY KEY,
	GH_TAX_ID int NOT NULL
)

IF @Error = 0 BEGIN

	MERGE INTO CIC_GeneralHeading dst
	USING (SELECT DISTINCT tm.ItemID AS GH_ID, gh.Used, gh.TaxonomyName, gh.TaxonomyRestrict, gh.NonPublic, gh.IconNameFull
			FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
			INNER JOIN CIC_GeneralHeading gh
				ON tm.ItemID=gh.GH_ID AND gh.PB_ID<>@PB_ID
			LEFT JOIN CIC_GeneralHeading_Name ghn
				ON gh.GH_ID=ghn.GH_ID
			INNER JOIN CIC_Publication pb
				-- Logic here is on permission to use the source heading so it needs to be shared or owned or user needs to be Global Super user
				ON gh.PB_ID=pb.PB_ID AND (pb.MemberID IS NULL OR @SuperUserGlobal=1 OR pb.MemberID=@MemberID)
			WHERE (gh.Used=1 OR gh.Used IS NULL) 
				AND (
					gh.TaxonomyName=1 OR NOT EXISTS(SELECT *
						FROM CIC_GeneralHeading gh2
						INNER JOIN CIC_GeneralHeading_Name ghn2
							ON gh2.GH_ID=ghn2.GH_ID AND ghn2.LangID=ghn.LangID AND ghn2.Name=ghn.Name
						WHERE gh2.PB_ID=@PB_ID)
				)
			) src ON 0=1
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (PB_ID, Used, TaxonomyName, TaxonomyRestrict, NonPublic, IconNameFull, CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY)
			VALUES (@PB_ID, src.Used, src.TaxonomyName, src.TaxonomyRestrict, src.NonPublic, src.IconNameFull, GETDATE(), @MODIFIED_BY, GETDATE(), @MODIFIED_BY)
	OUTPUT INSERTED.GH_ID, src.GH_ID INTO @GHIDMap 
	;

	INSERT INTO CIC_GeneralHeading_Name (GH_ID, LangID, [Name])
		SELECT New_GH_ID, LangID, [Name]
			FROM @GHIDMap tm
			INNER JOIN CIC_GeneralHeading_Name ghn
				ON tm.GH_ID=ghn.GH_ID
		WHERE NOT EXISTS(SELECT *
			FROM CIC_GeneralHeading gh2
			INNER JOIN CIC_GeneralHeading_Name ghn2
				ON gh2.GH_ID=ghn2.GH_ID AND ghn2.LangID=ghn.LangID
			WHERE gh2.PB_ID=@PB_ID AND ghn2.Name=ghn.Name)
			
	MERGE INTO CIC_GeneralHeading_TAX dst
	USING (SELECT ght.GH_TAX_ID, tm.New_GH_ID, MatchAny
			FROM CIC_GeneralHeading_TAX ght
			INNER JOIN @GHIDMap tm
				ON tm.GH_ID=ght.GH_ID) src
		ON 0=1
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (GH_ID, MatchAny) VALUES (src.New_GH_ID, src.MatchAny)
	OUTPUT INSERTED.GH_TAX_ID, src.GH_TAX_ID INTO @GHTaxIDMap (New_GH_TAX_ID, GH_TAX_ID)
		;
		
	INSERT INTO CIC_GeneralHeading_TAX_TM (GH_TAX_ID, Code)
		SELECT tm.New_GH_TAX_ID, ghtm.Code
			FROM @GHTaxIDMap tm
			INNER JOIN CIC_GeneralHeading_TAX_TM ghtm
				ON tm.GH_TAX_ID=ghtm.GH_TAX_ID

END

RETURN @Error

SET NOCOUNT OFF



GO


GRANT EXECUTE ON  [dbo].[sp_CIC_GeneralHeading_u_Copy] TO [cioc_login_role]
GO
