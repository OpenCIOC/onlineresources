SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_PaymentMethod_Check]
	@PaymentMethodEn nvarchar(200),
	@PaymentMethodFr nvarchar(200),
	@PAY_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT @PAY_ID = PAY_ID
	FROM GBL_PaymentMethod_Name
WHERE [Name]=@PaymentMethodEn OR [Name]=@PaymentMethodFr
	ORDER BY CASE
		WHEN [Name]=@PaymentMethodEn AND LangID=0 THEN 0
		WHEN [Name]=@PaymentMethodFr AND LangID=2 THEN 1
		ELSE 2
	END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_PaymentMethod_Check] TO [cioc_login_role]
GO
