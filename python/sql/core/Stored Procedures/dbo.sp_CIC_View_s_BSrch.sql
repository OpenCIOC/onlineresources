SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_s_BSrch] @ViewType [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON;

SELECT
    vw.SrchCommunityDefault,
    vw.SrchCommunityDefaultOnly,
    vw.BSrchAutoComplete,
    vw.BSrchAges,
    vw.BSrchBrowseByOrg,
    vw.BSrchKeywords,
    vw.BSrchLanguage,
    vw.BSrchNUM,
    vw.BSrchOCG,
    vw.BSrchVacancy,
    vw.BSrchVOL,
    vw.BSrchWWW,
    vw.BSrchDefaultTab,
    vw.BSrchNear2,
    vw.BSrchNear5,
    vw.BSrchNear10,
    vw.BSrchNear15,
    vw.BSrchNear25,
    vw.BSrchNear50,
    vw.BSrchNear100,
    vw.CSrch,
    vwd.CSrchText,
    CASE WHEN vwd.SearchTips IS NULL THEN 0 ELSE 1 END AS HasSearchTips,
    vwd.MenuTitle,
    vwd.MenuGlyph,
    vwd.MenuMessage,
    vwd.SearchLeftTitle,
    vwd.SearchLeftGlyph,
    vwd.SearchLeftMessage,
    vwd.SearchCentreTitle,
    vwd.SearchCentreGlyph,
    vwd.SearchCentreMessage,
    vwd.SearchRightTitle,
    vwd.SearchRightGlyph,
    vwd.SearchRightMessage,
    vwd.SearchAlertTitle,
    vwd.SearchAlertGlyph,
    vwd.SearchAlertMessage,
    vwd.KeywordSearchTitle,
    vwd.KeywordSearchGlyph,
    vwd.OtherSearchTitle,
    vwd.OtherSearchGlyph,
    vwd.OtherSearchMessage,
    vwd.QuickSearchTitle,
    vwd.QuickSearchGlyph
FROM    dbo.CIC_View vw
    LEFT JOIN dbo.CIC_View_Description vwd
        ON vw.ViewType = vwd.ViewType AND   vwd.LangID = @@LANGID
WHERE   vw.ViewType = @ViewType;

SELECT
    vts.TopicSearchTag,
    vtsd.SearchTitle,
    vtsd.SearchDescription
FROM    dbo.CIC_View_TopicSearch vts
    LEFT JOIN dbo.CIC_View_TopicSearch_Description vtsd
        ON vts.TopicSearchID = vtsd.TopicSearchID AND   vtsd.LangID = @@LANGID
WHERE   vts.ViewType = @ViewType
ORDER BY
    vts.DisplayOrder,
    vtsd.SearchTitle;

SELECT
    qsd.Name,
    qs.PageName,
    qs.QueryParameters,
    qs.PromoteToTab
FROM    dbo.CIC_View_QuickSearch qs
    INNER JOIN dbo.CIC_View_QuickSearch_Name qsd
        ON qs.QuickSearchID = qsd.QuickSearchID AND qsd.LangID = @@LANGID
WHERE   qs.ViewType = @ViewType
ORDER BY
    qs.DisplayOrder,
    qsd.Name;

SET NOCOUNT OFF;

GO








GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_BSrch] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_View_s_BSrch] TO [cioc_login_role]
GO
