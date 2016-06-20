SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_OrgLocationService_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 20-Jan-2013
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

SELECT ols.OLS_ID, ols.Code, ISNULL(olsn.Name,ols.Code) AS OrgLocationService
	FROM GBL_OrgLocationService ols
	LEFT JOIN GBL_OrgLocationService_Name olsn
		ON ols.OLS_ID=olsn.OLS_ID AND olsn.LangID=@@LANGID
ORDER BY ols.DisplayOrder, ISNULL(olsn.Name,ols.Code)

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_OrgLocationService_l] TO [cioc_login_role]
GO
