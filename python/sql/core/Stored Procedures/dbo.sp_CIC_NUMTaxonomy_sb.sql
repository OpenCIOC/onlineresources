SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMTaxonomy_sb]
	@ViewType [int],
	@NUM [varchar](8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 01-Feb-2011
	Action: NO ACTION REQUIRED
*/

/* Select this list of linked term sets used by this record */
SELECT tlt.*, CASE WHEN tmd.LangID=@@LANGID THEN tmd.Term ELSE '[' + tmd.Term + ']' END AS Term
	FROM CIC_BT_TAX tl
	INNER JOIN CIC_BT_TAX_TM tlt
		ON tlt.BT_TAX_ID=tl.BT_TAX_ID
	INNER JOIN TAX_Term tm
		ON tlt.Code=tm.Code
	INNER JOIN TAX_Term_Description tmd
		ON tm.Code=tmd.Code AND tmd.LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE tmd.Code=Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE tl.NUM=@NUM AND dbo.fn_CIC_RecordInView(tl.NUM,@ViewType,@@LANGID,0,GETDATE()) <> 0
ORDER BY dbo.fn_CIC_NUMToTaxTerms_Link(tlt.BT_TAX_ID,@@LANGID)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMTaxonomy_sb] TO [cioc_login_role]
GO
