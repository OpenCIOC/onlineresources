SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Profile_u_Login]
	@MemberID int,
	@Email [varchar](60),
	@LoginKey [char](32),
	-- next three are for gradual move to new hashing
	@PasswordHash [varchar](44),
	@PasswordHashSalt [varchar](44),
	@PasswordHashRepeat [varchar](44)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: CL
	Checked on: 26-Jun-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@VolunteerProfileObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END ELSE BEGIN
	UPDATE VOL_Profile SET 
		LoginKey	= @LoginKey,
		PasswordHash = ISNULL(@PasswordHash, PasswordHash),
		PasswordHashRepeat = ISNULL(@PasswordHashRepeat, PasswordHashRepeat),
		PasswordHashSalt = ISNULL(@PasswordHashSalt, PasswordHashSalt),
		Password = NULL
	WHERE Email = @Email
		AND MemberID=@MemberID
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Login] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Login] TO [cioc_vol_search_role]
GO
