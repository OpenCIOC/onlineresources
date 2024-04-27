SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_Summary] (
	@MemberID [int],
	@StartDate date,
	@EndDate date
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE 	@Error	int
SET @Error = 0

IF @StartDate IS NULL SET @StartDate = DATEADD(yy,-1,GETDATE())
IF @EndDate IS NULL SET @EndDate = DATEADD(d,1,GETDATE())

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT cm.CM_ID, cmn.Name AS Community
	FROM dbo.GBL_Community cm
	INNER JOIN dbo.GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN dbo.VOL_Profile_CM vpc
		ON cm.CM_ID=vpc.CM_ID
	INNER JOIN dbo.VOL_Profile vp
		ON vpc.ProfileID=vp.ProfileID
WHERE vp.MemberID=@MemberID
	AND EXISTS(SELECT * FROM dbo.VOL_CommunityGroup_CM cgc
		INNER JOIN dbo.VOL_CommunityGroup cg
			ON cgc.CommunityGroupID=cg.CommunityGroupID
		INNER JOIN dbo.VOL_View vw
			ON vw.CommunitySetID=cg.CommunitySetID
		WHERE vw.MemberID=@MemberID
			AND cgc.CM_ID=cm.CM_ID
			AND vw.UseProfilesView=1)
	AND (vp.OrgCanContact=1 AND vp.Verified=1)
GROUP BY cm.CM_ID, cmn.Name
ORDER BY cmn.Name

SELECT ai.AI_ID, CASE WHEN ain.LangID=@@LANGID THEN ain.Name ELSE '[' + ain.Name + ']' END AS InterestName
	FROM dbo.VOL_Interest ai
	INNER JOIN dbo.VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID AND ain.LangID=(SELECT TOP 1 LangID FROM dbo.VOL_Interest_Name WHERE AI_ID=ai.AI_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN dbo.VOL_Profile_AI pai
		ON ai.AI_ID = pai.AI_ID
	INNER JOIN dbo.VOL_Profile vp
		ON pai.ProfileID=vp.ProfileID
WHERE vp.MemberID=@MemberID
	AND (vp.OrgCanContact=1 AND vp.Verified=1)
GROUP BY ai.AI_ID, ain.Name, ain.LangID
ORDER BY ain.Name

DECLARE @DefaultViewVOL int

SELECT @DefaultViewVOL = DefaultViewVOL
	FROM dbo.STP_Member
WHERE MemberID=@MemberID

SELECT	vw.ViewType,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName
	FROM dbo.VOL_View vw
	INNER JOIN dbo.VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM dbo.VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vw.MemberID=@MemberID
	AND vw.UseProfilesView=1
	AND (
		vw.ViewType=@DefaultViewVOL
		OR EXISTS(SELECT * FROM dbo.VOL_View_Recurse WHERE ViewType=@DefaultViewVOL AND CanSee=vw.ViewType)
	)
ORDER BY vwd.ViewName

SELECT	COUNT(*) AS TOTAL,
		SUM(CAST(Active AS int)) AS ACTIVE,
		SUM(CAST(Verified AS int)) AS VERIFIED,
		SUM(CAST(NotifyNew AS int)) AS NOTIFY_NEW,
		SUM(CAST(NotifyUpdated AS int)) AS NOTIFY_UPDATED,
		SUM(CAST(OrgCanContact AS int)) AS CAN_CONTACT,
		SUM(CAST(AgreedToPrivacyPolicy AS int)) AS AGREED_PRIVACY,
		SUM(CASE WHEN ISNULL(vp.MODIFIED_DATE,vp.CREATED_DATE) BETWEEN @StartDate AND @EndDate THEN 1 ELSE 0 END) AS TOTAL_YR,
		SUM(CASE WHEN ISNULL(vp.MODIFIED_DATE,vp.CREATED_DATE) BETWEEN @StartDate AND @EndDate THEN CAST(vp.Active AS int) ELSE 0 END) AS ACTIVE_YR,
		SUM(CASE WHEN ISNULL(vp.MODIFIED_DATE,vp.CREATED_DATE) BETWEEN @StartDate AND @EndDate THEN CAST(vp.Verified AS int) ELSE 0 END) AS VERIFIED_YR,
		SUM(CASE WHEN ISNULL(vp.MODIFIED_DATE,vp.CREATED_DATE) BETWEEN @StartDate AND @EndDate THEN CAST(vp.NotifyNew AS int) ELSE 0 END) AS NOTIFY_NEW_YR,
		SUM(CASE WHEN ISNULL(vp.MODIFIED_DATE,vp.CREATED_DATE) BETWEEN @StartDate AND @EndDate THEN CAST(vp.NotifyUpdated AS int) ELSE 0 END) AS NOTIFY_UPDATED_YR,
		SUM(CASE WHEN ISNULL(vp.MODIFIED_DATE,vp.CREATED_DATE) BETWEEN @StartDate AND @EndDate THEN CAST(vp.OrgCanContact AS int) ELSE 0 END) AS CAN_CONTACT_YR,
		SUM(CASE WHEN ISNULL(vp.MODIFIED_DATE,vp.CREATED_DATE) BETWEEN @StartDate AND @EndDate THEN CAST(vp.AgreedToPrivacyPolicy AS int) ELSE 0 END) AS AGREED_PRIVACY_YR
FROM dbo.VOL_Profile vp
WHERE MemberID=@MemberID

SELECT *
FROM   
(SELECT MONTH(vp.CREATED_DATE) AS CREATED_MONTH, CAST(YEAR(vp.CREATED_DATE) AS varchar) AS CREATED_YEAR, vp.ProfileID
	FROM dbo.VOL_Profile vp
	WHERE vp.MemberID=@MemberID) p
PIVOT  
(  
COUNT (ProfileID)  
FOR CREATED_MONTH IN  
( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])  
) AS pvt  
ORDER BY CREATED_YEAR DESC;  

SELECT *
FROM   
(SELECT MONTH(vp.MODIFIED_DATE) AS MODIFIED_MONTH, CAST(YEAR(vp.MODIFIED_DATE) AS varchar) AS MODIFIED_YEAR, vp.ProfileID
	FROM dbo.VOL_Profile vp
	WHERE vp.MemberID=@MemberID) p  
PIVOT  
(  
COUNT (ProfileID)  
FOR MODIFIED_MONTH IN  
( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])  
) AS pvt  
ORDER BY MODIFIED_YEAR DESC; 

SELECT *
FROM   
(SELECT MONTH(rf.ReferralDate) AS PROFILE_REFERRAL_MONTH, CAST(YEAR(rf.ReferralDate) AS varchar) AS PROFILE_REFERRAL_YEAR, rf.REF_ID
	FROM dbo.VOL_Profile vp
	INNER JOIN dbo.VOL_OP_Referral rf
		ON vp.ProfileID=rf.ProfileID
	WHERE vp.MemberID=@MemberID
	) p  
PIVOT  
(  
COUNT (REF_ID) 
FOR PROFILE_REFERRAL_MONTH IN  
( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])  
) AS pvt  
ORDER BY pvt.PROFILE_REFERRAL_YEAR DESC;

SELECT *
FROM   
(SELECT DISTINCT MONTH(rf.ReferralDate) AS REFERRAL_P_MONTH, CAST(YEAR(rf.ReferralDate) AS varchar) AS REFERRAL_P_YEAR, vp.ProfileID
	FROM dbo.VOL_Profile vp
	INNER JOIN dbo.VOL_OP_Referral rf
		ON vp.ProfileID=rf.ProfileID
	WHERE vp.MemberID=@MemberID
	) p  
PIVOT  
(  
COUNT (ProfileID) 
FOR REFERRAL_P_MONTH IN  
( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])  
) AS pvt  
ORDER BY pvt.REFERRAL_P_YEAR DESC;

SELECT *
FROM   
(SELECT DISTINCT MONTH(rf.ReferralDate) AS REFERRAL_NP_MONTH, CAST(YEAR(rf.ReferralDate) AS varchar) AS REFERRAL_NP_YEAR, rf.REF_ID
	FROM dbo.VOL_OP_Referral rf
	WHERE rf.ProfileID IS NULL
		AND rf.MemberID=@MemberID
	) p  
PIVOT  
(  
COUNT (REF_ID) 
FOR REFERRAL_NP_MONTH IN  
( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])  
) AS pvt  
ORDER BY pvt.REFERRAL_NP_YEAR DESC; 

SELECT AGE_GROUP, COUNT(*) AS TOTAL, SUM(CASE WHEN ISNULL(ag.MODIFIED_DATE,ag.CREATED_DATE) BETWEEN @StartDate AND @EndDate THEN 1 ELSE 0 END) AS THIS_YEAR
	FROM (SELECT CASE
			WHEN BirthDate IS NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Not Specified')
			WHEN DATEDIFF(yy,BirthDate,GETDATE()) <= 12 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Children (12 and under)')
			WHEN DATEDIFF(yy,BirthDate,GETDATE()) <= 17 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Youth (13-17)')
			WHEN DATEDIFF(yy,BirthDate,GETDATE()) <= 25 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Young Adults (18-25)')
			WHEN DATEDIFF(yy,BirthDate,GETDATE()) <= 59 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Adults (26-59)')
			ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Older Adults (60+)')
		END AS AGE_GROUP,
		vp.MODIFIED_DATE, vp.CREATED_DATE
	FROM dbo.VOL_Profile vp
	WHERE MemberID=@MemberID) ag
GROUP BY AGE_GROUP
ORDER BY COUNT(*) DESC

SELECT COUNT(*) AS NO_COMMUNITIES_SPECIFIED
	FROM dbo.VOL_Profile vp
WHERE MemberID=@MemberID
	AND NOT EXISTS(SELECT * FROM dbo.VOL_Profile_CM cm WHERE vp.ProfileID=cm.ProfileID)

SELECT cmn.Name AS Community, COUNT(*) AS TOTAL
	FROM dbo.VOL_Profile vp
	INNER JOIN dbo.VOL_Profile_CM pcm
		ON pcm.ProfileID = vp.ProfileID
	INNER JOIN dbo.GBL_Community cm
		ON pcm.CM_ID=cm.CM_ID
	INNER JOIN dbo.GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vp.MemberID=@MemberID
GROUP BY cmn.Name
ORDER BY COUNT(*) DESC

SELECT cmn.Name AS Community, COUNT(*) AS THIS_YEAR
	FROM dbo.VOL_Profile vp
	INNER JOIN dbo.VOL_Profile_CM pcm
		ON pcm.ProfileID = vp.ProfileID
	INNER JOIN dbo.GBL_Community cm
		ON pcm.CM_ID=cm.CM_ID
	INNER JOIN dbo.GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vp.MemberID=@MemberID
	AND ISNULL(vp.MODIFIED_DATE, vp.CREATED_DATE) BETWEEN @StartDate AND @EndDate
GROUP BY cmn.Name
ORDER BY COUNT(*) DESC

SELECT COUNT(*) AS NO_INTERESTS_SPECIFIED
	FROM dbo.VOL_Profile vp
WHERE MemberID=@MemberID
	AND NOT EXISTS(SELECT * FROM dbo.VOL_Profile_AI ai WHERE vp.ProfileID=ai.ProfileID)

SELECT CASE WHEN ain.LangID=@@LANGID THEN ain.Name ELSE '[' + ain.Name + ']' END AS InterestName, COUNT(*) AS TOTAL
	FROM dbo.VOL_Profile vp
	INNER JOIN dbo.VOL_Profile_AI pai
		ON vp.ProfileID=pai.ProfileID
	INNER JOIN dbo.VOL_Interest ai
		ON pai.AI_ID=ai.AI_ID
	INNER JOIN dbo.VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID AND ain.LangID=(SELECT TOP 1 LangID FROM dbo.VOL_Interest_Name WHERE AI_ID=ai.AI_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vp.MemberID=@MemberID
GROUP BY ain.Name, ain.LangID
ORDER BY COUNT(*) DESC

SELECT CASE WHEN ain.LangID=@@LANGID THEN ain.Name ELSE '[' + ain.Name + ']' END AS InterestName, COUNT(*) AS THIS_YEAR
	FROM dbo.VOL_Profile vp
	INNER JOIN dbo.VOL_Profile_AI pai
		ON vp.ProfileID=pai.ProfileID
	INNER JOIN dbo.VOL_Interest ai
		ON pai.AI_ID=ai.AI_ID
	INNER JOIN dbo.VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID AND ain.LangID=(SELECT TOP 1 LangID FROM dbo.VOL_Interest_Name WHERE AI_ID=ai.AI_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vp.MemberID=@MemberID
	AND ISNULL(vp.MODIFIED_DATE, vp.CREATED_DATE) BETWEEN @StartDate AND @EndDate
GROUP BY ain.Name, ain.LangID
ORDER BY COUNT(*) DESC

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_Summary] TO [cioc_login_role]
GO
