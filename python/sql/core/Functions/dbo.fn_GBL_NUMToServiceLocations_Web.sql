
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_NUMToServiceLocations_Web](
	@NUM varchar(8),
	@ORG_NUM varchar(8),
	@ViewType int,
	@ShowNotInView bit,
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5.3
	Checked by: KL
	Checked on: 11-Jul-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(10),
		@returnStr nvarchar(max)

SET @conStr = '</li><li'

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ CASE WHEN sl.Deleted=1 THEN ' class="AlertStrike">' ELSE '>' END
		+ CASE
			WHEN sl.InView=1 THEN cioc_shared.dbo.fn_SHR_GBL_Link_Record(sl.NUM,sl.ORG_NAME,@HTTPVals,@PathToStart)
			ELSE sl.ORG_NAME
			END
	FROM dbo.fn_GBL_NUMToServiceLocations_rst(@NUM,@ORG_NUM,@ViewType,@ShowNotInView) sl
ORDER BY CASE WHEN sl.Deleted=1 THEN 1 ELSE 0 END, sl.ORG_NAME

IF @returnStr = '' BEGIN
	SET @returnStr = NULL
END ELSE BEGIN
	SET @returnStr = '<ul class="ServiceLocationList"><li' + @returnStr + '</li></ul>'
END

RETURN @returnStr

END



GO

GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToServiceLocations_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToServiceLocations_Web] TO [cioc_login_role]
GO
