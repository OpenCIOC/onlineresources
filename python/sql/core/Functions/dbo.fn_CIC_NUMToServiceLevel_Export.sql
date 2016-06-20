SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToServiceLevel_Export](
	@NUM varchar(8)
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr	nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') 
		+ CAST(fr.ServiceLevelCode AS varchar)
	FROM CIC_BT_SL AS pr
	INNER JOIN CIC_ServiceLevel AS fr
		ON pr.SL_ID = fr.SL_ID
WHERE NUM = @NUM
ORDER BY pr.SL_ID

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToServiceLevel_Export] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToServiceLevel_Export] TO [cioc_login_role]
GO
