SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_ProfileIDToInterestSrchList](
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

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + CAST(AI_ID AS varchar)
	FROM VOL_Profile_AI
WHERE ProfileID = @ProfileID
ORDER BY AI_ID

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_ProfileIDToInterestSrchList] TO [cioc_vol_search_role]
GO
