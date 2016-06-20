
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_GHIDToWhereClause](
	@GH_ID int
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 30-Sep-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(7),
		@returnStr nvarchar(max)

SET @conStr = ''

SET @returnStr = dbo.fn_CIC_GHIDToWhereClause_AllOrAny(@GH_ID,1)

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr <> '' SET @conStr = ') AND ('

SET @returnStr = @returnStr + ISNULL(@conStr + dbo.fn_CIC_GHIDToWhereClause_AllOrAny(@GH_ID,0),'')

IF @returnStr = '' BEGIN
	SET @returnStr = NULL
END ELSE IF @returnStr IS NOT NULL BEGIN
	SET @returnStr = '(' + @returnStr + ')'
END

RETURN @returnStr

END

GO

GRANT EXECUTE ON  [dbo].[fn_CIC_GHIDToWhereClause] TO [cioc_login_role]
GO
