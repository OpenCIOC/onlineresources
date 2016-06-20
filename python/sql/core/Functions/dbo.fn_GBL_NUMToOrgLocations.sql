
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GBL_NUMToOrgLocations](
	@NUM varchar(8),
	@ViewType int,
	@ShowNotInView bit
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5.3
	Checked by: KL
	Checked on: 11-Jun-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = ' * '

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
	+ CASE WHEN Deleted=1 THEN '[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Deleted') + ' - ' ELSE '' END
	+ os.ORG_NAME
	+ CASE WHEN Deleted=1 THEN ']' ELSE '' END
	FROM dbo.fn_GBL_NUMToOrgLocations_rst(@NUM,@ViewType,@ShowNotInView) os
ORDER BY CASE WHEN os.Deleted=1 THEN 1 ELSE 0 END, os.ORG_NAME

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO

GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToOrgLocations] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToOrgLocations] TO [cioc_login_role]
GO
