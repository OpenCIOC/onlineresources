SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_DisplayPaymentMethod](
	@PAY_ID int,
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

DECLARE	@PaymentMethod	nvarchar(200)

SELECT @PaymentMethod = payn.Name
	FROM GBL_PaymentMethod pay
	INNER JOIN GBL_PaymentMethod_Name payn
		ON pay.PAY_ID=payn.PAY_ID AND LangID=@LangID
WHERE pay.PAY_ID=@PAY_ID

IF @PaymentMethod = '' SET @PaymentMethod = NULL

RETURN @PaymentMethod

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayPaymentMethod] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayPaymentMethod] TO [cioc_login_role]
GO
