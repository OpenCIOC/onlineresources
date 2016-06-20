SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Community_ls]
	@searchStr nvarchar(100)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT DISTINCT cmn.CM_ID,
		cmn.Name AS Community,
		cmn.Name
			+ CASE WHEN cmn.Name LIKE '%' + @searchStr + '%' THEN '' ELSE ' [' + anm.AltName + ']' END
			+ CASE WHEN EXISTS(SELECT * FROM GBL_Community_Name cmn3 WHERE cmn3.CM_ID<>cm.CM_ID AND cmn.Name=cmn3.Name) AND pst.GBL_ProvinceStateCountry IS NOT NULL THEN ', ' + pst.GBL_ProvinceStateCountry ELSE '' END AS Display,
		cmn2.Name AS ParentCommunityName
	FROM GBL_Community cm
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_Community cm2
		ON cm.ParentCommunity = cm2.CM_ID
	LEFT JOIN GBL_Community_Name cmn2
		ON cm2.CM_ID=cmn2.CM_ID
			AND cmn2.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm2.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_Community_AltName anm
		ON cm.CM_ID=anm.CM_ID AND anm.LangID=@@LANGID
	LEFT JOIN vw_GBL_ProvinceStateCountry pst
		ON cm.ProvinceState=pst.ProvID AND pst.LangID=(SELECT TOP 1 LangID FROM vw_GBL_ProvinceStateCountry WHERE ProvID=pst.ProvID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE cmn.Name LIKE '%' + @searchStr + '%'
	OR anm.AltName LIKE '%' + @searchStr + '%'
ORDER BY Display

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_ls] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_ls] TO [cioc_login_role]
GO
