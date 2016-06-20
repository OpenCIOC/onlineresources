SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToOtherAddress](
	@NUM varchar(8)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr	nvarchar(4),
		@returnStr	nvarchar(max)

SET @conStr = CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ CASE WHEN oa.TITLE IS NULL THEN '' ELSE oa.TITLE END
		+ CASE WHEN oa.SITE_CODE IS NULL THEN '' ELSE
				CASE WHEN oa.TITLE IS NULL THEN '' ELSE ' ' END
				+ '[ ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Site Code') + cioc_shared.dbo.fn_SHR_STP_ObjectName(':') + SITE_CODE +  ' ]'
			END
		+ CASE WHEN oa.TITLE IS NULL AND oa.SITE_CODE IS NULL THEN '' ELSE CHAR(13) + CHAR(10) END
		+ ADDRESS
	FROM dbo.fn_CIC_NUMToOtherAddress_rst(@NUM,0) oa

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToOtherAddress] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToOtherAddress] TO [cioc_login_role]
GO
