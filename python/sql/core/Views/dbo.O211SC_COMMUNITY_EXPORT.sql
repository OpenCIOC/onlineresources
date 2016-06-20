SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[O211SC_COMMUNITY_EXPORT]
AS
SELECT
	cm.CM_ID,
	"record" = (SELECT
		"id" = cm.CM_ID,
		"parent_id" = cm.ParentCommunity,
		"names" = (SELECT
					cmn.Name "value",
					sl.Culture "culture"
				FROM GBL_Community_Name cmn
				INNER JOIN STP_Language sl
					ON cmn.LangID=sl.LangID
				WHERE cm.CM_ID = cmn.CM_ID
				FOR XML PATH('name'), TYPE
			)
		FOR XML PATH('community'), TYPE
	)
FROM GBL_Community cm

GO
GRANT SELECT ON  [dbo].[O211SC_COMMUNITY_EXPORT] TO [cioc_login_role]
GO
