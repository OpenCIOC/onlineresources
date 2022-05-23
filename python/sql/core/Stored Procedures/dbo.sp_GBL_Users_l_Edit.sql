SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Users_l_Edit]
	@User_ID [int],
	@UserName [varchar](50),
	@Agency [varchar](3),
	@FirstName [varchar](50),
	@LastName [varchar](50),
	@Email [varchar](100),
	@Inactive [bit],
	@Locked [bit],
	@SLIDCIC [int],
	@SLIDVOL [int]
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
		@UserAgency char(3),
		@LoginRetryLimit tinyint

IF @UserName='' SET @UserName=NULL
IF @Agency='' SET @Agency=NULL
IF @FirstName='' SET @FirstName=NULL
IF @LastName='' SET @LastName=NULL
IF @Email='' SET @Email=NULL

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

SELECT @LoginRetryLimit=LoginRetryLimit FROM STP_Member WHERE MemberID=@MemberID

SELECT u.*,
		csn.SecurityLevel AS SecurityLevelCIC,
		vsn.SecurityLevel AS SecurityLevelVOL,
		cv.ViewName AS ViewNameCIC,
		vv.ViewName AS ViewNameVOL
	FROM GBL_Users u
	LEFT JOIN CIC_SecurityLevel cs
		ON u.SL_ID_CIC = cs.SL_ID
	LEFT JOIN CIC_SecurityLevel_Name csn
		ON cs.SL_ID=csn.SL_ID AND csn.LangID=(SELECT TOP 1 LangID FROM CIC_SecurityLevel_Name WHERE csn.SL_ID=SL_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN CIC_View_Description cv
		ON cs.ViewType = cv.ViewType AND cv.LangID=(SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=cv.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_SecurityLevel vs
		ON u.SL_ID_VOL = vs.SL_ID
	LEFT JOIN VOL_SecurityLevel_Name vsn
		ON vs.SL_ID=vsn.SL_ID AND vsn.LangID=(SELECT TOP 1 LangID FROM VOL_SecurityLevel_Name WHERE vsn.SL_ID=SL_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_View_Description vv
		ON vs.ViewType = vv.ViewType AND vv.LangID=(SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vv.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE u.MemberID_Cache=@MemberID
	AND (@CanManageUsers=1 OR @SuperUser=1)
	AND (@SuperUser=1 OR
		(Agency=@UserAgency
		AND (cs.SuperUser=0 OR u.SL_ID_CIC IS NULL)
		AND (vs.SuperUser=0 OR u.SL_ID_VOL IS NULL)))
	AND (@SuperUserGlobal=1 OR ((cs.SuperUserGlobal=0 OR u.SL_ID_CIC IS NULL) AND (vs.SuperUserGlobal=0 OR u.SL_ID_VOL IS NULL)))
	AND (@UserName IS NULL OR u.UserName LIKE '%' + @UserName + '%' COLLATE Latin1_General_100_CI_AI)
	AND (@Agency IS NULL OR u.Agency=@Agency)
	AND (@FirstName IS NULL OR u.FirstName LIKE '%' + @FirstName + '%' COLLATE Latin1_General_100_CI_AI)
	AND (@LastName IS NULL OR u.LastName LIKE '%' + @LastName + '%' COLLATE Latin1_General_100_CI_AI)
	AND (@Email IS NULL OR u.Email LIKE '%' + @Email + '%' COLLATE Latin1_General_100_CI_AI)
	AND (@Inactive IS NULL OR u.Inactive=@Inactive)
	AND (@Locked IS NULL OR @LoginRetryLimit IS NULL OR (@Locked=1 AND ISNULL(LoginAttempts,0) >= @LoginRetryLimit) OR (@Locked=0 AND ISNULL(LoginAttempts,0) < @LoginRetryLimit))
	AND (@SLIDCIC IS NULL OR u.SL_ID_CIC=@SLIDCIC)
	AND (@SLIDVOL IS NULL OR u.SL_ID_VOL=@SLIDVOL)
ORDER BY u.UserName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_l_Edit] TO [cioc_login_role]
GO
