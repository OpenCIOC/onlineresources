SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CCR_NUMToTypeOfCare_Web](
	@NUM varchar(8),
	@Notes nvarchar(max),
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jul-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') 
		+ cioc_shared.dbo.fn_SHR_CCR_Link_TypeOfCare(toc.TOC_ID,toc.TypeOfCare,@HTTPVals,@PathToStart)
		+ CASE WHEN toc.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') + toc.Notes END
	FROM dbo.fn_CCR_NUMToTypeOfCare_rst(@NUM,@@LANGID) toc

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @Notes IS NOT NULL BEGIN
	SELECT @returnStr = @returnStr + @conStr + @Notes
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END



GO
GRANT EXECUTE ON  [dbo].[fn_CCR_NUMToTypeOfCare_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CCR_NUMToTypeOfCare_Web] TO [cioc_login_role]
GO
