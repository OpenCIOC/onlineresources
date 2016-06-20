SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_LoginCheck]
	@MemberID int,
	@UserName varchar(30),
	@IPAddress varchar(20)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 11-Nov-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

SELECT * FROM GBL_Banned WHERE IPAddress=@IPAddress

SELECT	StartModule, sl.Culture AS StartCulture, UserUID,
		PasswordHashRepeat, PasswordHashSalt, PasswordHash,
		Inactive, SingleLogin, ISNULL(LoginAttempts,0) AS LoginAttempts,
		u.Email, (SELECT ISNULL(a.UpdateAccountEmail,a.UpdateEmailCIC) FROM GBL_Agency a WHERE AgencyCode=u.Agency) AS AgencyEmail, SingleLoginKey
	FROM GBL_Users u
	INNER JOIN STP_Language sl
		ON u.StartLanguage=sl.LangID
WHERE UserName = @UserName AND MemberID_Cache=@MemberID

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_GBL_LoginCheck] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_LoginCheck] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_LoginCheck] TO [cioc_vol_search_role]
GO
