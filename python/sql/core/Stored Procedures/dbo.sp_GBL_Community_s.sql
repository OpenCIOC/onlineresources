SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Community_s]
	@CM_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT cm.*, 
		(SELECT cmn.Name
		 FROM GBL_Community_Name cmn
		 WHERE CM_ID=ParentCommunity AND 
			LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID 
					ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
				) AS ParentCommunityName,
		(SELECT cmn.CM_ID, cmn.Name
		 FROM GBL_Community_AltAreaSearch cm2
		INNER JOIN GBL_Community_Name cmn
			ON cm2.CM_ID=cmn.CM_ID AND LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			WHERE Search_CM_ID=@CM_ID
		FOR XML AUTO, TYPE) AS AltSearchArea,
	(SELECT COUNT(*) FROM GBL_Community WHERE ParentCommunity=@CM_ID) AS ParentUsage,
	(SELECT COUNT(*) FROM GBL_BaseTable WHERE LOCATED_IN_CM=@CM_ID) AS LocatedInUsage,
	(SELECT COUNT(*) FROM CIC_BT_CM WHERE CM_ID=@CM_ID) AS AreasServedUsage,
	(SELECT COUNT(*) FROM VOL_OP_CM WHERE CM_ID=@CM_ID) AS VolOppUsage,
	(SELECT COUNT(*) FROM CIC_BusRoute WHERE Municipality=@CM_ID) AS BusRouteUsage,
	(SELECT COUNT(*) FROM CIC_Ward WHERE Municipality=@CM_ID) AS WardUsage,
	(SELECT COUNT(*) FROM CIC_View_Community WHERE CM_ID=@CM_ID) AS ViewUsage,
	(SELECT COUNT(*) FROM VOL_CommunityGroup_CM WHERE CM_ID=@CM_ID) AS CommunityGroupUsage,
	CAST(CASE WHEN EXISTS(
			SELECT * FROM STP_Member mem
			WHERE NOT EXISTS(
				SELECT *
					FROM GBL_FieldOption_InactiveByMember fi
					INNER JOIN GBL_FieldOption fo
						ON fi.FieldID=fo.FieldID AND fo.FieldName='BUS_ROUTES'
				WHERE fi.MemberID=mem.MemberID
			)
		) THEN 1 ELSE 0 END AS bit) AS UsesBusRoutes,
	CAST(CASE WHEN EXISTS(
			SELECT * FROM STP_Member mem
			WHERE NOT EXISTS(
				SELECT *
					FROM GBL_FieldOption_InactiveByMember fi
					INNER JOIN GBL_FieldOption fo
						ON fi.FieldID=fo.FieldID AND fo.FieldName='WARD'
				WHERE fi.MemberID=mem.MemberID
			)
		) THEN 1 ELSE 0 END AS bit) AS UsesWards
	FROM GBL_Community cm
WHERE CM_ID=@CM_ID

SELECT cmn.*,
		(SELECT Culture FROM STP_Language WHERE LangID=cmn.LangID) AS Culture
	FROM GBL_Community_Name cmn
WHERE CM_ID=@CM_ID

SELECT an.*, l.Culture
	FROM GBL_Community_AltName an
	INNER JOIN STP_Language l
		ON an.LangID=l.LangID
WHERE CM_ID=@CM_ID
ORDER BY CASE WHEN an.LangID=@@LANGID THEN 0 ELSE 1 END, LangID, AltName

SELECT Search_CM_ID, cmn.Name 
	FROM GBL_Community_AltAreaSearch aas
	INNER JOIN GBL_Community_Name cmn
		ON cmn.CM_ID=aas.Search_CM_ID
			AND LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE aas.CM_ID=@CM_ID
ORDER BY cmn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_s] TO [cioc_login_role]
GO
