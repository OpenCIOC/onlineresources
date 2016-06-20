SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_LoginCheck]
	@MemberID int,
	@Email [varchar](60)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: CL
	Checked on: 26-Jul-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0



SELECT l.Culture AS StartCulture, Password, PasswordHashRepeat, PasswordHashSalt, PasswordHash, vp.Active, vp.Blocked
FROM VOL_Profile vp
INNER JOIN STP_Language l
	ON vp.LangID=l.LangID
WHERE vp.Email=@Email AND MemberID=@MemberID

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_LoginCheck] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_LoginCheck] TO [cioc_vol_search_role]
GO
