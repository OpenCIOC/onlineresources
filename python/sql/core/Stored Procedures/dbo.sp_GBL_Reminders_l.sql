SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Reminders_l]
	@User_ID int,
	@NUM varchar(8) = NULL,
	@VNUM varchar(10) = NULL
WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

SELECT reminders.*,
		rnt.HighPriority,
		rntn.Name,
		(SELECT User_ID, UserName
			FROM GBL_Users [user] 
			WHERE EXISTS(SELECT * FROM GBL_Reminder_User ru WHERE reminders.ReminderID=ru.ReminderID AND [user].User_ID=ru.User_ID)
			ORDER BY UserName
			FOR XML PATH('user'), ROOT('users'), TYPE 
		) AS Users,
		(SELECT agency.AgencyID, agency.AgencyCode
			FROM GBL_Agency agency
			WHERE EXISTS(SELECT * FROM GBL_Reminder_Agency WHERE ReminderID=reminders.ReminderID and AgencyID=agency.AgencyID)
			ORDER BY AgencyCode
			FOR XML PATH('agency'), ROOT('agencies'), TYPE
		) AS Agencies,
		(SELECT COUNT(*) FROM GBL_BT_Reminder WHERE ReminderID=reminders.ReminderID) AS NUMCount,
		(SELECT COUNT(*) FROM VOL_OP_Reminder WHERE ReminderID=reminders.ReminderID) AS VNUMCount,
		CASE WHEN reminders.Dismissed=1 OR EXISTS(SELECT * FROM GBL_Reminder_User_Dismiss WHERE ReminderID=reminders.ReminderID AND User_ID=@User_ID) THEN 1 ELSE 0 END AS Dismissed,
		ISNULL(reminders.DismissalDate, (SELECT TOP 1 DismissalDate FROM GBL_Reminder_User_Dismiss WHERE ReminderID=reminders.ReminderID AND User_ID=@User_ID)) AS DismissalDate,
		(SELECT UserName FROM GBL_Users u WHERE reminders.UserID=u.User_ID) AS UserName,
		CAST(CASE WHEN UserID=@User_ID
		AND NOT (
			EXISTS(SELECT *
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
		THEN 1 ELSE 0 END AS bit) AS ForOthers
	FROM GBL_Reminder reminders
	LEFT JOIN GBL_RecordNote_Type rnt
		ON reminders.NoteTypeID=rnt.NoteTypeID
	LEFT JOIN GBL_RecordNote_Type_Name rntn
		ON rnt.NoteTypeID=rntn.NoteTypeID
			AND rntn.LangID=(SELECT TOP 1 LangID FROM GBL_RecordNote_Type_Name WHERE NoteTypeID=rntn.NoteTypeID ORDER BY CASE WHEN LangID=ISNULL(reminders.LangID,@@LANGID) THEN 0 ELSE 1 END, LangID)
WHERE (@NUM IS NULL OR EXISTS(SELECT * FROM GBL_BT_Reminder WHERE reminders.ReminderID=ReminderID AND NUM=@NUM))
	AND (@VNUM IS NULL OR EXISTS(SELECT * FROM VOL_OP_Reminder WHERE reminders.ReminderID=ReminderID AND VNUM=@VNUM))
	AND (reminders.LangID IS NULL OR reminders.LangID=@@LANGID)
	AND (
		reminders.UserID=@User_ID
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
ORDER BY
	CASE
		-- Past Due First
		WHEN ISNULL(reminders.DueDate,CAST('2079-06-06 23:59:00' AS smalldatetime)) <= CAST(GETDATE() AS smalldatetime) THEN 0
		-- Current Second
		WHEN CAST(ISNULL(reminders.ActiveDate,GETDATE()) AS smalldatetime) <= CAST(GETDATE() AS smalldatetime) THEN 1
		-- Pending Last
		ELSE 2
	END,
	CASE WHEN UserID=@User_ID
		AND NOT (
			EXISTS(SELECT *
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
		THEN 1 ELSE 0 END,
	ISNULL(DueDate,CAST('2079-06-06 23:59:00' AS smalldatetime)),
	ISNULL(ActiveDate,GETDATE())
		
RETURN 0
	
END









GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Reminders_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Reminders_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Reminders_l] TO [cioc_vol_search_role]
GO
