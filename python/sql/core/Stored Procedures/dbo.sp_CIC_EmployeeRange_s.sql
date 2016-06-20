SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_EmployeeRange_s]
	@ER_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action:	NO ACTION REQUIRED
*/

SELECT CAST(MinNumber AS varchar)
		+ ISNULL((SELECT '-' + CAST(MIN(MinNumber) - 1 AS varchar) FROM CIC_EmployeeRange WHERE MinNumber > er.MinNumber), '+') AS Range
	FROM CIC_EmployeeRange er
WHERE ER_ID=@ER_ID

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_EmployeeRange_s] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_EmployeeRange_s] TO [cioc_login_role]
GO
