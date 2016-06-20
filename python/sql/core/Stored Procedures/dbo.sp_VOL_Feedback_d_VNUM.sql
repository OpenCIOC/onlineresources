SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Feedback_d_VNUM]
	@VNUM varchar(10),
	@LangID smallint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

IF @VNUM IS NOT NULL BEGIN
	DELETE VOL_Feedback
	WHERE VNUM = @VNUM
		AND (LangID=@LangID OR (@LangID=0 AND LangID IS NULL))
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Feedback_d_VNUM] TO [cioc_login_role]
GO
