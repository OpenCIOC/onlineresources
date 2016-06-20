SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_s_Login]
	@MemberID int,
	@Email varchar(60),
	@LoginKey char(32),
	@ProfileID [uniqueidentifier] OUTPUT,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

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
END IF @Email IS NULL BEGIN
	SET @Error = 13 -- No Login
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
-- Login exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE Email=@Email AND MemberID=@MemberID) BEGIN
	SET @Error = 14 -- No Such Login
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Email, NULL)
-- Valid Password ?
END ELSE IF @LoginKey IS NULL OR NOT EXISTS(SELECT * FROM VOL_Profile WHERE Email=@Email AND MemberID=@MemberID AND LoginKey=@LoginKey AND Blocked=0 AND Active=1) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
END ELSE BEGIN
	SELECT @ProfileID = ProfileID
		FROM VOL_Profile
	WHERE MemberID=@MemberID
		AND Email=@Email
		AND Active=1 And Blocked=0
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_s_Login] TO [cioc_login_role]
GO
