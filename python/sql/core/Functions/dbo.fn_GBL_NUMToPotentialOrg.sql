SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GBL_NUMToPotentialOrg](
	@NUM varchar(8),
	@ORG_NUM varchar(8)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 06-Oct-2013
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = CHAR(13) + CHAR(10)

IF @ORG_NUM IS NULL BEGIN
	SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') 
			+ po.ORG_NAME_FULL + ' (' + po.NUM + ')'
		FROM dbo.fn_GBL_NUMToPotentialOrg_rst(@NUM) po

	IF @returnStr = '' SET @returnStr = NULL
END

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToPotentialOrg] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToPotentialOrg] TO [cioc_login_role]
GO
