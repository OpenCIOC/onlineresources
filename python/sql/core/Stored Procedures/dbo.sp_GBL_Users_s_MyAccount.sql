SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Users_s_MyAccount]
	@User_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 26-Jul-2012
	Action: NO ACTION REQUIRED
*/

SELECT	u.CREATED_DATE,
		u.CREATED_BY,
		u.MODIFIED_DATE,
		u.MODIFIED_BY, 
		u.FirstName,
		u.LastName,
		u.Initials,
		u.Email,
		u.StartModule,
		u.StartLanguage,
		u.CanUpdateAccount,
		u.CanUpdatePassword,
		a.UpdateAccountEmail,
		sl.Culture AS UpdateAccountCulture,
		u.LastSuccessfulLogin,
		u.LastSuccessfulLoginIP
	FROM GBL_Users u
	INNER JOIN GBL_Agency a
		ON a.AgencyCode=u.Agency
	LEFT JOIN STP_Language sl
		ON a.UpdateAccountLangID=sl.LangID
WHERE [User_ID]=@User_ID

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_s_MyAccount] TO [cioc_login_role]
GO
