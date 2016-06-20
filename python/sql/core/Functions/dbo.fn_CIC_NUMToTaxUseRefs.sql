
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToTaxUseRefs](
	@MemberID int,
	@NUM varchar(8)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6.2
	Checked by: CL
	Checked on: 24-Oct-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(5),
		@returnStr nvarchar(max)
		
SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  STUFF(
	(SELECT @constr + src.Term
	FROM (
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
	) AS src
	ORDER BY src.Term
	FOR XML PATH(''), TYPE
	).value('.', 'nvarchar(max)')
	,1, LEN(REPLACE(@constr, ' ', '_')),''
)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO


GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToTaxUseRefs] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToTaxUseRefs] TO [cioc_login_role]
GO
