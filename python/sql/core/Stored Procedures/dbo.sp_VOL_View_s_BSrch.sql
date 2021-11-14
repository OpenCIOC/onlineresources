
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_View_s_BSrch]
	@ViewType [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 01-Feb-2016
	Action: NO ACTION REQUIRED
*/

SELECT	BSrchAutoComplete,
		BSrchBrowseAll,
		BSrchBrowseByInterest,
		BSrchBrowseByOrg,
		BSrchKeywords,
		BSrchStepByStep,
		BSrchStudent,
		BSrchWhatsNew,
		BSrchDefaultTab,
		BSrchCommunity,
		BSrchSuitableFor,
		BSrchCommitmentLength,
		CAST(CASE WHEN SearchTips IS NULL THEN 0 ELSE 1 END AS bit) AS HasSearchTips,
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
		SearchPromptOverride,
		KeywordSearchTitle,
		KeywordSearchGlyph,
		OtherSearchTitle,
		OtherSearchGlyph,
		OtherSearchMessage,
		HighlightOpportunity
	FROM VOL_View vw
	LEFT JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType AND vwd.LangID=@@LANGID
WHERE vw.ViewType = @ViewType

SET NOCOUNT OFF


GO








GRANT EXECUTE ON  [dbo].[sp_VOL_View_s_BSrch] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_View_s_BSrch] TO [cioc_vol_search_role]
GO
