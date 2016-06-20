SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_NUMToBusRoutes](
	@NUM varchar(8)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 10-Jun-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ' ; ','') + 
		CASE WHEN RouteName IS NULL
			THEN RouteNumber
			ELSE CASE
				WHEN RouteNumber IS NULL THEN ''
				ELSE RouteNumber + ' - '
			END + RouteName
		END
	FROM dbo.fn_CIC_NUMToBusRoutes_rst(@NUM) br

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToBusRoutes] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToBusRoutes] TO [cioc_login_role]
GO
