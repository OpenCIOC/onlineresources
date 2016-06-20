SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_PaymentTerms_Check]
	@PaymentTermsEn nvarchar(200),
	@PaymentTermsFr nvarchar(200),
	@PYT_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT @PYT_ID = PYT_ID
	FROM GBL_PaymentTerms_Name
WHERE [Name]=@PaymentTermsEn OR [Name]=@PaymentTermsFr
	ORDER BY CASE
		WHEN [Name]=@PaymentTermsEn AND LangID=0 THEN 0
		WHEN [Name]=@PaymentTermsFr AND LangID=2 THEN 1
		ELSE 2
	END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_PaymentTerms_Check] TO [cioc_login_role]
GO
