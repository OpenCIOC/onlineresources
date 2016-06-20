SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Users_sf]
	@EditUser_ID int,
	@User_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 10-May-2013
	Action: NO ACTION REQUIRED
*/

DECLARE	@MemberID int,
		@SuperUser bit,
		@SuperUserGlobal bit,
		@CanManageUsers bit,
		@UserAgency char(3)
		
SELECT	@MemberID=MemberID_Cache,
		@SuperUser = CASE WHEN cs.SuperUser=1 OR vs.SuperUser=1 THEN 1 ELSE 0 END,
		@SuperUserGlobal = CASE WHEN cs.SuperUserGlobal=1 OR vs.SuperUserGlobal=1 THEN 1 ELSE 0 END,
		@CanManageUsers = CASE WHEN cs.CanManageUsers=1 OR vs.CanManageUsers=1 THEN 1 ELSE 0 END,
		@UserAgency=Agency
	FROM GBL_Users u
	LEFT JOIN CIC_SecurityLevel cs
		ON u.SL_ID_CIC = cs.SL_ID
	LEFT JOIN VOL_SecurityLevel vs
		ON u.SL_ID_VOL = vs.SL_ID
WHERE [User_ID]=@User_ID

SELECT u.*
	FROM GBL_Users u
	LEFT JOIN CIC_SecurityLevel cs
		ON u.SL_ID_CIC = cs.SL_ID
	LEFT JOIN VOL_SecurityLevel vs
		ON u.SL_ID_VOL = vs.SL_ID
WHERE [User_ID]=@EditUser_ID
	AND u.MemberID_Cache=@MemberID
	AND (@CanManageUsers=1 OR @SuperUser=1)
	AND (@SuperUser=1 OR
		(Agency=@UserAgency
		AND (cs.SuperUser=0 OR u.SL_ID_CIC IS NULL)
		AND (vs.SuperUser=0 OR u.SL_ID_VOL IS NULL)))
	AND (@SuperUserGlobal=1 OR ((cs.SuperUserGlobal=0 OR u.SL_ID_CIC IS NULL) AND (vs.SuperUserGlobal=0 OR u.SL_ID_VOL IS NULL)))

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_sf] TO [cioc_login_role]
GO
