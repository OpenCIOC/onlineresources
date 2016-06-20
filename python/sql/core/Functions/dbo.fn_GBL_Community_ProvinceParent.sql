SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GBL_Community_ProvinceParent](
	@CM_ID int
)
RETURNS nvarchar(500) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6.3
	Checked by: CL
	Checked on: 02-Jun-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(500)

SELECT @returnStr=
		CASE WHEN EXISTS(SELECT * FROM GBL_Community_Name cmn3 WHERE cmn3.CM_ID<>cm.CM_ID AND cmn.Name=cmn3.Name) AND pst.GBL_ProvinceStateCountry IS NOT NULL THEN ', ' + pst.GBL_ProvinceStateCountry ELSE '' END
		+ CASE WHEN cmn2.Name IS NOT NULL THEN ' (' + cioc_shared.dbo.fn_SHR_STP_ObjectName('in') + ' ' + cmn2.Name + ')' ELSE '' END 
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
WHERE cm.CM_ID=@CM_ID
ORDER BY cmn.Name

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_Community_ProvinceParent] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_Community_ProvinceParent] TO [cioc_login_role]
GO
