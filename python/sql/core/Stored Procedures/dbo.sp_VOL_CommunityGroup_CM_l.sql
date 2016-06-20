SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunityGroup_CM_l]
	@CommunitySetID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT DISTINCT vcgc.DisplayOrder, cm.CM_ID, cmn.Name AS Community
	FROM VOL_CommunityGroup_CM vcgc
	INNER JOIN VOL_CommunityGroup vcg
		ON vcgc.CommunityGroupID=vcg.CommunityGroupID
	INNER JOIN GBL_Community cm
		ON vcgc.CM_ID=cm.CM_ID
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vcg.CommunitySetID=@CommunitySetID
ORDER BY vcgc.DisplayOrder, cmn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_CM_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_CM_l] TO [cioc_vol_search_role]
GO
