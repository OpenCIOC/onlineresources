SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_NUMToSocialMedia_Icon](
	@NUM varchar(8)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

DECLARE	@conStr	nvarchar(4),
		@returnStr	nvarchar(max)

SET @conStr = ' '

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ '<a href="' + Protocol + URL + '">'
		+ '<img src="' + IconURL24 + '"'
		+ ' alt="' + REPLACE(Name,'"','""') + '"'
		+ ' title="' + REPLACE(Name,'"','""') + '"'
		+ ' width="24px" height="24px">'
		+ '</a>'
	FROM dbo.fn_GBL_NUMToSocialMedia_rst(@NUM)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO



GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToSocialMedia_Icon] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToSocialMedia_Icon] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToSocialMedia_Icon] TO [cioc_vol_search_role]
GO
