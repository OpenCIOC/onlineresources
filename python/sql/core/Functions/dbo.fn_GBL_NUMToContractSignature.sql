SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMToContractSignature](
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
		+ cts.SIGSTATUS
		+ CASE WHEN cts.SIGNATORY IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' by ') + cts.SIGNATORY END
		+ CASE WHEN cts.DATE IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' on ') + cioc_shared.dbo.fn_SHR_GBL_DateString(cts.DATE) END
		+ CASE WHEN cts.NOTES IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ') + cts.NOTES END
	FROM dbo.fn_GBL_NUMToContractSignature_rst(@NUM) cts

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToContractSignature] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToContractSignature] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToContractSignature] TO [cioc_vol_search_role]
GO
