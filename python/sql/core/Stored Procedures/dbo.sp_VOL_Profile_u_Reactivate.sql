SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_u_Reactivate]
	@MemberID [int],
	@ProfileID [uniqueidentifier] OUTPUT,
	@Email varchar(60),
	@ConfirmationToken char(32),
	@FromEmail varchar(60) OUTPUT,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@VolunteerProfileObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @VolunteerProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Profile')

SET @Email = RTRIM(LTRIM(@Email))
IF @Email = '' SET @Email = NULL

IF @ProfileID IS NULL BEGIN
	SELECT @ProfileID=ProfileID FROM VOL_Profile WHERE Email=@Email AND MemberID=@MemberID
END

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
-- Inactive and not blocked
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE [Email]=@Email AND MemberID=@MemberID AND Active=0 AND Blocked=0) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Email, @VolunteerProfileObjectName)
-- Confirmation Token given ?
END ELSE IF @ConfirmationToken IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Confirmation Token'), @VolunteerProfileObjectName)
END ELSE BEGIN
	UPDATE VOL_Profile SET 
		ConfirmationToken = @ConfirmationToken,
		ConfirmationDate = GETDATE()
	WHERE Email=@Email
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolunteerProfileObjectName, @ErrMsg
	
	IF @Error=0 BEGIN
		SELECT @ProfileID=ProfileID FROM VOL_Profile WHERE Email=@Email
	END
	
	SELECT @FromEmail = DefaultEmailVOLProfile FROM STP_Member WHERE MemberID=@MemberID
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Reactivate] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Reactivate] TO [cioc_vol_search_role]
GO
