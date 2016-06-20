SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [dbo].[fn_VOL_VNUMToSocialMedia_Icon](
	@VNUM varchar(10),
	@PathToStart varchar(50)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

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
	FROM dbo.fn_VOL_VNUMToSocialMedia_rst(@VNUM)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO


GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSocialMedia_Icon] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSocialMedia_Icon] TO [cioc_vol_search_role]
GO
