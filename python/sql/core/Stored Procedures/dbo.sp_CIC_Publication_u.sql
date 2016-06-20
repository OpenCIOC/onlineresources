
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Publication_u]
	@PB_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@SuperUserGlobal bit,
	@PubCode [varchar](20),
	@NonPublic [bit],
	@FieldHeadings [bit],
	@FieldHeadingsNP [bit],
	@FieldDesc [bit],
	@FieldHeadingGroups [bit],
	@FieldHeadingGroupsNP [bit],
	@CanEditHeadingsShared [bit],
	@Descriptions [xml],
	@Groups [xml],
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
DECLARE	@Error		int
SET @Error = 0

DECLARE	@PublicationObjectName nvarchar(100),
		@CodeObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@GroupObjectName nvarchar(100),
		@MemberObjectName nvarchar(100)

SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')
SET @CodeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Code')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @GroupObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Group')
SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Name nvarchar(100) NULL,
	Notes nvarchar(max) NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Name,
	Notes
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('Name[1]', 'nvarchar(100)') AS Name,
	N.value('Notes[1]', 'nvarchar(max)') AS Notes
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM CIC_Publication pub INNER JOIN CIC_Publication_Name pubn ON pub.PB_ID=pubn.PB_ID WHERE Name=nt.Name AND LangID=nt.LangID AND pub.PB_ID<>@PB_ID)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

DECLARE @GroupUsedNames nvarchar(max),
		@GroupBadCultures nvarchar(max)

DECLARE @GroupTable TABLE (
	CNT int NOT NULL,
	GroupID int NOT NULL,
	DisplayOrder tinyint NOT NULL,
	IconNameFull varchar(65) NULL
)

DECLARE @GroupDescription TABLE (
	CNT int NOT NULL,
	GroupID int NOT NULL,
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Name nvarchar(200) NULL
)

INSERT INTO @GroupTable (
	CNT,
	GroupID,
	DisplayOrder,
	IconNameFull
)
SELECT
	N.value('CNT[1]', 'int') AS CNT,
	N.value('GroupID[1]', 'int') AS GroupID,
	N.value('DisplayOrder[1]', 'tinyint') AS DisplayOrder,
	N.value('IconNameFull[1]', 'varchar(65)') AS IconNameFull
FROM @Groups.nodes('//GROUP') as T(N)

UPDATE @GroupTable
	SET IconNameFull = CASE WHEN EXISTS(SELECT * FROM STP_Icon WHERE Type + '-' + IconName = IconNameFull) THEN IconNameFull ELSE NULL END
	
INSERT INTO @GroupDescription(
	CNT,
	GroupID,
	Culture,
	LangID,
	Name
)
SELECT
	N.value('CNT[1]', 'int') AS CNT,
	N.value('GroupID[1]', 'int') AS GroupID,
	iq.*
FROM @Groups.nodes('//GROUP') as T(N) CROSS APPLY 
	( SELECT 
		D.value('Culture[1]', 'varchar(5)') AS Culture,
		(SELECT LangID FROM STP_Language sl WHERE sl.Culture = D.value('Culture[1]', 'varchar(5)') AND ActiveRecord=1) AS LangID,
		D.value('Name[1]', 'nvarchar(200)') AS Name
			FROM N.nodes('DESCS/DESC') AS T2(D) ) iq 
			
SELECT @GroupBadCultures = COALESCE(@GroupBadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @GroupDescription nt
WHERE LangID IS NULL

SELECT DISTINCT @GroupUsedNames = COALESCE(@GroupUsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @GroupDescription gd WHERE EXISTS(SELECT * FROM @GroupDescription WHERE gd.Name=Name AND gd.LangID=LangID AND gd.CNT<>CNT)


-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Publication ID exists ?
END ELSE IF @PB_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM CIC_Publication WHERE PB_ID=@PB_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PB_ID AS varchar), @PublicationObjectName)
-- Publication can be edited by Member ?
END ELSE IF @PB_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM CIC_Publication WHERE PB_ID=@PB_ID AND (MemberID=@MemberID OR (MemberID IS NULL AND @SuperUserGlobal=1))) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE IF @PubCode IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CodeObjectName, @PublicationObjectName)
END ELSE IF EXISTS(SELECT * FROM CIC_Publication WHERE PubCode=@PubCode AND (@PB_ID IS NULL OR PB_ID<>@PB_ID)) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PubCode, @PublicationObjectName)
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END ELSE IF @GroupUsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @GroupUsedNames, @GroupObjectName)
END ELSE IF @GroupBadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @GroupBadCultures, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	IF @PB_ID IS NULL BEGIN
		INSERT INTO CIC_Publication (
			PubCode,
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			NonPublic,
			FieldHeadings,
			FieldHeadingsNP,
			FieldDesc,
			FieldHeadingGroups,
			FieldHeadingGroupsNP,
			CanEditHeadingsShared
		) VALUES (
			@PubCode,
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@NonPublic,
			@FieldHeadings,
			@FieldHeadingsNP,
			@FieldDesc,
			@FieldHeadingGroups,
			@FieldHeadingGroupsNP,
			@CanEditHeadingsShared
		)
		SELECT @PB_ID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE CIC_Publication
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			PubCode				= @PubCode,
			NonPublic			= @NonPublic,
			FieldHeadings		= @FieldHeadings,
			FieldHeadingsNP		= @FieldHeadingsNP,
			FieldDesc			= @FieldDesc,
			FieldHeadingGroups	= @FieldHeadingGroups,
			FieldHeadingGroupsNP	= @FieldHeadingGroupsNP,
			CanEditHeadingsShared = @CanEditHeadingsShared
		WHERE PB_ID = @PB_ID	
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
	

	IF @Error=0 AND @PB_ID IS NOT NULL BEGIN
		DELETE pubn
		FROM CIC_Publication_Name pubn
		WHERE pubn.PB_ID=@PB_ID
			AND NOT EXISTS(SELECT * FROM @DescTable nt WHERE pubn.LangID=nt.LangID AND (Name IS NOT NULL OR Notes IS NOT NULL))
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
		
		UPDATE pubn SET
			Name		= nt.Name,
			Notes		= nt.Notes
		FROM CIC_Publication_Name pubn
		INNER JOIN @DescTable nt
			ON pubn.LangID=nt.LangID
		WHERE pubn.PB_ID=@PB_ID
	
		INSERT INTO CIC_Publication_Name (
			PB_ID,
			LangID,
			Name,
			Notes
		) SELECT
			@PB_ID,
			LangID,
			Name,
			Notes
		FROM @DescTable nt
		WHERE NOT EXISTS(SELECT * FROM CIC_Publication_Name WHERE PB_ID=@PB_ID AND LangID=nt.LangID) AND (Name IS NOT NULL OR Notes IS NOT NULL)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
		
		
		DECLARE @IDMap TABLE (
			GroupID int NULL,
			CNT int NULL,
			ACTN varchar(10)
		)

		MERGE INTO CIC_GeneralHeading_Group hg
		USING @GroupTable nt
			ON nt.GroupID=hg.GroupID AND hg.PB_ID=@PB_ID
		WHEN MATCHED THEN
			UPDATE SET DisplayOrder = nt.DisplayOrder,
				IconNameFull = nt.IconNameFull
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (PB_ID, DisplayOrder, IconNameFull) VALUES (@PB_ID, nt.DisplayOrder, nt.IconNameFull)
		WHEN NOT MATCHED BY SOURCE AND hg.PB_ID=@PB_ID THEN
			DELETE
		
		OUTPUT INSERTED.GroupID, nt.CNT, $action INTO @IDMap
			;
			
		DELETE FROM @IDMap WHERE ACTN <> 'INSERT'
		
		MERGE INTO CIC_GeneralHeading_Group_Name hg
		USING (SELECT CASE WHEN nt.GroupID=-1 THEN map.GroupID ELSE nt.GroupID END AS GroupID,
					nt.LangID, nt.Name 
						FROM @GroupDescription nt
						LEFT JOIN @IDMap map
							ON nt.CNT=map.CNT) nt
			ON nt.GroupID=hg.GroupID AND nt.LangID=hg.LangID
		WHEN MATCHED THEN
			UPDATE SET Name=nt.Name
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (GroupID, LangID, Name) 
				VALUES (nt.GroupID, nt.LangID, nt.Name)
		WHEN NOT MATCHED BY SOURCE AND EXISTS(SELECT * FROM CIC_GeneralHeading_Group WHERE hg.GroupID=GroupID AND PB_ID=@PB_ID) THEN
			DELETE
			;
			
	END
END

RETURN @Error

SET NOCOUNT OFF


GO


GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_u] TO [cioc_login_role]
GO
