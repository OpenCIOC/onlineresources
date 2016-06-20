SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_Community_s_Search](
	@CMList varchar(max)
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	varchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ',','') + CAST(CM_ID AS varchar)
	FROM dbo.fn_GBL_Community_Search_rst(@CMList)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_Community_s_Search] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_Community_s_Search] TO [cioc_vol_search_role]
GO
