
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMAreasServed_s]
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: CL
	Checked on: 26-Aug-2015
	Action: NO ACTION REQUIRED
*/

SELECT cm.CM_ID, cmn.Name AS Community, prn.Notes,
		CASE WHEN EXISTS(SELECT * FROM GBL_Community_Name cmn3 WHERE cmn3.CM_ID<>cm.CM_ID AND cmn.Name=cmn3.Name) AND pst.GBL_ProvinceStateCountry IS NOT NULL THEN ', ' + pst.GBL_ProvinceStateCountry ELSE '' END AS ProvinceState,
		cmn2.Name AS ParentCommunityName
	FROM GBL_Community cm
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN CIC_BT_CM pr 
		ON cm.CM_ID = pr.CM_ID AND pr.NUM=@NUM
	LEFT JOIN CIC_BT_CM_Notes prn
		ON pr.BT_CM_ID=prn.BT_CM_ID AND prn.LangID=@@LANGID
	LEFT JOIN GBL_Community cm2
		ON cm.ParentCommunity = cm2.CM_ID
	LEFT JOIN GBL_Community_Name cmn2
		ON cm2.CM_ID=cmn2.CM_ID
			AND cmn2.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm2.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN vw_GBL_ProvinceStateCountry pst
		ON cm.ProvinceState=pst.ProvID AND pst.LangID=(SELECT TOP 1 LangID FROM vw_GBL_ProvinceStateCountry WHERE ProvID=pst.ProvID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY cmn.Name

SET NOCOUNT OFF


GO



GRANT EXECUTE ON  [dbo].[sp_CIC_NUMAreasServed_s] TO [cioc_login_role]
GO
