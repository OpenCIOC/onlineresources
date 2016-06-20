SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToTaxTerms_Link_rst](
	@BT_TAX_ID [int],
	@LangID [smallint]
)
RETURNS @TaxTerms TABLE (
	[Code] [varchar](21) COLLATE Latin1_General_100_CI_AI NULL,
	[Term] [varchar](255) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 08-Apr-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @TaxTerms 
SELECT tm.Code, ISNULL(tmd.AltTerm,tmd.Term) AS Term
	FROM CIC_BT_TAX_TM pr
	INNER JOIN TAX_Term tm
		ON pr.Code = tm.Code
	INNER JOIN TAX_Term_Description tmd
		ON tm.Code = tmd.Code AND tmd.LangID=@LangID
	WHERE (pr.BT_TAX_ID = @BT_TAX_ID)
ORDER BY ISNULL(tmd.AltTerm,tmd.Term)

RETURN

END

GO
GRANT SELECT ON  [dbo].[fn_CIC_NUMToTaxTerms_Link_rst] TO [cioc_cic_search_role]
GO
