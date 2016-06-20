
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[vw_GBL_ProvinceStateCountry]
AS
SELECT pv.ProvID, pvn.LangID, pv.NameOrCode, 
	ISNULL(pvn.Name, ISNULL(pv.NameOrCode, pv.Country))
	+ CASE WHEN COALESCE (pvn.Name, pv.NameOrCode) IS NULL
		THEN ''
		ELSE ', ' + pv.Country
	END AS GBL_ProvinceStateCountry
FROM [dbo].GBL_ProvinceState pv
LEFT JOIN [dbo].GBL_ProvinceState_Name pvn
	ON pv.ProvID = pvn.ProvID AND pvn.LangID=(SELECT TOP 1 LangID FROM [dbo].GBL_ProvinceState_Name WHERE ProvID = pvn.ProvID ORDER BY CASE WHEN LangID=@@LangID THEN 0 ELSE 1 END)




GO

GRANT SELECT ON  [dbo].[vw_GBL_ProvinceStateCountry] TO [cioc_login_role]
GO
