SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrivacyProfile_u]
	@ProfileID [int],
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@Descriptions [xml],
	@IdList [varchar](max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@ProfileObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@FieldObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	ProfileName nvarchar(100) NOT NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	ProfileName
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('ProfileName[1]', 'nvarchar(100)') AS ProfileName
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ProfileName
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM GBL_PrivacyProfile pp INNER JOIN GBL_PrivacyProfile_Name ppn ON pp.ProfileID=ppn.ProfileID WHERE ProfileName=nt.ProfileName AND LangID=nt.LangID AND pp.ProfileID<>@ProfileID)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

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
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrivacyProfile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @ProfileObjectName)
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrivacyProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
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
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE ProfileName IS NOT NULL) BEGIN
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
	UPDATE GBL_PrivacyProfile 
	SET	MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= @MODIFIED_BY
	WHERE ProfileID = @ProfileID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg OUTPUT
	
	IF @Error = 0 BEGIN
		MERGE INTO GBL_PrivacyProfile_Name ppn
		USING @DescTable nt
			ON ppn.ProfileID=@ProfileID AND ppn.LangID=nt.LangID
		WHEN MATCHED THEN
			UPDATE SET ProfileName=nt.ProfileName
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ProfileID, LangID, ProfileName) 
				VALUES (@ProfileID, nt.LangID, nt.ProfileName)
		WHEN NOT MATCHED BY SOURCE AND ppn.ProfileID=@ProfileID THEN
			DELETE
			;
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg OUTPUT
	END
	
	IF @Error = 0 BEGIN
		DECLARE @tmpFieldIDs TABLE(FieldID int)

		INSERT INTO @tmpFieldIDs SELECT DISTINCT tm.*
			FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
			INNER JOIN GBL_FieldOption fo
				ON tm.ItemID = fo.FieldID
			WHERE fo.CanUsePrivacy=1

		DELETE pr
			FROM GBL_PrivacyProfile_Fld pr
			LEFT JOIN @tmpFieldIDs tm
				ON pr.FieldID = tm.FieldID
		WHERE tm.FieldID IS NULL AND ProfileID=@ProfileID

		INSERT INTO GBL_PrivacyProfile_Fld (ProfileID, FieldID) SELECT ProfileID=@ProfileID, tm.FieldID
			FROM @tmpFieldIDs tm
		WHERE NOT EXISTS(SELECT * FROM GBL_PrivacyProfile_Fld pr WHERE ProfileID=@ProfileID AND pr.FieldID=tm.FieldID)
	END
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrivacyProfile_u] TO [cioc_login_role]
GO
