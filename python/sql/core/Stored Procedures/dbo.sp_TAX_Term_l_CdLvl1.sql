SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_TAX_Term_l_CdLvl1]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 17-Nov-2015
	Action: NO ACTION REQUIRED
*/

SELECT tm.Code, REPLACE(ISNULL(tmd.AltTerm,tmd.Term),'/',' / ') AS Term, tm.IconFA
FROM TAX_Term tm
INNER JOIN TAX_Term_Description tmd
	ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID
WHERE tm.CdLvl=1
ORDER BY Code

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Term_l_CdLvl1] TO [cioc_cic_search_role]
GO
