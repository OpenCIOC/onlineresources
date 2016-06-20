
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Community_l_Print]
	@CM_ID int = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.3
	Checked by: KL
	Checked on: 21-Nov-2014
	Action: NO ACTION REQUIRED
*/

SELECT 
	cm.*, 
	(SELECT cmn.Name
	 FROM GBL_Community_Name cmn
	 WHERE CM_ID=ParentCommunity AND 
		LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID 
				ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			) AS ParentCommunityName,
	(SELECT Name 
	 FROM GBL_Community pcm 
	 INNER JOIN dbo.GBL_Community_Name pcmn
		ON pcm.ParentCommunity=pcmn.CM_ID
	 WHERE pcm.CM_ID=cm.ParentCommunity AND pcmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=pcmn.CM_ID 
				ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			) AS ParentCommunity2,
	(SELECT COUNT(*) FROM GBL_Community WHERE ParentCommunity=cm.CM_ID) AS ParentUsage,
	(SELECT COUNT(*) FROM GBL_BaseTable WHERE LOCATED_IN_CM=cm.CM_ID) AS LocatedInUsage,
	(SELECT COUNT(*) FROM CIC_BT_CM WHERE CM_ID=cm.CM_ID) AS AreasServedUsage,
	(SELECT COUNT(*) FROM VOL_OP_CM WHERE CM_ID=cm.CM_ID) AS VolOppUsage,
	(SELECT COUNT(*) FROM CIC_BusRoute WHERE Municipality=cm.CM_ID) AS BusRouteUsage,
	(SELECT COUNT(*) FROM CIC_Ward WHERE Municipality=cm.CM_ID) AS WardUsage,
	(SELECT COUNT(*) FROM CIC_View_Community WHERE CM_ID=cm.CM_ID) AS ViewUsage,
	(SELECT COUNT(*) FROM VOL_CommunityGroup_CM WHERE CM_ID=cm.CM_ID) AS CommunityGroupUsage,
	(SELECT TOP 1 Name FROM GBL_ProvinceState_Name WHERE ProvID=cm.ProvinceState ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS ProvinceName,
	(SELECT cmn.*,
			(SELECT Culture FROM STP_Language WHERE LangID=cmn.LangID) AS Culture
			 FROM GBL_Community_Name cmn
			 WHERE CM_ID=cm.CM_ID FOR XML PATH('Name'), ROOT('Names'), ELEMENTS, TYPE) AS Names,
	(SELECT DISTINCT an.AltName
		FROM GBL_Community_AltName an
		WHERE CM_ID=cm.CM_ID
		ORDER BY AltName FOR XML PATH(''), ROOT('AltNames'), ELEMENTS, TYPE) AS AltNames,
	(SELECT cmn.Name 
		FROM GBL_Community_AltAreaSearch aas
		INNER JOIN GBL_Community_Name cmn
			ON cmn.CM_ID=aas.Search_CM_ID
				AND LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		WHERE aas.CM_ID=cm.CM_ID
		ORDER BY cmn.Name FOR XML PATH(''), ROOT('SearchAreas'), ELEMENTS, TYPE) AS AltAreaSearch
	FROM GBL_Community cm
	WHERE @CM_ID IS NULL OR EXISTS(SELECT * FROM GBL_Community_ParentList pl WHERE pl.CM_ID=cm.CM_ID AND pl.Parent_CM_ID=@CM_ID)
ORDER BY (SELECT COUNT(*) FROM dbo.GBL_Community_ParentList WHERE CM_ID=cm.CM_ID) ASC,
	(SELECT Name 
	 FROM GBL_Community pcm
	 INNER JOIN dbo.GBL_Community_Name pcmn ON pcm.ParentCommunity=pcmn.CM_ID
	 WHERE pcm.CM_ID=cm.ParentCommunity AND pcmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=pcmn.CM_ID 
				ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)),
	 (SELECT cmn.Name
	 FROM GBL_Community_Name cmn
	 WHERE CM_ID=ParentCommunity AND 
		LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID 
				ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)),
	(SELECT cmn.Name
	 FROM GBL_Community_Name cmn
	 WHERE CM_ID=cm.CM_ID AND 
		LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID 
				ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID))

SET NOCOUNT OFF

GO



GRANT EXECUTE ON  [dbo].[sp_GBL_Community_l_Print] TO [cioc_login_role]
GO
