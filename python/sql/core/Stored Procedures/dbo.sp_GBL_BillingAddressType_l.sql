SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BillingAddressType_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT at.*, atn.Name 
	FROM GBL_BillingAddressType at
	INNER JOIN GBL_BillingAddressType_Name atn
		ON at.AddressTypeID=atn.AddressTypeID AND atn.LangID=(SELECT TOP 1 LangID FROM GBL_BillingAddressType_Name WHERE atn.AddressTypeID=AddressTypeID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY DefaultType DESC, atn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BillingAddressType_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_BillingAddressType_l] TO [cioc_login_role]
GO
