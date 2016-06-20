SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_VOL_VNUMToSocialMedia_Web](
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

SET @conStr = '<br>'

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ '<img src="' + IconURL16 + '"'
		+ ' alt="' + REPLACE(Name,'"','""') + '"'
		+ ' width="16px" height="16px">&nbsp;'
		+ Name + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
		+ cioc_shared.dbo.fn_SHR_GBL_Link_URL(Protocol,URL,0)
	FROM dbo.fn_VOL_VNUMToSocialMedia_rst(@VNUM)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO


GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSocialMedia_Web] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSocialMedia_Web] TO [cioc_vol_search_role]
GO
