SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_Term_s_Code_Unmatched]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

SELECT	tm.Code,
		tmde.Term,
		tmdf.Term AS TermEq,
		dbo.fn_TAX_U_NewCodeList(tm.Code) AS NewCode,
		(SELECT COUNT(*) FROM dbo.CIC_BT_TAX_TM tt WHERE tt.Code=tm.Code) AS USAGE_COUNT,
		(SELECT COUNT(*) FROM dbo.CIC_GeneralHeading_TAX_TM ghtm WHERE ghtm.Code=tm.Code) AS HEADING_USAGE_COUNT
	FROM dbo.TAX_Term tm
	LEFT JOIN dbo.TAX_Term_Description tmde
		ON tm.Code=tmde.Code AND tmde.LangID=0
	LEFT JOIN dbo.TAX_Term_Description tmdf
		ON tm.Code=tmdf.Code AND tmdf.LangID=2
WHERE tm.Authorized=1
	AND NOT EXISTS(SELECT * FROM dbo.TAX_U_Term utt WHERE utt.Code=tm.Code)
GROUP BY tm.Code,tmde.Term,tmdf.Term

SET NOCOUNT OFF

END

GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_Term_s_Code_Unmatched] TO [cioc_login_role]
GO
