SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Users_s_Security]
	@MemberID int,
	@UserName varchar(50),
	@AllowAPIUser bit = 0
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: CL
	Checked on: 27-Jul-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@SL_ID_CIC int,
		@SL_ID_VOL int,
		@CIC_SUG bit,
		@VOL_SUG bit,
		@CIC_SU bit,
		@VOL_SU bit

SELECT TOP 1 @SL_ID_CIC=SL_ID_CIC,
		@SL_ID_VOL=SL_ID_VOL
	FROM GBL_Users u
	LEFT JOIN GBL_Users_APICreds a
		ON a.User_ID=u.User_ID
WHERE MemberID_Cache=@MemberID
	AND (UserName=@UserName OR (@AllowAPIUser=1 AND CAST(a.CredID AS nvarchar(50))=@UserName))
	AND Inactive=0
ORDER BY CASE WHEN UserName=@UserName THEN 0 ELSE 1 END

	
SELECT @CIC_SUG = SuperUserGlobal,
		@CIC_SU = SuperUser
	FROM CIC_SecurityLevel
WHERE SL_ID=@SL_ID_CIC

SELECT @VOL_SUG = SuperUserGlobal,
		@VOL_SU = SuperUser
	FROM VOL_SecurityLevel
WHERE SL_ID=@SL_ID_VOL

SELECT TOP 1 u.[User_ID], UserUID,
	UserName, FirstName, LastName, Initials, 
	Agency, Email, SavedSearchQuota,
	CASE WHEN @UserName=u.UserName THEN u.PasswordHash ELSE a.PasswordHash END AS PasswordHash,
	CASE WHEN @UserName=u.UserName THEN u.PasswordHashSalt ELSE a.PasswordHashSalt END AS PasswordHashSalt,
	CASE WHEN @UserName=u.UserName THEN u.PasswordHashRepeat ELSE a.PasswordHashRepeat END AS PasswordHashRepeat, SingleLogin, SingleLoginKey, TechAdmin,
	LoginAttempts, (SELECT ISNULL(ag.UpdateAccountEmail,ag.UpdateEmailCIC) FROM GBL_Agency ag WHERE AgencyCode=u.Agency) AS AgencyEmail,

	(CASE WHEN @CIC_SUG = 1 OR @VOL_SUG = 1 THEN 
		(SELECT COUNT(*) 
			FROM GBL_Admin_Notice an 
			INNER JOIN GBL_Admin_Area aa 
				ON an.AdminAreaID=aa.AdminAreaID 
		WHERE PROCESSED_DATE IS NULL AND ((@CIC_SUG =1 AND Domain IN (1,3,4)) OR (@VOL_SUG=1 AND Domain IN (2,4)) )) ELSE 0 END) +
	(CASE WHEN @CIC_SU = 1 OR @VOL_SU = 1 THEN
		(SELECT COUNT(*)
			FROM GBL_SharingProfile sp
			WHERE sp.ShareMemberID = u.MemberID_Cache AND sp.ReadyToAccept=1 AND ((@CIC_SU=1 AND Domain=1) OR (@VOL_SU=1 AND Domain=2))) ELSE 0 END)
		 AS NoticeCount,
	dbo.fn_GBL_Reminders(u.User_ID, @@LANGID, GETDATE()) AS Reminders
	FROM GBL_Users u
	LEFT JOIN GBL_Users_APICreds a
		ON a.User_ID=u.User_ID
WHERE MemberID_Cache=@MemberID
	AND (UserName=@UserName OR (@AllowAPIUser=1 AND CAST(a.CredID AS nvarchar(50))=@UserName))
	AND Inactive=0
ORDER BY CASE WHEN UserName=@UserName THEN 0 ELSE 1 END

SELECT sl.*, vw.PB_ID, vw.LimitedView,
	(SELECT api.Code + ',' AS [text()] 
		FROM CIC_SecurityLevel_ExternalAPI slapi
		INNER JOIN GBL_ExternalAPI api
			ON api.API_ID=slapi.API_ID
		WHERE slapi.SL_ID=sl.SL_ID
		FOR XML PATH('')) AS ExternalAPIs
	FROM CIC_SecurityLevel sl
	INNER JOIN CIC_View vw
		ON sl.ViewType = vw.ViewType
WHERE SL_ID=@SL_ID_CIC

SELECT sl.*,
	(SELECT api.Code + ',' AS [text()] 
		FROM VOL_SecurityLevel_ExternalAPI slapi
		INNER JOIN GBL_ExternalAPI api
			ON api.API_ID=slapi.API_ID
		WHERE slapi.SL_ID=sl.SL_ID
		FOR XML PATH('')) AS ExternalAPIs
	FROM VOL_SecurityLevel sl
WHERE SL_ID=@SL_ID_VOL

SET NOCOUNT OFF









GO


GRANT EXECUTE ON  [dbo].[sp_GBL_Users_s_Security] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_s_Security] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_s_Security] TO [cioc_vol_search_role]
GO
