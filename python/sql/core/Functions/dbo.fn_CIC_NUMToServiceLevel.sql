SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToServiceLevel](
	@NUM varchar(8),
	@LangID smallint
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr	nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID)

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ '(' + CAST(sl.ServiceLevelCode AS varchar) + ')'
		+ CASE WHEN sln.Name IS NULL THEN '' ELSE ' ' + sln.Name END
	FROM CIC_BT_SL AS pr
	INNER JOIN CIC_ServiceLevel sl
		ON pr.SL_ID = sl.SL_ID
	LEFT JOIN CIC_ServiceLevel_Name sln
		ON sl.SL_ID=sln.SL_ID AND LangID=@LangID
WHERE NUM = @NUM
ORDER BY sl.ServiceLevelCode

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END




GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToServiceLevel] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToServiceLevel] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToServiceLevel] TO [cioc_maintenance_role]
GO
