SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_Community_s_Search_Exact](
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

SELECT @returnStr =  COALESCE(@returnStr + ',','') + CAST(cm.CM_ID AS varchar)
	FROM GBL_Community cm
	INNER JOIN (SELECT DISTINCT ItemID AS CM_ID FROM fn_GBL_ParseIntIDList(@CMList, ',')) tm
		ON tm.CM_ID=cm.CM_ID

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_Community_s_Search_Exact] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_Community_s_Search_Exact] TO [cioc_vol_search_role]
GO
