SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_Reminders](
	@User_ID int,
	@LangID smallint,
	@Today smalldatetime
)
RETURNS xml WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 12-Nov-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnVal xml,
		@MemberID int,
		@AgencyCode char(3)

SET @returnVal = (
	SELECT	COUNT(*) AS Total,
			SUM(CASE WHEN DueDate IS NOT NULL AND DueDate<=@Today THEN 1 ELSE 0 END) AS PastDue
	FROM GBL_Reminder reminders
		WHERE Dismissed=0 
			AND NOT EXISTS(SELECT * FROM GBL_Reminder_User_Dismiss WHERE ReminderID=reminders.ReminderID AND User_ID=@User_ID)
			AND (reminders.LangID IS NULL OR reminders.LangID=@LangID)
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
GRANT EXECUTE ON  [dbo].[fn_GBL_Reminders] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_Reminders] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_Reminders] TO [cioc_vol_search_role]
GO
