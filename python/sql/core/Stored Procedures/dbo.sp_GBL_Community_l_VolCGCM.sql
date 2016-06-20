SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Community_l_VolCGCM]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Apr-2012
	Action: NO ACTION REQUIRED
*/

SELECT cm.CM_ID,
		cmn.Name
			+ CASE WHEN EXISTS(SELECT * FROM GBL_Community_Name cmn3 WHERE cmn3.CM_ID<>cm.CM_ID AND cmn.Name=cmn3.Name) AND pst.GBL_ProvinceStateCountry IS NOT NULL THEN ', ' + pst.GBL_ProvinceStateCountry ELSE '' END AS Community,
		dbo.fn_GBL_Community_s_Search(cm.CM_ID) AS SEARCH_CM_ID
	FROM GBL_Community cm
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN vw_GBL_ProvinceStateCountry pst
		ON cm.ProvinceState=pst.ProvID AND pst.LangID=(SELECT TOP 1 LangID FROM vw_GBL_ProvinceStateCountry WHERE ProvID=pst.ProvID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE EXISTS(SELECT *
			FROM VOL_CommunityGroup_CM vcgc
			INNER JOIN VOL_CommunityGroup vcg
				ON vcgc.CommunityGroupID=vcg.CommunityGroupID
			INNER JOIN VOL_CommunitySet cs
				ON vcg.CommunitySetID=cs.CommunitySetID AND cs.MemberID=@MemberID
		WHERE vcgc.CM_ID=cm.CM_ID
	)
ORDER BY cmn.Name

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_l_VolCGCM] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_l_VolCGCM] TO [cioc_vol_search_role]
GO
