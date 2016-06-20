
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Community_ls_Finder]
	@CM_ID int,
	@searchStr nvarchar(100),
	@HTTPVals varchar(500),
	@PathToStart varchar(50),
	@SearchParameters bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.2
	Checked by: KL
	Checked on: 23-Oct-2015
	Action: NO ACTION REQUIRED
*/

SELECT cmn.CM_ID, CASE WHEN cm.AlternativeArea=1 THEN '<em>' ELSE '' END + cmn.Name + CASE WHEN cm.AlternativeArea=1 THEN '</em>' ELSE '' END AS Community, cm.AlternativeArea,
		cioc_shared.dbo.fn_SHR_GBL_Link_CommunityFinder(cm2.CM_ID,cmn2.Name,1,@HTTPVals,@PathToStart) AS ParentCommunityName,
		dbo.fn_GBL_Community_FinderChildren_Web(cm.CM_ID,@HTTPVals,@PathToStart,@SearchParameters) AS ChildCommunities
	FROM GBL_Community cm
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_Community cm2
		ON cm.ParentCommunity = cm2.CM_ID
	LEFT JOIN GBL_Community_Name cmn2
		ON cm2.CM_ID=cmn2.CM_ID
			AND cmn2.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm2.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE (@CM_ID IS NOT NULL AND cm.CM_ID=@CM_ID)
	OR (@CM_ID IS NULL AND cmn.Name LIKE '%' + @searchStr + '%')
	OR (@CM_ID IS NULL AND EXISTS(SELECT * FROM GBL_Community_AltName anm WHERE LangID=@@LANGID AND CM_ID=cm.CM_ID AND AltName LIKE '%' + @searchStr + '%'))
ORDER BY cmn.Name

SET NOCOUNT OFF







GO



GRANT EXECUTE ON  [dbo].[sp_GBL_Community_ls_Finder] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_ls_Finder] TO [cioc_login_role]
GO
