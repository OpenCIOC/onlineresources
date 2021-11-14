SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_s_BSrch]
	@ViewType [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 28-Feb-2016
	Action: NO ACTION REQUIRED
*/

SELECT	SrchCommunityDefault,
		BSrchAutoComplete,
		BSrchAges,
		BSrchBrowseByOrg,
		BSrchKeywords,
		BSrchLanguage,
		BSrchNUM,
		BSrchOCG,
		BSrchVacancy,
		BSrchVOL,
		BSrchWWW,
		BSrchDefaultTab,
		BSrchNear2,
		BSrchNear5,
		BSrchNear10,
		BSrchNear15,
		BSrchNear25,
		BSrchNear50,
		BSrchNear100,
		CSrch,
		CSrchText,
		CASE WHEN SearchTips IS NULL THEN 0 ELSE 1 END AS HasSearchTips,
		MenuTitle,
		MenuGlyph,
		MenuMessage,
		SearchLeftTitle,
		SearchLeftGlyph,
		SearchLeftMessage,
		SearchCentreTitle,
		SearchCentreGlyph,
		SearchCentreMessage,
		SearchRightTitle,
		SearchRightGlyph,
		SearchRightMessage,
		SearchAlertTitle,
		SearchAlertGlyph,
		SearchAlertMessage,
		KeywordSearchTitle,
		KeywordSearchGlyph,
		OtherSearchTitle,
		OtherSearchGlyph,
		OtherSearchMessage,
		QuickSearchTitle,
		QuickSearchGlyph
	FROM CIC_View vw
	LEFT JOIN CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType AND vwd.LangID=@@LANGID
WHERE vw.ViewType = @ViewType

SELECT vts.TopicSearchTag, vtsd.SearchTitle, vtsd.SearchDescription
	FROM CIC_View_TopicSearch vts
	LEFT JOIN CIC_View_TopicSearch_Description vtsd
		ON vts.TopicSearchID=vtsd.TopicSearchID AND vtsd.LangID=@@LANGID
WHERE vts.ViewType=@ViewType
ORDER BY vts.DisplayOrder, vtsd.SearchTitle

SELECT qsd.Name, qs.PageName, qs.QueryParameters, qs.PromoteToTab
	FROM CIC_View_QuickSearch qs
	INNER JOIN CIC_View_QuickSearch_Name qsd
		ON qs.QuickSearchID=qsd.QuickSearchID AND qsd.LangID=@@LANGID
WHERE qs.ViewType=@ViewType
ORDER BY qs.DisplayOrder, qsd.Name

SET NOCOUNT OFF

GO








GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_BSrch] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_BSrch] TO [cioc_login_role]
GO
