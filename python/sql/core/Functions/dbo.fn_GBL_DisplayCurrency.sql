SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_DisplayCurrency](
	@CUR_ID int,
	@IncludeName bit
)
RETURNS nvarchar(206) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Currency	nvarchar(206)

SELECT @Currency = Currency
		+ CASE
			WHEN @IncludeName=1 AND curn.Name IS NOT NULL
			THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' (') + curn.Name + cioc_shared.dbo.fn_SHR_STP_ObjectName(')')
			ELSE ''
		END
	FROM GBL_Currency cur
	LEFT JOIN GBL_Currency_Name curn
		ON cur.CUR_ID=curn.CUR_ID AND curn.LangID=@@LANGID
WHERE cur.CUR_ID=@CUR_ID

IF @Currency = '' SET @Currency = NULL

RETURN @Currency

END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayCurrency] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayCurrency] TO [cioc_login_role]
GO
