SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_RecordNote_CheckModule](
	@GblNoteType varchar(100),
	@GblNUM varchar(8), 
	@VolNoteType varchar(1),
	@VolVNUM varchar(10)
)
RETURNS bit WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

RETURN CASE
	WHEN (@GblNoteType IS NOT NULL AND @VolNoteType IS NULL AND @GblNUM IS NOT NULL AND @VolVNUM IS NULL) THEN 0
	WHEN (@GblNoteType IS NULL AND @VolNoteType IS NOT NULL AND @GblNUM IS NULL AND @VolVNUM IS NOT NULL) THEN 0
	ELSE -1 END

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_RecordNote_CheckModule] TO [cioc_login_role]
GO
