
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_OrgLocationService_u]
	@NUM varchar(8),
	@Codes xml
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.2
	Checked by: CL
	Checked on: 26-Oct-2014
	Action: NO ACTION REQUIRED
*/
DECLARE @OLSIDs table (OLS_ID int)

INSERT INTO @OLSIDs 
SELECT ols.OLS_ID
FROM @Codes.nodes('//CD') as T(N)
INNER JOIN GBL_OrgLocationService ols
	ON ols.Code=N.value('@V', 'nvarchar(50)')


DELETE ols FROM GBL_BT_OLS ols WHERE NUM=@NUM AND NOT EXISTS(SELECT * FROM @OLSIDs WHERE OLS_ID=ols.OLS_ID)

INSERT INTO GBL_BT_OLS (NUM, OLS_ID)
SELECT @NUM, OLS_ID
FROM @OLSIDs ols WHERE NOT EXISTS(SELECT * FROM GBL_BT_OLS WHERE NUM=@NUM AND OLS_ID=ols.OLS_ID)

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_OrgLocationService_u] TO [cioc_login_role]
GO
