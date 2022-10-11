SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMNumNeeded_s]
	@VNUM varchar(10),
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

IF @VNUM IS NOT NULL BEGIN
	SELECT cm.CM_ID, cmn.Name AS Community, pr.OP_CM_ID, pr.NUM_NEEDED
		FROM dbo.GBL_Community cm
		INNER JOIN dbo.GBL_Community_Name cmn
			ON cm.CM_ID=cmn.CM_ID
				AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		LEFT JOIN dbo.VOL_OP_CM pr
			ON cm.CM_ID=pr.CM_ID AND pr.VNUM=@VNUM
		WHERE pr.CM_ID IS NOT NULL
			OR EXISTS(SELECT * FROM dbo.VOL_View vw
				INNER JOIN dbo.VOL_CommunitySet vcs
					ON vw.CommunitySetID=vcs.CommunitySetID
				INNER JOIN dbo.VOL_CommunityGroup vcg
					ON vcs.CommunitySetID=vcg.CommunitySetID
				INNER JOIN dbo.VOL_CommunityGroup_CM vcgc
					ON vcg.CommunityGroupID=vcgc.CommunityGroupID
				WHERE vw.ViewType=@ViewType AND vcgc.CM_ID=cm.CM_ID)
	ORDER BY CASE WHEN pr.OP_CM_ID IS NOT NULL THEN 0 ELSE 1 END, cmn.Name
END ELSE BEGIN
	SELECT cm.CM_ID, cmn.Name AS Community, NULL AS OP_CM_ID, NULL AS NUM_NEEDED
		FROM dbo.GBL_Community cm
		INNER JOIN dbo.GBL_Community_Name cmn
			ON cm.CM_ID=cmn.CM_ID
				AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		WHERE EXISTS(SELECT * FROM dbo.VOL_View vw
				INNER JOIN dbo.VOL_CommunitySet vcs
					ON vw.CommunitySetID=vcs.CommunitySetID
				INNER JOIN dbo.VOL_CommunityGroup vcg
					ON vcs.CommunitySetID=vcg.CommunitySetID
				INNER JOIN dbo.VOL_CommunityGroup_CM vcgc
					ON vcg.CommunityGroupID=vcgc.CommunityGroupID
				WHERE vw.ViewType=@ViewType AND vcgc.CM_ID=cm.CM_ID)
	ORDER BY cmn.Name
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMNumNeeded_s] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMNumNeeded_s] TO [cioc_vol_search_role]
GO
