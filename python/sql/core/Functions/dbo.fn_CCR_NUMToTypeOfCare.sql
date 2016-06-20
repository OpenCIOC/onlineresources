SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CCR_NUMToTypeOfCare](
	@NUM varchar(8),
	@Notes nvarchar(max),
	@LangID smallint
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

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID)

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + toc.TypeOfCare
		+ CASE WHEN toc.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' - ',@LangID) + toc.Notes END
	FROM dbo.fn_CCR_NUMToTypeOfCare_rst(@NUM,@LangID) toc

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @Notes IS NOT NULL BEGIN
	SELECT @returnStr = @returnStr + @conStr + @Notes
END

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CCR_NUMToTypeOfCare] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CCR_NUMToTypeOfCare] TO [cioc_login_role]
GO
