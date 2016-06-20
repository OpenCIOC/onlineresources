SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrintProfile_Fld_u]
	@PFLD_ID [int],
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@Domain tinyint,
	@HeadingLevel [tinyint],
	@Separator [varchar](50),
	@LabelStyle [varchar](50),
	@ContentStyle [varchar](50),
	@DisplayOrder [tinyint],
	@Descriptions xml,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ProfileObjectName nvarchar(100),
		@FieldObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')
SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @ProfileID	int
SELECT @ProfileID=ProfileID FROM GBL_PrintProfile_Fld WHERE PFLD_ID=@PFLD_ID

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Label nvarchar(50) NULL,
	ContentIfEmpty nvarchar(100) NULL,
	Prefix nvarchar(max) NULL,
	Suffix nvarchar(max) NULL
)

DECLARE @BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Label,
	ContentIfEmpty,
	Prefix,
	Suffix
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('Label[1]', 'nvarchar(50)') AS Label,
	N.value('ContentIfEmpty[1]', 'nvarchar(100)') AS ContentIfEmpty,
	N.value('Prefix[1]', 'nvarchar(100)') AS Prefix,
	N.value('Suffix[1]', 'nvarchar(100)') AS Suffix
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @ProfileObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND Domain=@Domain) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar(20)), @ProfileObjectName)
-- Profile belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Field ID given ?
END ELSE IF @PFLD_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FieldObjectName, NULL)
-- Invalid language ?
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END
IF @Error = 0 BEGIN
	UPDATE GBL_PrintProfile_Fld SET
		HeadingLevel		= @HeadingLevel,
		Separator			= @Separator,
		LabelStyle			= @LabelStyle,
		ContentStyle		= @ContentStyle,
		DisplayOrder		= @DisplayOrder
	WHERE PFLD_ID = @PFLD_ID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg
	
	IF @Error = 0 BEGIN
		MERGE INTO GBL_PrintProfile_Fld_Description pfd
		USING @DescTable nt
			ON pfd.PFLD_ID=@PFLD_ID AND pfd.LangID=nt.LangID
		WHEN MATCHED THEN 
			UPDATE SET Label=nt.Label, ContentIfEmpty=nt.ContentIfEmpty, Prefix=nt.Prefix, Suffix=nt.Suffix
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (PFLD_ID, LangID, Label, ContentIfEmpty, Prefix, Suffix)
				VALUES (@PFLD_ID, nt.LangID, nt.Label, nt.ContentIfEmpty, nt.Prefix, nt.Suffix)
		WHEN NOT MATCHED BY SOURCE AND pfd.PFLD_ID=@PFLD_ID THEN
			DELETE
			;
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg
	END
	
	IF @Error = 0 BEGIN
		UPDATE GBL_PrintProfile
		SET MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY
		WHERE ProfileID=@ProfileID
	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrintProfile_Fld_u] TO [cioc_login_role]
GO
