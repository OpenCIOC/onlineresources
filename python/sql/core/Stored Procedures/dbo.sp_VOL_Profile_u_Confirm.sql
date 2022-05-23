SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_u_Confirm]
	@MemberID int,
	@ProfileID [uniqueidentifier],
	@ConfirmationToken char(32),
	@FromEmail varchar(100) OUTPUT,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error int
SET @Error = 0

DECLARE	@VolunteerProfileObjectName nvarchar(60)

SET @VolunteerProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Profile')

DECLARE @ConfirmationDate smalldatetime
SELECT @ConfirmationDate=ConfirmationDate FROM VOL_Profile WHERE ProfileID=@ProfileID

DECLARE @NewEmail nvarchar(100)
SELECT @NewEmail = NewEmail FROM VOL_Profile WHERE ProfileID=@ProfileID

-- Profile ID given ?
IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar(100)), @VolunteerProfileObjectName)
-- Profile Blocked ?
END ELSE IF EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID AND Blocked=1) BEGIN
	SET @Error = 19 -- Blocked
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
-- Not waiting a confirmation
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID AND ConfirmationToken IS NOT NULL) BEGIN
	SET @Error = 15 -- No Confirmation
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
-- Confirmation Token does not match
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID AND ConfirmationToken=@ConfirmationToken) BEGIN
	SET @Error = 8 -- Confirmation Failure - Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)	
-- Confirmation Token too old
END ELSE IF DATEDIFF(dd, @ConfirmationDate, GetDate()) > 14 BEGIN
	SET @Error = 16 -- Confirmation Too Old
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END ELSE IF @NewEmail IS NOT NULL AND EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID<>@ProfileID AND MemberID=@MemberID AND Email=@NewEmail) BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NewEmail, @VolunteerProfileObjectName)
END ELSE BEGIN
	UPDATE VOL_Profile SET
		MODIFIED_DATE		= GETDATE(),
		Email				= ISNULL([NewEmail], [Email]),
		ConfirmationToken	= NULL,
		ConfirmationDate	= NULL,
		NewEmail			= NULL,
		Active				= 1,
		Verified			= 1
	WHERE ProfileID=@ProfileID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolunteerProfileObjectName, @ErrMsg
	
	IF @Error = 0 BEGIN
		SELECT @FromEmail = Email FROM VOL_Profile WHERE ProfileID=@ProfileID
	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Confirm] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Confirm] TO [cioc_vol_search_role]
GO
