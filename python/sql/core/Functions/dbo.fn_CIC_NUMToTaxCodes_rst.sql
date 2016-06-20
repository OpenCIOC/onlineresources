SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_NUMToTaxCodes_rst](
	@NUM varchar(8)
)
RETURNS @TaxTerms TABLE (
	[LinkedCode] varchar(max) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 11-Sep-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @TaxTerms
	SELECT dbo.fn_CIC_NUMToTaxCodes_Link(pr.BT_TAX_ID)
FROM CIC_BT_TAX pr
	WHERE pr.NUM=@NUM
ORDER BY dbo.fn_CIC_NUMToTaxCodes_Link(pr.BT_TAX_ID)

RETURN

END


GO
GRANT SELECT ON  [dbo].[fn_CIC_NUMToTaxCodes_rst] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_CIC_NUMToTaxCodes_rst] TO [cioc_login_role]
GO
