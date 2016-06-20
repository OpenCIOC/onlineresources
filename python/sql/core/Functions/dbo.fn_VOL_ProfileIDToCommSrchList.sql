SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_ProfileIDToCommSrchList](
	@ProfileID [uniqueidentifier]
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 05-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr varchar(3),
		@returnStr varchar(max)

SET @conStr = ','

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') +  CAST(CM_ID AS varchar)
	FROM VOL_Profile_CM
WHERE ProfileID=@ProfileID
ORDER BY CM_ID

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_ProfileIDToCommSrchList] TO [cioc_vol_search_role]
GO
