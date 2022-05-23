SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_EmailUpdateOpportunities](
	@NUM varchar(8),
	@CONTACT_EMAIL varchar(100),
	@LangID smallint
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(', ',@LangID)

SET @CONTACT_EMAIL = RTRIM(LTRIM(@CONTACT_EMAIL))
IF @CONTACT_EMAIL = '' SET @CONTACT_EMAIL=NULL

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + ISNULL(POSITION_TITLE, '')
	FROM VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vod.VNUM ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
WHERE NUM = @NUM 
	AND (
		UPDATE_EMAIL = @CONTACT_EMAIL
		OR (
			UPDATE_EMAIL IS NULL
			AND EXISTS(SELECT * FROM GBL_Contact c WHERE VolContactType='CONTACT' AND VolVNUM=vo.VNUM AND EMAIL=@CONTACT_EMAIL)
			)
		)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_EmailUpdateOpportunities] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_EmailUpdateOpportunities] TO [cioc_vol_search_role]
GO
