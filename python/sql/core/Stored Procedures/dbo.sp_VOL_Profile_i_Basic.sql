SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_i_Basic]
	@MemberID [int],
	@ProfileID [uniqueidentifier] OUTPUT,
	@Email [varchar](100),
	@PasswordHash [varchar](44),
	@PasswordHashSalt [varchar](44),
	@PasswordHashRepeat [varchar](44),
	@FirstName [nvarchar](50),
	@LastName [nvarchar](50),
	@Phone [nvarchar](100),
	@Address [nvarchar](150),
	@City [nvarchar](100),
	@Province [varchar](2),
	@PostalCode [varchar](20),
	@LangID [int],
	@OrgCanContact [bit],
	@AgreedToPrivacyPolicy [bit],
	@ConfirmationToken [char](32),
	@FromEmail [varchar](100) OUTPUT,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@VolunteerProfileObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @VolunteerProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Profile')

SET @Email = RTRIM(LTRIM(@Email))
IF @Email = '' SET @Email = NULL

SET @FirstName = RTRIM(LTRIM(@FirstName))
IF @FirstName = '' SET @FirstName = NULL

SET @LastName = RTRIM(LTRIM(@LastName))
IF @LastName = '' SET @LastName = NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Email given ?
END ELSE IF @Email IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Email'), @VolunteerProfileObjectName)
-- Possible Reactivation ?
END ELSE IF EXISTS(SELECT * FROM VOL_Profile WHERE [Email]=@Email AND MemberID=@MemberID AND Active=0) BEGIN
	SET @Error = 20
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
-- Email not in use ?
END ELSE IF EXISTS(SELECT * FROM VOL_Profile WHERE [Email]=@Email AND MemberID=@MemberID) BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Email, @VolunteerProfileObjectName)
-- Password given ?
END ELSE IF @PasswordHash IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Password'), @VolunteerProfileObjectName)
-- First Name given ?
END ELSE IF @FirstName IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('First Name'), @VolunteerProfileObjectName)
-- Last Name given ?
END ELSE IF @LastName IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Last Name'), @VolunteerProfileObjectName)
-- Language ID given ?
END ELSE IF @LangID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Language'), @VolunteerProfileObjectName)
-- Language ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Language WHERE LangID=@LangID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@LangID AS varchar), @LanguageObjectName)
-- Confirmation Token given ?
END ELSE IF @ConfirmationToken IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Confirmation Token'), @VolunteerProfileObjectName)
END ELSE BEGIN
	INSERT INTO VOL_Profile (
		CREATED_DATE,
		MODIFIED_DATE,
		MemberID,
		Email,
		[Password],
		PasswordHash,
		PasswordHashRepeat,
		PasswordHashSalt,
		FirstName,
		LastName,
		Phone,
		[Address],
		City,
		Province,
		PostalCode,
		[LangID],
		OrgCanContact,
		AgreedToPrivacyPolicy,
		ConfirmationToken,
		ConfirmationDate,
		Verified,
		Active
	) VALUES (
		GETDATE(),
		GETDATE(),
		@MemberID,
		@Email,
		NULL,
		@PasswordHash,
		@PasswordHashRepeat,
		@PasswordHashSalt,
		@FirstName,
		@LastName,
		@Phone,
		@Address,
		@City,
		@Province,
		@PostalCode,
		@LangID,
		ISNULL(@OrgCanContact,0),
		ISNULL(@AgreedToPrivacyPolicy,0),
		@ConfirmationToken,
		GETDATE(),
		0,
		1
	)
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolunteerProfileObjectName, @ErrMsg OUTPUT
	IF @Error=0 BEGIN
		SELECT @ProfileID=ProfileID FROM VOL_Profile WHERE Email=@Email
	END
	
	SELECT @FromEmail = DefaultEmailVOLProfile FROM STP_Member WHERE MemberID=@MemberID
END

RETURN @Error

SET NOCOUNT OFF






GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_i_Basic] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_i_Basic] TO [cioc_vol_search_role]
GO
