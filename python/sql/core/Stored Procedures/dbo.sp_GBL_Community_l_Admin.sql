SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Community_l_Admin] 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SELECT cm.CM_ID,
		cmn.Name
			+ CASE WHEN EXISTS(SELECT * FROM dbo.GBL_Community_Name cmn3 WHERE cmn3.CM_ID<>cm.CM_ID AND cmn.Name=cmn3.Name) AND pst.GBL_ProvinceStateCountry IS NOT NULL THEN ', ' + pst.GBL_ProvinceStateCountry ELSE '' END AS Community,
		cmn2.Name AS ParentCommunity,
		cmn3.Name AS ParentCommunity2,
		ISNULL(cmtn.Name,cm.PrimaryAreaType) AS PrimaryAreaType,
		cm.Authorized
	FROM dbo.GBL_Community cm
	INNER JOIN dbo.GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.vw_GBL_ProvinceStateCountry pst
		ON cm.ProvinceState=pst.ProvID AND pst.LangID=(SELECT TOP 1 LangID FROM dbo.vw_GBL_ProvinceStateCountry WHERE ProvID=pst.ProvID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.GBL_Community cm2
		ON cm2.CM_ID = cm.ParentCommunity
	LEFT JOIN dbo.GBL_Community_Name cmn2
		ON cmn2.CM_ID=cm2.CM_ID AND cmn2.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn2.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.GBL_Community_Name cmn3
		ON cmn3.CM_ID=cm2.ParentCommunity AND cmn3.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn3.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.GBL_Community_Type_Name cmtn
		ON cm.PrimaryAreaType=cmtn.Code AND cmtn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Type_Name WHERE Code=cmtn.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE cm.AlternativeArea=0
ORDER BY cmn.Name

SELECT cm.CM_ID,
		cmn.Name
			+ CASE WHEN EXISTS(SELECT * FROM dbo.GBL_Community_Name cmn3 WHERE cmn3.CM_ID<>cm.CM_ID AND cmn.Name=cmn3.Name) AND pst.GBL_ProvinceStateCountry IS NOT NULL THEN ', ' + pst.GBL_ProvinceStateCountry ELSE '' END AS Community,
		cmn2.Name AS ParentCommunity,
		cm.Authorized
	FROM dbo.GBL_Community cm
	INNER JOIN dbo.GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.vw_GBL_ProvinceStateCountry pst
		ON cm.ProvinceState=pst.ProvID AND pst.LangID=(SELECT TOP 1 LangID FROM dbo.vw_GBL_ProvinceStateCountry WHERE ProvID=pst.ProvID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.GBL_Community_Name cmn2
		ON cmn2.CM_ID=cm.ParentCommunity AND cmn2.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn2.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE cm.AlternativeArea=1
ORDER BY cmn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_l_Admin] TO [cioc_login_role]
GO
