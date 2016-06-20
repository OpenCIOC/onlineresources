
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_GeneralHeading_i_QuickTax]
	@PB_ID int,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@SuperUserGlobal bit,
	@CodeList varchar(max),
	@BadCodes varchar(max) OUTPUT,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: CL
	Checked on: 2-Jun-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@GeneralHeadingObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @GeneralHeadingObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('General Heading')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')


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

DECLARE @CodeTable TABLE (
	Code varchar(21) NOT NULL PRIMARY KEY
)

DECLARE @CodeGHIDMap TABLE (
	Code varchar(21) NOT NULL PRIMARY KEY,
	GH_ID int
)

INSERT INTO @CodeTable
SELECT DISTINCT tax.Code
	FROM dbo.fn_GBL_ParseVarCharIDList(@CodeList,',') tm
	INNER JOIN TAX_Term tax
		ON tm.ItemID=tax.Code COLLATE Latin1_General_100_CS_AI

IF @Error = 0 BEGIN
	MERGE INTO CIC_GeneralHeading dst
	USING (SELECT ct.Code
			FROM @CodeTable ct
			WHERE NOT (
				EXISTS(SELECT *
					FROM CIC_GeneralHeading gh
					INNER JOIN CIC_GeneralHeading_Name ghn
						ON gh.GH_ID=ghn.GH_ID
					INNER JOIN TAX_Term_Description tmd
						ON tmd.Code=ct.Code AND tmd.LangID=ghn.LangID AND tmd.Term=ghn.Name
					WHERE gh.PB_ID=@PB_ID)
				
				OR EXISTS(SELECT *
					FROM CIC_GeneralHeading gh
					WHERE gh.PB_ID=@PB_ID
						AND gh.TaxonomyName=1
						AND (SELECT COUNT(*) FROM CIC_GeneralHeading_TAX ght INNER JOIN CIC_GeneralHeading_TAX_TM ghtm ON ght.GH_TAX_ID=ghtm.GH_TAX_ID WHERE ght.GH_ID=gh.GH_ID)=1
						AND EXISTS(SELECT * FROM CIC_GeneralHeading_TAX ght INNER JOIN CIC_GeneralHeading_TAX_TM ghtm ON ght.GH_TAX_ID=ghtm.GH_TAX_ID WHERE ght.GH_ID=gh.GH_ID AND ghtm.Code=ct.Code)
				)
			)
		) src ON 0=1
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (PB_ID, Used, TaxonomyName, TaxonomyRestrict, NonPublic, CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY)
			VALUES (@PB_ID, NULL, 1, 0, 0, GETDATE(), @MODIFIED_BY, GETDATE(), @MODIFIED_BY)
	OUTPUT src.Code, INSERTED.GH_ID INTO @CodeGHIDMap 
	;
		
	INSERT INTO CIC_GeneralHeading_TAX (GH_ID, MatchAny)
	SELECT GH_ID, 0
		FROM @CodeGHIDMap
		
	INSERT INTO CIC_GeneralHeading_TAX_TM (GH_TAX_ID, Code)
		SELECT GH_TAX_ID, tm.Code
			FROM @CodeGHIDMap tm
			INNER JOIN CIC_GeneralHeading_TAX ght
				ON ght.GH_ID=tm.GH_ID

	SELECT @BadCodes=COALESCE(@BadCodes + ', ','') + Code
		FROM @CodeTable ct
	WHERE NOT EXISTS(SELECT * FROM @CodeGHIDMap cmap WHERE ct.Code=cmap.Code)
	
	IF @BadCodes = '' SET @BadCodes = NULL
	
	IF @BadCodes IS NOT NULL BEGIN
		-- SET @Error = 31 -- values not added
		SET @BadCodes = cioc_shared.dbo.fn_SHR_STP_FormatError(31, NULL, NULL) + @BadCodes
	END

END

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_GeneralHeading_i_QuickTax] TO [cioc_login_role]
GO
