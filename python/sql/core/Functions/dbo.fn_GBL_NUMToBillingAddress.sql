SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMToBillingAddress](
	@NUM varchar(8)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr	nvarchar(4),
		@returnStr	nvarchar(max)

SET @conStr = CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ CASE WHEN ba.ADDRTYPE IS NULL AND ba.SITE_CODE IS NULL
			THEN ''
			ELSE '[ '
				+ CASE WHEN ba.ADDRTYPE IS NULL THEN '' ELSE ba.ADDRTYPE + CASE WHEN ba.SITE_CODE IS NULL AND ba.CAS_CONFIRMATION_DATE IS NULL THEN '' ELSE ' ; ' END END
				+ CASE WHEN ba.CAS_CONFIRMATION_DATE IS NULL THEN '' ELSE + cioc_shared.dbo.fn_SHR_STP_ObjectName('CAS Site Confirmation Date') + cioc_shared.dbo.fn_SHR_STP_ObjectName(':') + cioc_shared.dbo.fn_SHR_GBL_DateString(ba.CAS_CONFIRMATION_DATE) + CASE WHEN ba.SITE_CODE IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ') END END
				+ CASE WHEN ba.SITE_CODE IS NULL THEN '' ELSE + cioc_shared.dbo.fn_SHR_STP_ObjectName('Site Code') + cioc_shared.dbo.fn_SHR_STP_ObjectName(':') + ba.SITE_CODE END
				 + ' ]' + CHAR(13) + CHAR(10)
			END
		+ ADDRESS
	FROM dbo.fn_GBL_NUMToBillingAddress_rst(@NUM) ba

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr
END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToBillingAddress] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToBillingAddress] TO [cioc_login_role]
GO
