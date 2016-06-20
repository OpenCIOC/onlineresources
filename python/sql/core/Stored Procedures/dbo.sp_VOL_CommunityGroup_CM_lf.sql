SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunityGroup_CM_lf]
	@MemberID int,
	@CommunitySetID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Jan-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT cs.CommunitySetID, SetName
	FROM VOL_CommunitySet cs
	INNER JOIN VOL_CommunitySet_Name csn
		ON cs.CommunitySetID=csn.CommunitySetID AND LangID=(SELECT TOP 1 LangID FROM VOL_CommunitySet_Name WHERE csn.CommunitySetID=CommunitySetID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE cs.MemberID=@MemberID
	AND cs.CommunitySetID=@CommunitySetID

SELECT vcgc.CG_CM_ID, vcg.CommunityGroupID, cm.CM_ID, cmn.Name AS Community
	FROM VOL_CommunityGroup_CM vcgc
	INNER JOIN GBL_Community cm
		ON vcgc.CM_ID=cm.CM_ID
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN VOL_CommunityGroup vcg
		ON vcgc.CommunityGroupID=vcg.CommunityGroupID
	INNER JOIN VOL_CommunitySet vcs
		ON vcg.CommunitySetID=vcs.CommunitySetID AND vcs.MemberID=@MemberID
WHERE vcg.CommunitySetID=@CommunitySetID
ORDER BY vcgc.DisplayOrder, cmn.Name

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_CM_lf] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_CM_lf] TO [cioc_vol_search_role]
GO
