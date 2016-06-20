SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrivacyProfile_d]
	@ProfileID int,
	@MemberID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@ProfileObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')

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
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrivacyProfile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @ProfileObjectName)
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrivacyProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Profile in use ?
END ELSE IF EXISTS (SELECT * FROM GBL_BaseTable WHERE PRIVACY_PROFILE = @ProfileID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record'))
END ELSE BEGIN
	DELETE GBL_PrivacyProfile WHERE ProfileID = @ProfileID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrivacyProfile_d] TO [cioc_login_role]
GO
