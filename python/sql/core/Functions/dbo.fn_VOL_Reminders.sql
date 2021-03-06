SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_VOL_Reminders](
	@VNUM varchar(10),
	@User_ID int,
	@LangID smallint,
	@Today smalldatetime
)
RETURNS xml WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@returnVal xml,
		@MemberID int,
		@AgencyCode char(3)

SET @returnVal = (SELECT COUNT(*) AS Total, SUM(CASE WHEN DueDate IS NOT NULL AND  DueDate<=GETDATE() THEN 1 ELSE 0 END) AS PastDue
	FROM GBL_Reminder reminders
		WHERE Dismissed=0 
			AND NOT EXISTS(SELECT * FROM GBL_Reminder_User_Dismiss WHERE ReminderID=reminders.ReminderID AND User_ID=@User_ID)
			AND EXISTS(SELECT * FROM VOL_OP_Reminder WHERE reminders.ReminderID=ReminderID AND VNUM=@VNUM)
			AND (LangID IS NULL OR LangID=@LangID)
			AND (reminders.ActiveDate IS NULL OR reminders.ActiveDate <= @Today)
			AND (
				(reminders.UserID=@User_ID
					AND NOT EXISTS(SELECT * FROM GBL_Reminder_Agency ra WHERE ra.ReminderID=reminders.ReminderID)
					AND NOT EXISTS(SELECT * FROM GBL_Reminder_User ru WHERE ru.ReminderID=reminders.ReminderID)
				)
				OR EXISTS(SELECT *
					FROM GBL_Reminder_Agency ra 
					INNER JOIN GBL_Agency a
						ON ra.AgencyID=a.AgencyID
					INNER JOIN GBL_Users u
						ON u.Agency = a.AgencyCode
					WHERE ra.ReminderID=reminders.ReminderID AND u.User_ID=@User_ID)
				OR EXISTS(SELECT *
					FROM GBL_Reminder_User ru
					WHERE ru.ReminderID=reminders.ReminderID AND ru.User_ID=@User_ID)
			)
	FOR XML AUTO,TYPE
)

RETURN @returnVal

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_Reminders] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_Reminders] TO [cioc_vol_search_role]
GO
