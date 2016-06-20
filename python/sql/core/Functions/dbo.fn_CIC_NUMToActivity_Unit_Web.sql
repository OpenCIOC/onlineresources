SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToActivity_Unit_Web](
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

DECLARE	@returnStr	nvarchar(max)

SET @returnStr = '<table border="1" class="BasicBorder cell-padding-2">'
	/* Activity Name */
	+ '<tr><th colspan="2" class="TitleBox" style="text-align:left">'
			+ cioc_shared.dbo.fn_SHR_STP_ObjectName('Activity') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
			+ @ActivityName
			+ '</th></tr>'
	/* Status */
	+ CASE WHEN @Status IS NULL
		THEN ''
		ELSE '<tr><td class="FieldLabelLeftClr">'
			+ cioc_shared.dbo.fn_SHR_STP_ObjectName('Status') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
			+ '</td><td>'
			+ @Status
			+ '</td></tr>'
		END
	/* Activity Details */
	+ CASE
		WHEN @ActivityDescription IS NULL
		THEN ''
		ELSE '<tr><td class="FieldLabelLeftClr">' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Activity Details')
			+ '</td><td>'
			+ @ActivityDescription
			+ '</td></tr>'
		END
	/* Notes */
	+ CASE 
		WHEN @Notes IS NULL
		THEN ''
		ELSE '<tr><td class="FieldLabelLeftClr">' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Notes')
			+ '</td><td>'
			+ @Notes
			+ '</td></tr>'
	END
	+ '</table>'

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END
GO
