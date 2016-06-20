SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_GetInvolvedAPI_s]
	@MemberID int,
	@AllData bit = 1
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 26-Jun-2012
	Action: NO ACTION REQUIRED
*/

SELECT cs.CommunitySetID, csn.Setname
FROM VOL_CommunitySet cs
INNER JOIN VOL_CommunitySet_Name csn
	ON cs.CommunitySetID=csn.CommunitySetID AND csn.LangID=(SELECT TOP 1 LangID FROM VOL_CommunitySet_Name WHERE CommunitySetID=csn.CommunitySetID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE cs.MemberID = @MemberID
ORDER BY csn.SetName

SELECT ign.Name AS InterestGroup, ai.AI_ID, ain.Name AS InterestName 
FROM VOL_Interest ai
INNER JOIN VOL_Interest_Name ain
	ON ai.AI_ID=ain.AI_ID AND ain.LangID = (SELECT TOP 1 LangID FROM VOL_Interest_Name WHERE AI_ID=ain.AI_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
INNER JOIN VOL_AI_IG aiig
	ON ai.AI_ID=aiig.AI_ID
INNER JOIN VOL_InterestGroup ig
	ON aiig.IG_ID=ig.IG_ID
INNER JOIN VOL_InterestGroup_Name ign
	ON ign.IG_ID=ig.IG_ID AND ign.LangID = (SELECT TOP 1 LangID FROM VOL_InterestGroup_Name WHERE IG_ID=ign.IG_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY ig.DisplayOrder, ign.Name, ain.Name

SELECT sk.SK_ID, skn.Name
FROM VOL_Skill sk
INNER JOIN VOL_Skill_Name skn
	ON sk.SK_ID=skn.SK_ID AND skn.LangID=(SELECT TOP 1 LangID FROM VOL_Skill_Name WHERE SK_ID=skn.SK_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	
SELECT GIInterestGroup, GIInterestID, GIInterestName
FROM VOL_GetInvolved_Interest
ORDER BY GIInterestGroup, GIInterestName 

SELECT GISkillID, GISkillName
FROM VOL_GetInvolved_Skill
ORDER BY GISkillName

IF @AllData = 1 BEGIN

SELECT AgencyCode, GetInvolvedUser, GetInvolvedToken, GetInvolvedCommunitySet, GetInvolvedSite
FROM GBL_Agency
WHERE RecordOwnerVOL=1 AND MemberID=@MemberID

SELECT *
FROM VOL_Interest_GetInvolved_Map

SELECT * 
FROM VOL_Skill_GetInvolved_Map

END



SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_VOL_GetInvolvedAPI_s] TO [cioc_login_role]
GO
