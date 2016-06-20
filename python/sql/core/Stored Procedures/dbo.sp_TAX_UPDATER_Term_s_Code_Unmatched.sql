SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_Term_s_Code_Unmatched]
WITH EXECUTE AS CALLER
AS
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 15-Oct-2012
	Action: NO ACTION REQUIRED
*/

SET NOCOUNT ON

SELECT	tm.Code,
		tmde.Term,
		tmdf.Term AS TermEq,
		tax_updater.dbo.fn_UPDATER_NewCodeList(tm.Code) AS NewCode,
		(SELECT COUNT(*) FROM CIC_BT_TAX_TM tt WHERE tt.Code=tm.Code) AS USAGE_COUNT,
		(SELECT COUNT(*) FROM CIC_GeneralHeading_TAX_TM ghtm WHERE ghtm.Code=tm.Code) AS HEADING_USAGE_COUNT
	FROM TAX_Term tm
	LEFT JOIN TAX_Term_Description tmde
		ON tm.Code=tmde.Code AND tmde.LangID=0
	LEFT JOIN TAX_Term_Description tmdf
		ON tm.Code=tmdf.Code AND tmdf.LangID=2
WHERE Authorized=1
	AND NOT EXISTS(SELECT * FROM tax_updater.dbo.UPDATER_Term utt WHERE utt.Code=tm.Code)
GROUP BY tm.Code,tmde.Term,tmdf.Term

SET NOCOUNT OFF

END

GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_Term_s_Code_Unmatched] TO [cioc_login_role]
GO
