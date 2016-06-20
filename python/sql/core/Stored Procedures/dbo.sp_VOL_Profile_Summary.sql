
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_Summary] (
	@MemberID [int]
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.2
	Checked by: KL
	Checked on: 02-Mar-2015
	Action:	NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT cm.CM_ID, cmn.Name AS Community
	FROM GBL_Community cm
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN VOL_Profile_CM vpc
		ON cm.CM_ID=vpc.CM_ID
	INNER JOIN VOL_Profile vp
		ON vpc.ProfileID=vp.ProfileID
WHERE vp.MemberID=@MemberID
	AND EXISTS(SELECT * FROM VOL_CommunityGroup_CM cgc
		INNER JOIN VOL_CommunityGroup cg
			ON cgc.CommunityGroupID=cg.CommunityGroupID
		INNER JOIN VOL_View vw
			ON vw.CommunitySetID=cg.CommunitySetID
		WHERE vw.MemberID=@MemberID
			AND cgc.CM_ID=cm.CM_ID
			AND vw.UseProfilesView=1)
	AND (vp.OrgCanContact=1 AND vp.Verified=1)
GROUP BY cm.CM_ID, cmn.Name
ORDER BY cmn.Name

SELECT ai.AI_ID, CASE WHEN ain.LangID=@@LANGID THEN ain.Name ELSE '[' + ain.Name + ']' END AS InterestName
	FROM VOL_Interest ai
	INNER JOIN VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID AND ain.LangID=(SELECT TOP 1 LangID FROM VOL_Interest_Name WHERE AI_ID=ai.AI_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN VOL_Profile_AI pai
		ON ai.AI_ID = pai.AI_ID
	INNER JOIN VOL_Profile vp
		ON pai.ProfileID=vp.ProfileID
WHERE vp.MemberID=@MemberID
	AND (vp.OrgCanContact=1 AND vp.Verified=1)
GROUP BY ai.AI_ID, ain.Name, ain.LangID
ORDER BY ain.Name

DECLARE @DefaultViewVOL int

SELECT @DefaultViewVOL = DefaultViewVOL
	FROM STP_Member
WHERE MemberID=@MemberID

SELECT	vw.ViewType,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName
	FROM VOL_View vw
	INNER JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vw.MemberID=@MemberID
	AND UseProfilesView=1
	AND (
		vw.ViewType=@DefaultViewVOL
		OR EXISTS(SELECT * FROM VOL_View_Recurse WHERE ViewType=@DefaultViewVOL AND CanSee=vw.ViewType)
	)
ORDER BY vwd.ViewName

SELECT	COUNT(*) AS TOTAL,
		COUNT(CAST(Active AS int)) AS ACTIVE,
		SUM(CAST(Verified AS int)) AS VERIFIED,
		SUM(CAST(NotifyNew AS int)) AS NOTIFY_NEW,
		SUM(CAST(NotifyUpdated AS int)) AS NOTIFY_UPDATED,
		SUM(CAST(OrgCanContact AS int)) AS CAN_CONTACT,
		SUM(CAST(AgreedToPrivacyPolicy AS int)) AS AGREED_PRIVACY
FROM VOL_Profile vp
WHERE MemberID=@MemberID

SELECT CREATED_MONTH = DATENAME(m, CREATED_DATE) + ' ' + CAST(YEAR(CREATED_DATE) AS varchar), COUNT(*) AS TOTAL
	FROM VOL_Profile vp
WHERE MemberID=@MemberID
GROUP BY YEAR(CREATED_DATE), MONTH(CREATED_DATE), DATENAME(m, CREATED_DATE)
ORDER BY YEAR(CREATED_DATE) DESC, MONTH(CREATED_DATE) DESC

SELECT LAST_MODIFIED = DATENAME(m, MODIFIED_DATE) + ' ' + CAST(YEAR(MODIFIED_DATE) AS varchar), COUNT(*) AS TOTAL
	FROM VOL_Profile vp
WHERE MemberID=@MemberID
GROUP BY YEAR(MODIFIED_DATE), MONTH(MODIFIED_DATE), DATENAME(m, MODIFIED_DATE)
ORDER BY YEAR(MODIFIED_DATE) DESC, MONTH(MODIFIED_DATE) DESC

SELECT APPLICATION_DATE, COUNT(*) AS TOTAL_PROFILES, SUM(TOTAL) AS TOTAL_APPLICATIONS
FROM (SELECT YEAR(rf.CREATED_DATE) AS APP_YEAR, MONTH(rf.CREATED_DATE) AS APP_MONTH, APPLICATION_DATE = DATENAME(m, rf.CREATED_DATE) + ' ' + CAST(YEAR(rf.CREATED_DATE) AS varchar), COUNT(*) AS TOTAL
	FROM VOL_Profile vp
	INNER JOIN VOL_OP_Referral rf
		ON vp.ProfileID=rf.ProfileID
WHERE vp.MemberID=@MemberID
GROUP BY YEAR(rf.CREATED_DATE), MONTH(rf.CREATED_DATE), DATENAME(m, rf.CREATED_DATE), vp.ProfileID) x
GROUP BY APPLICATION_DATE, APP_MONTH, APP_YEAR
ORDER BY APP_YEAR DESC, APP_MONTH DESC

SELECT AGE_GROUP, COUNT(*) AS TOTAL
	FROM (SELECT CASE
			WHEN BirthDate IS NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Not Specified')
			WHEN DATEDIFF(yy,BirthDate,GETDATE()) <= 12 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Children (12 and under)')
			WHEN DATEDIFF(yy,BirthDate,GETDATE()) <= 17 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Youth (13-17)')
			WHEN DATEDIFF(yy,BirthDate,GETDATE()) <= 25 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Young Adults (18-25)')
			WHEN DATEDIFF(yy,BirthDate,GETDATE()) <= 59 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Adults (26-59)')
			ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Older Adults (60+)')
		END AS AGE_GROUP
	FROM VOL_Profile vp
	WHERE MemberID=@MemberID) ag
GROUP BY AGE_GROUP
ORDER BY COUNT(*) DESC

SELECT COUNT(*) AS NO_COMMUNITIES_SPECIFIED
	FROM VOL_Profile vp
WHERE MemberID=@MemberID
	AND NOT EXISTS(SELECT * FROM VOL_Profile_CM cm WHERE vp.ProfileID=cm.ProfileID)

SELECT cmn.Name AS Community, COUNT(*) AS TOTAL
	FROM dbo.VOL_Profile vp
	INNER JOIN VOL_Profile_CM pcm
		ON pcm.ProfileID = vp.ProfileID
	INNER JOIN GBL_Community cm
		ON pcm.CM_ID=cm.CM_ID
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE MemberID=@MemberID
GROUP BY cmn.Name
ORDER BY COUNT(*) DESC

SELECT COUNT(*) AS NO_INTERESTS_SPECIFIED
	FROM VOL_Profile vp
WHERE MemberID=@MemberID
	AND NOT EXISTS(SELECT * FROM VOL_Profile_AI ai WHERE vp.ProfileID=ai.ProfileID)

SELECT TOP 25 CASE WHEN ain.LangID=@@LANGID THEN ain.Name ELSE '[' + ain.Name + ']' END AS InterestName, COUNT(*) AS TOTAL
	FROM VOL_Profile vp
	INNER JOIN VOL_Profile_AI pai
		ON vp.ProfileID=pai.ProfileID
	INNER JOIN VOL_Interest ai
		ON pai.AI_ID=ai.AI_ID
	INNER JOIN VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID AND ain.LangID=(SELECT TOP 1 LangID FROM VOL_Interest_Name WHERE AI_ID=ai.AI_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vp.MemberID=@MemberID
GROUP BY ain.Name, ain.LangID
ORDER BY COUNT(*) DESC

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_Summary] TO [cioc_login_role]
GO
