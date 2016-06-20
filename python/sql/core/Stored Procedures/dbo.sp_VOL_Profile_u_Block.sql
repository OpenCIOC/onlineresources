SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_u_Block]
	@MemberID int,
	@ProfileID uniqueidentifier,
	@Blocked bit,
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

DECLARE	@MemberObjectName	nvarchar(60),
		@VolunteerProfileObjectName	nvarchar(50)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @VolunteerProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Profile')

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
-- Profile ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 14 -- No Such Login
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar(38)), NULL)
END ELSE BEGIN
	UPDATE VOL_Profile
		SET Blocked = @Blocked
	WHERE ProfileID=@ProfileID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolunteerProfileObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Block] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_u_Block] TO [cioc_vol_search_role]
GO
