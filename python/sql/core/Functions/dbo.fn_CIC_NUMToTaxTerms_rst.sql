SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToTaxTerms_rst](
	@NUM varchar(8),
	@ForWeb bit,
	@LinkAll bit,
	@LangID smallint,
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS @TaxTerms TABLE (
	[LinkedTerm] varchar(max) COLLATE Latin1_General_100_CI_AI NULL
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
	SELECT CASE WHEN @ForWeb=1
		THEN dbo.fn_CIC_NUMToTaxTerms_Link_Web(pr.BT_TAX_ID,@LinkAll,@LangID,@HTTPVals,@PathToStart)
		ELSE  dbo.fn_CIC_NUMToTaxTerms_Link(pr.BT_TAX_ID,@LangID)
	END
FROM CIC_BT_TAX pr
	WHERE pr.NUM=@NUM
ORDER BY dbo.fn_CIC_NUMToTaxTerms_Link(pr.BT_TAX_ID,@LangID)

RETURN

END

GO
GRANT SELECT ON  [dbo].[fn_CIC_NUMToTaxTerms_rst] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_CIC_NUMToTaxTerms_rst] TO [cioc_login_role]
GO
