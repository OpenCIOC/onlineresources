SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_Notify_Done]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 21-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @TodayAtMidnight smalldatetime
SET @TodayAtMidnight = CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, GETDATE())))

UPDATE STP_Member
	SET LastVolProfileEmailDate = @TodayAtMidnight
WHERE MemberID=@MemberID

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_Notify_Done] TO [cioc_maintenance_role]
GO
