SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_u_PWReset]
	@MemberID [int],
	@Email [varchar](100),
	@PasswordHash [varchar](44),
	@PasswordHashSalt [varchar](44),
	@PasswordHashRepeat [varchar](44),
	@FromEmail [varchar](100) OUTPUT,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@VolunteerProfileObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @VolunteerProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Profile')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Login given ?
END ELSE IF @Email IS NULL BEGIN
	SET @Error = 13 -- No Login
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
-- Login exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE MemberID=@MemberID AND Email=@Email) BEGIN
	SET @Error = 14 -- No Such Login
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Email, NULL)
-- Login is active ?
END ELSE IF EXISTS(SELECT * FROM VOL_Profile WHERE Email=@Email AND Active=0) BEGIN
	SET @Error = 18 -- Login not active.
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
-- Login is not blocked ?
END ELSE IF EXISTS(SELECT * FROM VOL_Profile WHERE Email=@Email AND Blocked=1) BEGIN
	SET @Error = 19 -- Login Blocked
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END ELSE BEGIN
	UPDATE VOL_Profile
	SET	MODIFIED_DATE		= GETDATE(),
		Password			= NULL,
		PasswordHash		= ISNULL(@PasswordHash, PasswordHash),
		PasswordHashRepeat	= ISNULL(@PasswordHashRepeat, PasswordHashRepeat),
		PasswordHashSalt	= ISNULL(@PasswordHashSalt, PasswordHashSalt)
	WHERE Email=@Email AND MemberID=@MemberID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolunteerProfileObjectName, @ErrMsg

	SELECT @FromEmail = DefaultEmailVOLProfile
		FROM STP_Member
	WHERE MemberID=@MemberID
END

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_PWReset] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_PWReset] TO [cioc_vol_search_role]
GO
