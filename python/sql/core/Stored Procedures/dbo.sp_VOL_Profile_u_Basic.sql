SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_u_Basic]
	@MemberID [int],
	@ProfileID [uniqueidentifier],
	@Email [varchar](60),
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
	@FromEmail [varchar](60) OUTPUT,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: CL
	Checked on: 27-Jul-2012
	Action: NO ACTION REQUIRED
*/

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

IF @Email IS NULL SET @ConfirmationToken = NULL

DECLARE @ConfirmationDate smalldatetime
IF @Email IS NULL BEGIN
	SET @ConfirmationDate = NULL
END ELSE BEGIN
	SET @ConfirmationDate = GETDATE()
END

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
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @VolunteerProfileObjectName)
-- Profile belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Profile is Active and not Blocked ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID AND Active=1 AND Blocked=0) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
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
-- Email AND Confirmation Token Given ?
END ELSE IF @Email IS NOT NULL AND @ConfirmationToken IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Confirmation Token'), @VolunteerProfileObjectName)
END ELSE IF @EMAIL IS NOT NULL AND EXISTS(SELECT * FROM VOL_Profile WHERE [Email]=@Email AND MemberID=@MemberID AND ProfileID<>@ProfileID) BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Email, @VolunteerProfileObjectName)
END ELSE BEGIN
	UPDATE VOL_Profile SET
		MODIFIED_DATE		= GETDATE(),
		[Password]			= CASE WHEN @PasswordHash IS NOT NULL THEN NULL ELSE [Password] END,
		PasswordHash		= ISNULL(@PasswordHash, PasswordHash),
		PasswordHashRepeat	= ISNULL(@PasswordHashRepeat, PasswordHashRepeat),
		PasswordHashSalt	= ISNULL(@PasswordHashSalt, PasswordHashSalt),
		FirstName			= @FirstName,
		LastName			= @LastName,
		Phone				= @Phone,
		[Address]			= @Address,
		City				= @City,
		Province			= @Province,
		PostalCode			= @PostalCode,
		[LangID]			= @LangID,
		OrgCanContact		= ISNULL(@OrgCanContact,OrgCanContact),
		AgreedToPrivacyPolicy = ISNULL(@AgreedToPrivacyPolicy,AgreedToPrivacyPolicy),
		NewEmail			= ISNULL(@Email, [Email]),
		ConfirmationToken	= ISNULL(@ConfirmationToken, [ConfirmationToken]),
		ConfirmationDate	= ISNULL(@ConfirmationDate, [ConfirmationDate])
	WHERE ProfileID=@ProfileID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolunteerProfileObjectName, @ErrMsg OUTPUT
	
	SELECT @FromEmail = DefaultEmailVOLProfile FROM STP_Member WHERE MemberID=@MemberID
END

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Basic] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Basic] TO [cioc_vol_search_role]
GO
