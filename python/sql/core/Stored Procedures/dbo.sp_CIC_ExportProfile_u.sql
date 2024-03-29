SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExportProfile_u]
	@ProfileID [int],
	@MODIFIED_BY [varchar](50),
	@MemberID [int],
	@SubmitChangesToAccessURL [varchar](255),
	@IncludePrivacyProfiles [bit],
	@ConvertLine1Line2Addresses [BIT],
	@InViews [varchar](max),
	@Descriptions [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ProfileObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@ViewObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')

IF @SubmitChangesToAccessURL = '' SET @SubmitChangesToAccessURL = NULL

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL PRIMARY KEY,
	LangID smallint NULL,
	Name nvarchar(100) NULL,
	SourceDbName nvarchar(255) NULL,
	SourceDbURL varchar(255) NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Name,	
	SourceDbName,
	SourceDbURL
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('Name[1]', 'nvarchar(100)') AS Name,	
	N.value('SourceDbName[1]', 'nvarchar(255)') AS SourceDbName,
	N.value('SourceDbURL[1]', 'nvarchar(255)') AS SourceDbURL
FROM @Descriptions.nodes('//DESC') as T(N)

UPDATE @DescTable
	SET Name = (SELECT TOP 1 Name FROM @DescTable WHERE Name IS NOT NULL ORDER BY LangID)
WHERE Name IS NULL

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(
	SELECT *
	FROM CIC_ExportProfile ep
	INNER JOIN CIC_ExportProfile_Description epn
		ON ep.ProfileID=epn.ProfileID
	WHERE ep.MemberID=@MemberID
		AND Name=nt.Name
		AND LangID=nt.LangID
		AND ep.ProfileID<>@ProfileID
	)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE NOT EXISTS(
	SELECT *
	FROM STP_Language
	WHERE LangID=nt.LangID
		AND Active=1
	)

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @ProfileObjectName)
-- Profile belongs to member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE MemberID=@MemberID AND ProfileID=@ProfileID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @ProfileObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE Name IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @ProfileObjectName)
-- Name in use ?
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
-- Invalid language ?
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	UPDATE CIC_ExportProfile 
	SET	MODIFIED_DATE				= GETDATE(),
		MODIFIED_BY					= @MODIFIED_BY,
		SubmitChangesToAccessURL	= @SubmitChangesToAccessURL,
		IncludePrivacyProfiles		= @IncludePrivacyProfiles,
		ConvertLine1Line2Addresses  = @ConvertLine1Line2Addresses
	WHERE ProfileID = @ProfileID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg

	IF @Error = 0 BEGIN
		MERGE INTO CIC_ExportProfile_Description ppd
		USING @DescTable nt
			ON @ProfileID=ppd.ProfileID AND ppd.LangID=nt.LangID
		WHEN MATCHED THEN
			UPDATE SET 
				Name = nt.Name,
				SourceDbName = nt.SourceDbName,
				SourceDbURL = nt.SourceDbURL
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (MemberID_Cache, ProfileID, LangID, Name, SourceDbName, SourceDbURL)
				VALUES (@MemberID, @ProfileID, nt.LangID, nt.Name, nt.SourceDbName, nt.SourceDbURL)
		WHEN NOT MATCHED BY SOURCE AND ppd.ProfileID=@ProfileID THEN
			DELETE
			;
			
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
	END

	IF @Error = 0 BEGIN
		MERGE INTO CIC_View_ExportProfile ppv
		USING (SELECT ViewType
				FROM CIC_View vw
				INNER JOIN fn_GBL_ParseIntIDList(@InViews, ',') nt
					ON ViewType=nt.ItemID) nt
			ON ppv.ProfileID=@ProfileID AND ppv.ViewType = nt.ViewType
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ProfileID, ViewType) VALUES (@ProfileID, nt.ViewType)
		WHEN NOT MATCHED BY SOURCE AND ppv.ProfileID=@ProfileID THEN
			DELETE
			;
			
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
	END

END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ExportProfile_u] TO [cioc_login_role]
GO
