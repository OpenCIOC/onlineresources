SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_SearchTips_s]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT st.PageText
	FROM GBL_SearchTips st
	INNER JOIN CIC_View_Description vwd
		ON st.SearchTipsID=vwd.SearchTips
WHERE vwd.ViewType=@ViewType
	AND vwd.LangID=@@LANGID

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_SearchTips_s] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_SearchTips_s] TO [cioc_login_role]
GO
