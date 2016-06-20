SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Reminder_sr]
	@ReminderID int,
	@User_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 14-Nov-2012
	Action: NO ACTION REQUIRED
*/

SELECT CASE WHEN LEN(Notes) > 150 THEN LEFT(Notes,150) + ' ...' ELSE Notes END AS ReminderName
	FROM GBL_Reminder rm
WHERE ReminderID=@ReminderID
	AND (
		rm.UserID=@User_ID
		OR EXISTS(SELECT *
			FROM GBL_Reminder_Agency ra 
			INNER JOIN GBL_Agency a
				ON ra.AgencyID=a.AgencyID
			INNER JOIN GBL_Users u
				ON u.Agency = a.AgencyCode
			WHERE ra.ReminderID=rm.ReminderID AND u.User_ID=@User_ID)
		OR EXISTS(SELECT *
			FROM GBL_Reminder_User ru
			WHERE ru.ReminderID=rm.ReminderID AND ru.User_ID=@User_ID)
	)
SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Reminder_sr] TO [cioc_login_role]
GO
