SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_VOL_VNUMToSocialMedia](
	@VNUM varchar(10)
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

SET @conStr = CHAR(13) + CHAR(10)

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ Name + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
		+ CASE WHEN Protocol='http://' THEN '' ELSE Protocol END + URL
	FROM dbo.fn_VOL_VNUMToSocialMedia_rst(@VNUM)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END





GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSocialMedia] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSocialMedia] TO [cioc_vol_search_role]
GO
