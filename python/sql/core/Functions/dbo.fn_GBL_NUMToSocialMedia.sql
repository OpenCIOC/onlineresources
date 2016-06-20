SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_NUMToSocialMedia](
	@NUM varchar(8)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 02-Nov-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr	nvarchar(4),
		@returnStr	nvarchar(max)

SET @conStr = CHAR(13) + CHAR(10)

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ Name + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
		+ CASE WHEN Protocol='http://' THEN '' ELSE Protocol END + URL
	FROM dbo.fn_GBL_NUMToSocialMedia_rst(@NUM)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToSocialMedia] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToSocialMedia] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToSocialMedia] TO [cioc_vol_search_role]
GO
