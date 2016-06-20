SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_GHIDToTaxTerms_Link_rst](
	@GH_TAX_ID [int],
	@LangID [smallint]
)
RETURNS @TaxTerms TABLE (
	[Code] [varchar](21) COLLATE Latin1_General_100_CI_AI NULL,
	[Term] [varchar](255) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 30-Sep-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @TaxTerms 
SELECT tm.Code, ISNULL(tmd.AltTerm,tmd.Term) AS Term
	FROM CIC_GeneralHeading_TAX_TM pr
	INNER JOIN TAX_Term tm
		ON pr.Code = tm.Code
	INNER JOIN TAX_Term_Description tmd
		ON tm.Code = tmd.Code AND tmd.LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE Code=tm.Code ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
	WHERE (pr.GH_TAX_ID = @GH_TAX_ID)
ORDER BY ISNULL(tmd.AltTerm,tmd.Term)

RETURN

END

GO
GRANT SELECT ON  [dbo].[fn_CIC_GHIDToTaxTerms_Link_rst] TO [cioc_cic_search_role]
GO
