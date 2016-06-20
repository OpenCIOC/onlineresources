SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToTaxUseRefs_rst](
	@MemberID int,
	@NUM [varchar](8)
)
RETURNS @TaxTerms TABLE (
	[Term] [varchar](255) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Apr-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @TaxTerms 
SELECT Term
	FROM CIC_BT_TAX tl
	INNER JOIN CIC_BT_TAX_TM tlt
		ON tl.BT_TAX_ID=tlt.BT_TAX_ID
	INNER JOIN TAX_Unused ut
		ON tlt.Code = ut.Code
			AND ut.LangID=@@LANGID
			AND ut.Active=1
	WHERE tl.NUM = @NUM
UNION SELECT ISNULL(tmd.AltTerm,tmd.Term) AS Term
		FROM CIC_BT_TAX tl
		INNER JOIN CIC_BT_TAX_TM tlt
			ON tl.BT_TAX_ID=tlt.BT_TAX_ID
		INNER JOIN TAX_Term_ParentList tmpl
			ON tlt.Code=tmpl.ParentCode
		INNER JOIN TAX_Term tm
			ON tmpl.Code=tm.Code
		INNER JOIN TAX_Term_Description tmd
			ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID
	WHERE tl.NUM=@NUM
		AND (
				(
					tm.Active IS NULL
					AND NOT EXISTS(SELECT * FROM TAX_Term_ParentList tmplx
						WHERE tmplx.ParentCode=tm.Code
							AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tmplx.Code AND MemberID=@MemberID))
				)
			OR (
				tm.Active=1
				AND NOT EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID)
			)
		)
ORDER BY Term

RETURN

END



GO
GRANT SELECT ON  [dbo].[fn_CIC_NUMToTaxUseRefs_rst] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_CIC_NUMToTaxUseRefs_rst] TO [cioc_login_role]
GO
