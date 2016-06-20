SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_DisplayMainAddress](
	@NUM [varchar](8),
	@MAIN_ADDRESS_SITE [bit],
	@MAIN_ADDRESS_MAIL [bit],
	@MAIN_ADDRESS_ADDRID [int],
	@MAIN_ADDRESS_BADDRID [int]
)
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(max)

SET @returnStr = NULL

IF @MAIN_ADDRESS_SITE=1 BEGIN
	SELECT @returnStr = dbo.fn_GBL_FullAddress(NUM,NULL,NULL,SITE_STREET_NUMBER,SITE_STREET,SITE_STREET_TYPE,SITE_STREET_TYPE_AFTER,SITE_STREET_DIR,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,@@LANGID,0)
	FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=@@LANGID
	IF @returnStr = '' OR @returnStr IS NULL BEGIN
		SET @returnStr = cioc_shared.dbo.fn_SHR_STP_ObjectName('Site Address')
	END ELSE BEGIN
		SET @returnStr = cioc_shared.dbo.fn_SHR_STP_ObjectName('Site Address') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + @returnStr
	END	
END ELSE IF @MAIN_ADDRESS_MAIL=1 BEGIN
	SELECT @returnStr = dbo.fn_GBL_FullAddress(NUM,NULL,NULL,MAIL_STREET_NUMBER,MAIL_STREET,MAIL_STREET_TYPE,MAIL_STREET_TYPE_AFTER,MAIL_STREET_DIR,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,@@LANGID,0)
	FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=@@LANGID
	IF @returnStr = '' OR @returnStr IS NULL BEGIN
		SET @returnStr = cioc_shared.dbo.fn_SHR_STP_ObjectName('Mailing Address')
	END ELSE BEGIN
		SET @returnStr = cioc_shared.dbo.fn_SHR_STP_ObjectName('Mailing Address') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + @returnStr
	END	
END ELSE IF @MAIN_ADDRESS_ADDRID IS NOT NULL BEGIN
	SELECT @returnStr = CASE
	WHEN TITLE IS NOT NULL OR SITE_CODE IS NOT NULL
		THEN  '[ '
			+ CASE WHEN TITLE IS NOT NULL THEN + TITLE + CASE WHEN SITE_CODE IS NOT NULL THEN ' ; ' ELSE '' END ELSE '' END
			+ CASE WHEN SITE_CODE IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Site Code') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + SITE_CODE ELSE '' END
			+ ' ] '
		ELSE ''
	END + dbo.fn_GBL_FullAddress(NUM,NULL,NULL,STREET_NUMBER,STREET,STREET_TYPE,STREET_TYPE_AFTER,STREET_DIR,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,LangID,0)
	FROM CIC_BT_OTHERADDRESS
	WHERE ADDR_ID=@MAIN_ADDRESS_ADDRID
END ELSE BEGIN
	SELECT @returnStr = CASE
	WHEN ADDRTYPE IS NOT NULL OR SITE_CODE IS NOT NULL
		THEN  '[ '
			+ CASE WHEN ADDRTYPE IS NOT NULL THEN + at.Name + CASE WHEN SITE_CODE IS NOT NULL THEN ' ; ' ELSE '' END ELSE '' END
			+ CASE WHEN SITE_CODE IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Site Code') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + SITE_CODE ELSE '' END
			+ ' ] '
		ELSE ''
	END + dbo.fn_GBL_FullBillingAddress(NUM,LINE_1,LINE_2,LINE_3,LINE_4,NULL,NULL,NULL,NULL)
	FROM GBL_BT_BILLINGADDRESS ba
	INNER JOIN GBL_BillingAddressType_Name at
		ON ba.ADDRTYPE=at.AddressTypeID AND at.LangID=(SELECT TOP 1 LangID FROM GBL_BillingAddressType_Name WHERE at.AddressTypeID=AddressTypeID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE BADDR_ID=@MAIN_ADDRESS_BADDRID
END

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayMainAddress] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayMainAddress] TO [cioc_login_role]
GO
