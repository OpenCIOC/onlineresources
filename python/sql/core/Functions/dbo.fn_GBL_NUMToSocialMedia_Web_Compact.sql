
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [dbo].[fn_GBL_NUMToSocialMedia_Web_Compact](
	@NUM varchar(8)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.8
	Checked by: KL
	Checked on: 16-Sep-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr	nvarchar(8),
		@returnStr	nvarchar(max)

SET @conStr = ', '

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ '<img src="' + IconURL16 + '"'
		+ ' alt="' + REPLACE(Name,'"','""') + '"'
		+ ' width="16px" height="16px">&nbsp;'
		+ '<a href="' + Protocol + URL + '">' + Name + '</a>'
	FROM dbo.fn_GBL_NUMToSocialMedia_rst(@NUM)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END



GO



GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToSocialMedia_Web_Compact] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToSocialMedia_Web_Compact] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToSocialMedia_Web_Compact] TO [cioc_vol_search_role]
GO
