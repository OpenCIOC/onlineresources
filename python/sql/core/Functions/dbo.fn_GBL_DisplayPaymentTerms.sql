SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_DisplayPaymentTerms](
	@PYT_ID int,
	@LangID smallint
)
RETURNS nvarchar(200) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@PaymentTerms	nvarchar(200)

SELECT @PaymentTerms = pytn.Name
	FROM GBL_PaymentTerms pyt
	INNER JOIN GBL_PaymentTerms_Name pytn
		ON pyt.PYT_ID=pytn.PYT_ID AND LangID=@LangID
WHERE pyt.PYT_ID=@PYT_ID

IF @PaymentTerms = '' SET @PaymentTerms = NULL

RETURN @PaymentTerms

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayPaymentTerms] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayPaymentTerms] TO [cioc_login_role]
GO
