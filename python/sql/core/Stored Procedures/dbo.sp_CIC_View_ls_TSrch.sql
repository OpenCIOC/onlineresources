SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_ls_TSrch]
	@ViewType [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 14-Sep-2013
	Action: NO ACTION REQUIRED
*/

SELECT vts.TopicSearchTag, vtsd.SearchTitle, vtsd.SearchDescription
	FROM CIC_View_TopicSearch vts
	LEFT JOIN CIC_View_TopicSearch_Description vtsd
		ON vts.TopicSearchID=vtsd.TopicSearchID AND vtsd.LangID=@@LANGID
WHERE vts.ViewType=@ViewType
ORDER BY vts.DisplayOrder, vtsd.SearchTitle

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_ls_TSrch] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_View_ls_TSrch] TO [cioc_login_role]
GO
