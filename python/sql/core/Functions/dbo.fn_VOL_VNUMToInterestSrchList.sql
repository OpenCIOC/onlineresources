SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToInterestSrchList](
	@VNUM varchar(10)
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@conStr varchar(3),
		@returnStr varchar(max)

SET @conStr = ','

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + CAST(AI_ID AS varchar)
	FROM VOL_OP_AI
WHERE VNUM = @VNUM
ORDER BY AI_ID

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToInterestSrchList] TO [cioc_vol_search_role]
GO
