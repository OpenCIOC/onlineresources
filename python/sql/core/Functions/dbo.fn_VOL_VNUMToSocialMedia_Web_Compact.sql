SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_VOL_VNUMToSocialMedia_Web_Compact](
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

DECLARE	@conStr	nvarchar(8),
		@returnStr	nvarchar(max)

SET @conStr = ', '

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ '<img src="' + IconURL16 + '"'
		+ ' alt="' + REPLACE(Name,'"','""') + '"'
		+ ' width="16px" height="16px">&nbsp;'
		+ '<a href="' + Protocol + URL + '">' + Name + '</a>'
	FROM dbo.fn_VOL_VNUMToSocialMedia_rst(@VNUM)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END



GO


GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSocialMedia_Web_Compact] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSocialMedia_Web_Compact] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSocialMedia_Web_Compact] TO [cioc_vol_search_role]
GO
