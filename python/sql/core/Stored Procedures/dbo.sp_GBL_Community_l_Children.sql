SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Community_l_Children]
	@CM_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SELECT cm.CM_ID,
	ISNULL(cmn.Display,cmn.Name) AS Community,
	CASE WHEN EXISTS(SELECT * FROM dbo.GBL_Community WHERE ParentCommunity=cm.CM_ID)
		THEN (SELECT TOP 1
				ISNULL(ctn.Article,'') + ' ' + ISNULL(ctn.Simplified, ctn.Name)
			FROM dbo.GBL_Community_Type ct
			LEFT JOIN dbo.GBL_Community_Type_Name ctn
				ON ctn.Code = ct.Code AND ctn.LangID=@@LANGID
			LEFT JOIN dbo.GBL_Community cmp
				ON ct.Code=cmp.PrimaryAreaType AND cmp.ParentCommunity=cm.CM_ID
			WHERE cmp.CM_ID IS NOT NULL OR ct.Code='COMMUNITY'
			GROUP BY ISNULL(ctn.Article,'') + ' ' + ISNULL(ctn.Simplified, ctn.Name)
			ORDER BY COUNT(cmp.CM_ID) DESC)
		ELSE NULL
		END AS ChildCommunityType
	FROM dbo.GBL_Community cm
INNER JOIN dbo.GBL_Community_Name cmn
	ON cm.CM_ID=cmn.CM_ID
		AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE cm.ParentCommunity = @CM_ID
ORDER BY cmn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_l_Children] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_l_Children] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_l_Children] TO [cioc_vol_search_role]
GO
