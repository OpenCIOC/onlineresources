SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToTaxSeeAlsos_rst](
	@MemberID int,
	@NUM varchar(8)
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
SELECT DISTINCT tm.Code, Term
	FROM CIC_BT_TAX pr
		INNER JOIN CIC_BT_TAX_TM fr
			ON pr.BT_TAX_ID=fr.BT_TAX_ID
		INNER JOIN TAX_SeeAlso sa
			ON fr.Code = sa.Code
		INNER JOIN TAX_Term tm
			ON sa.SA_Code=tm.Code
		INNER JOIN TAX_Term_Description tmd
			ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID
WHERE pr.NUM = @NUM
	AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID)
ORDER BY Term
	
RETURN

END

GO
GRANT SELECT ON  [dbo].[fn_CIC_NUMToTaxSeeAlsos_rst] TO [cioc_cic_search_role]
GO
