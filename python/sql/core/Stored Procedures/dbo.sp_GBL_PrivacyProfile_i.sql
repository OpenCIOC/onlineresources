SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrivacyProfile_i]
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@ProfileName [varchar](50),
	@ProfileID [int] OUTPUT,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-May-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
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

DECLARE	@CopyProfileID int

SET @ProfileName = NULLIF(RTRIM(LTRIM(@ProfileName)), '')
SET @CopyProfileID = @ProfileID

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Copy Profile ID exists ?
END ELSE IF @CopyProfileID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_PrivacyProfile WHERE ProfileID=@CopyProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @ProfileObjectName)
-- Profile ID belongs to Member ?
END ELSE IF @CopyProfileID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_PrivacyProfile WHERE ProfileID=@CopyProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Profile Name given ?
END ELSE IF @ProfileName IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @ProfileObjectName)
-- Profile Name in use ?
END ELSE IF EXISTS (SELECT * FROM GBL_PrivacyProfile pp INNER JOIN GBL_PrivacyProfile_Name ppd ON pp.ProfileID=ppd.ProfileID WHERE ProfileName = @ProfileName AND LangID=@@LANGID) BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileName, @NameObjectName)
END ELSE BEGIN
	INSERT INTO GBL_PrivacyProfile (
		MemberID,
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY
	) VALUES (
		@MemberID,
		GETDATE(),
		@MODIFIED_BY,
		GETDATE(),
		@MODIFIED_BY
	)
	SELECT @ProfileID = SCOPE_IDENTITY()
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg OUTPUT
	
	IF @Error = 0 BEGIN
		INSERT INTO GBL_PrivacyProfile_Name ( ProfileID, LangID, ProfileName)
			VALUES (@ProfileID, @@LANGID, @ProfileName) 
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg OUTPUT
	END
	
	IF @Error = 0 AND @CopyProfileID IS NOT NULL BEGIN
		INSERT INTO GBL_PrivacyProfile_Fld (ProfileID, FieldID)
			SELECT @ProfileID AS ProfileID, FieldID
				FROM GBL_PrivacyProfile_Fld
			WHERE ProfileID = @CopyProfileID
	END
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrivacyProfile_i] TO [cioc_login_role]
GO
