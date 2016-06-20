SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_FullEmployees](
	@EMPLOYEES_FT int,
	@EMPLOYEES_PT int,
	@EMPLOYEES_TOTAL int
)
RETURNS nvarchar(255) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @colonStr nvarchar(3),
		@returnStr	nvarchar(600)

SET @returnStr = ''
SET @colonStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')

IF @EMPLOYEES_FT <= 0 SET @EMPLOYEES_FT = NULL
IF @EMPLOYEES_PT <= 0 SET @EMPLOYEES_PT = NULL
IF @EMPLOYEES_TOTAL <= 0 SET @EMPLOYEES_TOTAL = NULL

SELECT @returnStr =
		CASE WHEN @EMPLOYEES_FT IS NOT NULL THEN
			cioc_shared.dbo.fn_SHR_STP_ObjectName('Full-time') + @colonStr + CAST(@EMPLOYEES_FT AS nvarchar) ELSE '' END
		+ CASE WHEN @EMPLOYEES_FT IS NOT NULL AND @EMPLOYEES_PT IS NOT NULL THEN '<BR>' ELSE '' END
		+ CASE WHEN @EMPLOYEES_PT IS NOT NULL THEN
			cioc_shared.dbo.fn_SHR_STP_ObjectName('Part-time / Seasonal') + @colonStr + CAST(@EMPLOYEES_PT AS nvarchar) ELSE '' END
		+ CASE WHEN @EMPLOYEES_FT IS NOT NULL OR @EMPLOYEES_PT IS NOT NULL THEN '<BR>' ELSE '' END
		+ CASE WHEN @EMPLOYEES_TOTAL IS NOT NULL THEN
			cioc_shared.dbo.fn_SHR_STP_ObjectName('Total Employees') + @colonStr + CAST(@EMPLOYEES_TOTAL AS nvarchar) ELSE '' END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_FullEmployees] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_FullEmployees] TO [cioc_login_role]
GO
