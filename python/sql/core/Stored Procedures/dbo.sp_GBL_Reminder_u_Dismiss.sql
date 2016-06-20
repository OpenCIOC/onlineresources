SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_GBL_Reminder_u_Dismiss]
	@ReminderID int OUTPUT,
	@MODIFIED_BY varchar(50),
	@User_ID int,
	@Dismissed bit,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: CL
	Checked on: 24-Oct-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@ReminderObjectName nvarchar(100)
		
SET @ReminderObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Reminder')


DECLARE @MemberID int
SELECT @MemberID=MemberID_Cache FROM GBL_Users WHERE User_ID=@User_ID

IF @ReminderID IS NULL BEGIN
	SET @Error = 2 -- No ID Provided
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ReminderObjectName, NULL)
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Reminder WHERE ReminderID=@ReminderID AND MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ReminderID AS varchar), @ReminderObjectName)
END ELSE BEGIN
	IF EXISTS(SELECT * FROM GBL_Reminder WHERE ReminderID=@ReminderID AND DismissForAll = 1) BEGIN
		UPDATE GBL_Reminder SET Dismissed=@Dismissed, DismissalDate=CASE WHEN @Dismissed=1 THEN GETDATE() ELSE NULL END, MODIFIED_BY=@MODIFIED_BY, MODIFIED_DATE=GETDATE() WHERE ReminderID=@ReminderID
	END ELSE BEGIN
		IF @Dismissed=0 BEGIN
			DELETE FROM GBL_Reminder_User_Dismiss WHERE ReminderID=@ReminderID AND User_ID=@User_ID
		END ELSE IF NOT EXISTS(SELECT * FROM GBL_Reminder_User_Dismiss WHERE ReminderID=@ReminderID AND User_ID=@User_ID) BEGIN
			INSERT INTO GBL_Reminder_User_Dismiss (ReminderID, User_ID)
				VALUES (@ReminderID, @User_ID)
		END
	END
END

RETURN @Error

SET NOCOUNT OFF








GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Reminder_u_Dismiss] TO [cioc_login_role]
GO
