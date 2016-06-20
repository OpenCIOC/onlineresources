SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_NUMToTaxCodes_Link_rst](
	@BT_TAX_ID [int]
)
RETURNS @TaxTerms TABLE (
	[Code] [varchar](21) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1.1
	Checked by: KL
	Checked on: 11-Sep-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @TaxTerms 
SELECT tm.Code
	FROM CIC_BT_TAX_TM pr
	INNER JOIN TAX_Term tm
		ON pr.Code = tm.Code
	WHERE (pr.BT_TAX_ID = @BT_TAX_ID)
ORDER BY Code

RETURN

END

GO
GRANT SELECT ON  [dbo].[fn_CIC_NUMToTaxCodes_Link_rst] TO [cioc_cic_search_role]
GO
