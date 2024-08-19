SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Community_s]
	@CM_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SELECT cm.*, 
		(SELECT cmn.Name
		 FROM dbo.GBL_Community_Name cmn
		 WHERE CM_ID=ParentCommunity AND 
			LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID 
					ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
				) AS ParentCommunityName,
		(SELECT cmn.CM_ID, cmn.Name
			FROM dbo.GBL_Community_AltAreaSearch cm2
			INNER JOIN dbo.GBL_Community_Name cmn
				ON cm2.CM_ID=cmn.CM_ID AND LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			WHERE cm2.Search_CM_ID=@CM_ID
			FOR XML AUTO, TYPE) AS AltSearchArea,
	(SELECT COUNT(*) FROM dbo.GBL_Community WHERE ParentCommunity=@CM_ID) AS ParentUsage,
	(SELECT COUNT(*) FROM dbo.GBL_BaseTable WHERE LOCATED_IN_CM=@CM_ID) AS LocatedInUsage,
	(SELECT COUNT(*) FROM dbo.CIC_BT_CM WHERE CM_ID=@CM_ID) AS AreasServedUsage,
	(SELECT COUNT(*) FROM dbo.VOL_OP_CM WHERE CM_ID=@CM_ID) AS VolOppUsage,
	(SELECT COUNT(*) FROM dbo.CIC_BusRoute WHERE Municipality=@CM_ID) AS BusRouteUsage,
	(SELECT COUNT(*) FROM dbo.CIC_Ward WHERE Municipality=@CM_ID) AS WardUsage,
	(SELECT COUNT(*) FROM dbo.CIC_View_Community WHERE CM_ID=@CM_ID) AS ViewUsage,
	(SELECT COUNT(*) FROM dbo.VOL_CommunityGroup_CM WHERE CM_ID=@CM_ID) AS CommunityGroupUsage,
	CAST(CASE WHEN EXISTS(
			SELECT * FROM dbo.STP_Member mem
			WHERE NOT EXISTS(
				SELECT *
					FROM dbo.GBL_FieldOption_InactiveByMember fi
					INNER JOIN dbo.GBL_FieldOption fo
						ON fi.FieldID=fo.FieldID AND fo.FieldName='BUS_ROUTES'
				WHERE fi.MemberID=mem.MemberID
			)
		) THEN 1 ELSE 0 END AS bit) AS UsesBusRoutes,
	CAST(CASE WHEN EXISTS(
			SELECT * FROM dbo.STP_Member mem
			WHERE NOT EXISTS(
				SELECT *
					FROM dbo.GBL_FieldOption_InactiveByMember fi
					INNER JOIN dbo.GBL_FieldOption fo
						ON fi.FieldID=fo.FieldID AND fo.FieldName='WARD'
				WHERE fi.MemberID=mem.MemberID
			)
		) THEN 1 ELSE 0 END AS bit) AS UsesWards
	FROM dbo.GBL_Community cm
WHERE CM_ID=@CM_ID

SELECT cmn.*,
		(SELECT Culture FROM STP_Language WHERE LangID=cmn.LangID) AS Culture
	FROM dbo.GBL_Community_Name cmn
WHERE CM_ID=@CM_ID

SELECT an.*, l.Culture
	FROM dbo.GBL_Community_AltName an
	INNER JOIN dbo.STP_Language l
		ON an.LangID=l.LangID
WHERE an.CM_ID=@CM_ID
ORDER BY CASE WHEN an.LangID=@@LANGID THEN 0 ELSE 1 END, LangID, AltName

SELECT aas.Search_CM_ID, cmn.Name 
	FROM dbo.GBL_Community_AltAreaSearch aas
	INNER JOIN dbo.GBL_Community_Name cmn
		ON cmn.CM_ID=aas.Search_CM_ID
			AND LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE aas.CM_ID=@CM_ID
ORDER BY cmn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_s] TO [cioc_login_role]
GO
