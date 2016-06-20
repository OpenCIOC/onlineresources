SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_NUMBillingAddress_l]
	@NUM [varchar](8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT BADDR_ID, CASE
	WHEN ADDRTYPE IS NOT NULL OR SITE_CODE IS NOT NULL
		THEN  '[ '
			+ CASE WHEN ADDRTYPE IS NOT NULL THEN + atn.Name + CASE WHEN SITE_CODE IS NOT NULL THEN ' ; ' ELSE '' END ELSE '' END
			+ CASE WHEN SITE_CODE IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Site Code') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + SITE_CODE ELSE '' END
			+ ' ] '
		ELSE ''
	END + dbo.fn_GBL_FullBillingAddress(NUM,LINE_1,LINE_2,LINE_3,LINE_4,NULL,NULL,NULL,NULL) AS Display
FROM GBL_BT_BILLINGADDRESS ba
INNER JOIN GBL_BillingAddressType at
	ON ba.ADDRTYPE=at.AddressTypeID
INNER JOIN GBL_BillingAddressType_Name atn
	ON atn.AddressTypeID=at.AddressTypeID AND atn.LangID=(SELECT TOP 1 LangID FROM GBL_BillingAddressType_Name WHERE atn.AddressTypeID=AddressTypeID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE NUM=@NUM AND ba.LangID=@@LANGID
ORDER BY PRIORITY

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_NUMBillingAddress_l] TO [cioc_login_role]
GO
