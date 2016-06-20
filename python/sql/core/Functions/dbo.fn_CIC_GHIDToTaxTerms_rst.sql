SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_GHIDToTaxTerms_rst](
	@GH_ID varchar(8),
	@LangID smallint
)
RETURNS @TaxTerms TABLE (
	[LinkedTerm] varchar(max) COLLATE Latin1_General_100_CI_AI NULL
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
SELECT dbo.fn_CIC_GHIDToTaxTerms_Link(pr.GH_TAX_ID,@LangID)
FROM CIC_GeneralHeading_TAX pr
	WHERE pr.GH_ID=@GH_ID
ORDER BY dbo.fn_CIC_GHIDToTaxTerms_Link(pr.GH_TAX_ID,@LangID)

RETURN

END


GO
GRANT SELECT ON  [dbo].[fn_CIC_GHIDToTaxTerms_rst] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_CIC_GHIDToTaxTerms_rst] TO [cioc_login_role]
GO
