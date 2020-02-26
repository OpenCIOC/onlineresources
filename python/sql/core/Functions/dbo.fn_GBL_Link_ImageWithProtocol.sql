SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_Link_ImageWithProtocol](
	@ImgURL [varchar](200),
	@ImgLink [varchar](200),
	@ImgID [VARCHAR](50),
	@ImgClass [varchar](50),
	@ImgURLProtocol varchar(8),
	@ImgLinkProtocol varchar(8),
	@ImgHoverText NVARCHAR(500),
	@ImgAltText NVARCHAR(255)
)
RETURNS [varchar](500) WITH EXECUTE AS CALLER
AS 
BEGIN 
DECLARE @returnStr varchar(500)

IF @ImgURL IS NULL BEGIN
	SET @returnStr = NULL
END ELSE BEGIN
	SET @returnStr = '<img src="'
		+ CASE WHEN @ImgURLProtocol IS NULL THEN 'http://' ELSE @ImgURLProtocol END
		+ @ImgURL + '" border="0"'
		+ CASE WHEN @ImgClass IS NULL THEN '' ELSE ' class="' + @ImgClass + '"' END
		+ CASE WHEN @ImgID IS NULL THEN '' ELSE ' id="' + @ImgID + '"' END
		+ CASE WHEN @ImgHoverText IS NULL THEN '' ELSE ' title="' + @ImgHoverText + '"' END
		+ CASE WHEN @ImgAltText IS NULL THEN '' ELSE ' alt="' + @ImgAltText + '"' END
		+ '>'
	IF @ImgLink IS NOT NULL
		SET @returnStr = '<a href="' + CASE WHEN @ImgLinkProtocol IS NULL THEN 'http://' ELSE @ImgLinkProtocol END + @ImgLink + '">' + @returnStr + '</a>'
END

RETURN @returnStr
END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_Link_ImageWithProtocol] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[fn_GBL_Link_ImageWithProtocol] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[fn_GBL_Link_ImageWithProtocol] TO [cioc_vol_search_role]
GO
