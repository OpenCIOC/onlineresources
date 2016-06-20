SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GBL_NUMToOrgLocationService_Web](
	@NUM varchar(8),
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ' ; ','')
		+ cioc_shared.dbo.fn_SHR_GBL_Link_OrgLocationService(ols.OLS_ID,ols.OrgLocationService,@HTTPVals,@PathToStart)
	FROM dbo.fn_GBL_NUMToOrgLocationService_rst(@NUM) ols

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToOrgLocationService_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToOrgLocationService_Web] TO [cioc_login_role]
GO
