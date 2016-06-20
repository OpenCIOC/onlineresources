
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [dbo].[fn_GBL_NUMToLocationServices_Web](
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
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 16-Jul-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(10),
		@returnStr nvarchar(max)

SET @conStr = '</li><li'

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ CASE WHEN ls.Deleted=1 THEN ' class="AlertStrike">' ELSE '>' END
		+ CASE
			WHEN ls.InView=1 THEN cioc_shared.dbo.fn_SHR_GBL_Link_Record(ls.NUM,ls.ORG_NAME,@HTTPVals,@PathToStart)
			ELSE ls.ORG_NAME
			END
	FROM dbo.fn_GBL_NUMToLocationServices_rst(@NUM,@ORG_NUM,@ViewType,@ShowNotInView) ls
ORDER BY Deleted, ls.ORG_NAME

IF @returnStr = '' BEGIN
	SET @returnStr = NULL
END ELSE BEGIN
	SET @returnStr = '<ul class="ServiceLocationList"><li' + @returnStr + '</li></ul>'
END

RETURN @returnStr

END




GO


GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToLocationServices_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToLocationServices_Web] TO [cioc_login_role]
GO
