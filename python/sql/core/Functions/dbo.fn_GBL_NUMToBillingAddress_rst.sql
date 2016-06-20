SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMToBillingAddress_rst](
	@NUM [varchar](8)
)
RETURNS @BillingAddress TABLE (
	[ADDRTYPE] [nvarchar](100) COLLATE Latin1_General_100_CI_AI NULL,
	[SITE_CODE] [varchar](100) COLLATE Latin1_General_100_CI_AI NULL,
	[CAS_CONFIRMATION_DATE] [smalldatetime] NULL,
	[Address] [nvarchar](max) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @BillingAddress 
	SELECT
		atn.Name,
		SITE_CODE,
		CAS_CONFIRMATION_DATE,
		dbo.fn_GBL_FullBillingAddress(
				NUM,
				LINE_1,
				LINE_2,
				LINE_3,
				LINE_4,
				CITY,
				PROVINCE,
				COUNTRY,
				POSTAL_CODE
			)
	FROM GBL_BT_BILLINGADDRESS ba
	INNER JOIN GBL_BillingAddressType at
		ON ba.ADDRTYPE=at.AddressTypeID
	INNER JOIN GBL_BillingAddressType_Name atn
		ON at.AddressTypeID=atn.AddressTypeID AND atn.LangID=(SELECT TOP 1 LangID FROM GBL_BillingAddressType_Name WHERE atn.AddressTypeID=AddressTypeID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE NUM = @NUM AND ba.LangID=@@LANGID
ORDER BY PRIORITY

RETURN

END
GO
