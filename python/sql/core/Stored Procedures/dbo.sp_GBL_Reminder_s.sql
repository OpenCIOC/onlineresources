SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Reminder_s]
	@MemberID int,
	@ReminderID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

SELECT r.*, l.Culture 
	FROM GBL_Reminder r
	LEFT JOIN STP_Language l
		ON r.LangID=l.LangID
WHERE ReminderID=@ReminderID AND MemberID=@MemberID

SELECT ru.User_ID, u.UserName
	FROM GBL_Reminder_User ru
	INNER JOIN GBL_Users u
		ON u.User_ID=ru.User_ID
	WHERE ReminderID=@ReminderID
ORDER BY u.UserName

SELECT AgencyCode
	FROM GBL_Agency a
	INNER JOIN GBL_Reminder_Agency ra
		ON a.AgencyID=ra.AgencyID
	WHERE ReminderID=@ReminderID
ORDER BY AgencyCode

SELECT r.NUM, dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL
	FROM GBL_BT_Reminder r
	LEFT JOIN GBL_BaseTable bt
		ON r.NUM=bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE bt.NUM=NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE ReminderID=@ReminderID ORDER BY bt.NUM

SELECT r.VNUM, vod.POSITION_TITLE
	FROM VOL_OP_Reminder r
	LEFT JOIN VOL_Opportunity_Description vod
		ON r.VNUM=vod.VNUM AND LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vod.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE ReminderID=@ReminderID ORDER BY VNUM

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Reminder_s] TO [cioc_login_role]
GO
