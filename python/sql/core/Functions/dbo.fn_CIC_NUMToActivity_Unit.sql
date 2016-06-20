SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToActivity_Unit](
	@Status nvarchar(100),
	@ActivityName nvarchar(100),
	@ActivityDescription nvarchar(max),
	@Notes nvarchar(max)
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

DECLARE	@newLine char(2),
		@returnStr	nvarchar(max)

SET @newLine = CHAR(13) + CHAR(10)

SET @returnStr = 
	/* Status */
	CASE WHEN @Status IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Status') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + @Status + @newLine END
	/* Activity Name */
	+ cioc_shared.dbo.fn_SHR_STP_ObjectName('Activity') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + @ActivityName + @newLine
	/* Activity Details */
	+ CASE
		WHEN @ActivityDescription IS NULL
		THEN ''
		ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Activity Details') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + @ActivityDescription + @newLine
		END
	/* Notes */
	+ CASE 
		WHEN @Notes IS NULL
		THEN ''
		ELSE @newLine + cioc_shared.dbo.fn_SHR_STP_ObjectName('Notes') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + @Notes
	END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToActivity_Unit] TO [cioc_login_role]
GO
