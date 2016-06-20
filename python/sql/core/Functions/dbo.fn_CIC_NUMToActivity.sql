SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToActivity](
	@NUM varchar(8),
	@ACTIVITY_NOTES nvarchar(max)
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

DECLARE	@conStr	nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = CHAR(13) + CHAR(10)

SELECT @returnStr =  COALESCE(@returnStr + @conStr + @conStr,'') 
		+ dbo.fn_CIC_NUMToActivity_Unit(
			[Status],
			ActivityName,
			ActivityDescription,
			Notes
		)
	FROM dbo.fn_CIC_NUMToActivity_rst(@NUM)

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @ACTIVITY_NOTES IS NOT NULL BEGIN
	SELECT @returnStr = @returnStr + @conStr + @conStr + @ACTIVITY_NOTES
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToActivity] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToActivity] TO [cioc_login_role]
GO
