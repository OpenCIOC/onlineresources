SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_LoginCheck]
	@MemberID int,
	@Email [varchar](100)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

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
