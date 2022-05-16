SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_Profile_u_Unsubscribe]
	@MemberID [INT],
	@Email [VARCHAR](60),
	@UnsubscribeToken [VARCHAR](36),
	@ErrMsg [NVARCHAR](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName NVARCHAR(100),
		@LanguageObjectName NVARCHAR(100),
		@VolunteerProfileObjectName NVARCHAR(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @VolunteerProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Profile')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS VARCHAR), @MemberObjectName)
-- Profile ID given ?
END ELSE IF @Email IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
END ELSE IF @UnsubscribeToken IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
-- Profile is Active and not Blocked ?
END ELSE IF (SELECT COUNT(*) FROM VOL_Profile WHERE Email=@Email AND UnsubscribeToken=@UnsubscribeToken AND MemberID=@MemberID) > 1 BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
END ELSE BEGIN
	UPDATE VOL_Profile SET
		MODIFIED_DATE		= GETDATE(),
		NotifyNew			= 0,
		NotifyUpdated		= 0,
		OrgCanContact		= 0
	WHERE Email=@Email AND UnsubscribeToken=@UnsubscribeToken AND MemberID=@MemberID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolunteerProfileObjectName, @ErrMsg OUTPUT
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Unsubscribe] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Unsubscribe] TO [cioc_vol_search_role]
GO
