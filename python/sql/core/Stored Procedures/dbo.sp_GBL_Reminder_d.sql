SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_GBL_Reminder_d]
	@ReminderID [int],
	@User_ID int,
	@SuperUser bit,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: CL
	Checked on: 26-Oct-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@ReminderObjectName nvarchar(60)

SET @ReminderObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Reminder')

DECLARE @MemberID int

SELECT @MemberID = MemberID_Cache FROM GBL_Users WHERE User_ID=@User_ID

-- Reminder ID given ?
IF @ReminderID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ReminderObjectName, NULL)
-- Reminder ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Reminder WHERE ReminderID = @ReminderID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ReminderID AS varchar), @ReminderObjectName)
-- Correct Membership?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Reminder WHERE ReminderID=@ReminderID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ReminderObjectName, NULL)
END ELSE IF @SuperUser = 0 AND NOT EXISTS(SELECT * FROM GBL_Reminder WHERE ReminderID=@ReminderID AND UserID=@User_ID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ReminderObjectName, NULL)
END ELSE BEGIN
	DELETE GBL_Reminder
	WHERE (ReminderID = @ReminderID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ReminderObjectName, @ErrMsg
END			

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Reminder_d] TO [cioc_login_role]
GO
