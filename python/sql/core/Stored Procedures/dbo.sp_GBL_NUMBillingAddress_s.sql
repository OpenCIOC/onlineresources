SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_NUMBillingAddress_s]
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT *
	FROM GBL_BT_BILLINGADDRESS
WHERE NUM=@NUM AND LangID=@@LANGID
ORDER BY PRIORITY

SET NOCOUNT OFF

GRANT EXECUTE ON [dbo].[sp_GBL_NUMBillingAddress_s] TO [cioc_login_role]


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_NUMBillingAddress_s] TO [cioc_login_role]
GO
