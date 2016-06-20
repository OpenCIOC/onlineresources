SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_FullEmployeesRange](
	@EMPLOYEES_RANGE int
)
RETURNS varchar(100) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @returnStr varchar(100)

SELECT @returnStr = CAST(MinNumber AS varchar) + ISNULL((SELECT '-' + CAST(MIN(MinNumber) - 1 AS varchar)
		FROM CIC_EmployeeRange WHERE MinNumber > er.MinNumber), '+')
FROM CIC_EmployeeRange er
WHERE ER_ID=@EMPLOYEES_RANGE

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_FullEmployeesRange] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_FullEmployeesRange] TO [cioc_login_role]
GO
