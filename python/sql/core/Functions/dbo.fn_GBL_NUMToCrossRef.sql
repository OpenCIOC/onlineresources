SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMToCrossRef](
	@NUM varchar(8),
	@LangID smallint
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr	nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID)

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + OrgName
	FROM dbo.fn_GBL_NUMToCrossRef_rst(@NUM,@LangID)
ORDER BY OrgName

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToCrossRef] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToCrossRef] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToCrossRef] TO [cioc_vol_search_role]
GO
