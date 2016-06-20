
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Users_u_Login]
	@MemberID int,
	@UserName varchar(30),
	@Success bit,
	@IPAddress varchar(20),
	@SingleLoginKey char(44)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON
/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 18-Dec-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE @LoginRetryLimit tinyint
SELECT @LoginRetryLimit=ISNULL(LoginRetryLimit,5) FROM STP_Member WHERE MemberID=@MemberID

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END ELSE BEGIN

	IF @Success = 1 BEGIN
		UPDATE GBL_Users
			SET SingleLoginKey = CASE WHEN SingleLogin=1 THEN @SingleLoginKey ELSE NULL END,
				LoginAttempts = NULL,
				LastLoginAttempt = NULL,
				LastLoginAttemptIP = NULL,
				LastSuccessfulLogin = GETDATE(),
				LastSuccessfulLoginIP = @IPAddress
		WHERE MemberID_Cache=@MemberID
			AND UserName=@UserName
	END ELSE BEGIN
		UPDATE GBL_Users
			SET LoginAttempts = ISNULL(LoginAttempts,0) + CASE WHEN LoginAttempts=255 THEN 0 ELSE 1 END,
				LastLoginAttempt = GETDATE(),
				LastLoginAttemptIP = @IPAddress
		WHERE MemberID_Cache=@MemberID
			AND UserName=@UserName
	END

	IF (SELECT COUNT(*) FROM GBL_Users WHERE LastLoginAttemptIP=@IPAddress AND LoginAttempts >= @LoginRetryLimit) > 2 
			AND NOT EXISTS(SELECT * FROM dbo.GBL_Banned_Whitelist WHERE IPAddress=@IPAddress) BEGIN
		INSERT INTO GBL_Banned (IPAddress, LoginBanOnly)
		SELECT @IPAddress, 1 WHERE NOT EXISTS(SELECT * FROM GBL_Banned WHERE IPAddress=@IPAddress)
	END

END

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_GBL_Users_u_Login] TO [cioc_login_role]
GO
