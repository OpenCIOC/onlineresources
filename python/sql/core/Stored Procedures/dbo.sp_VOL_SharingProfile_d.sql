SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[sp_VOL_SharingProfile_d]
	@ProfileID [int],
	@MemberID [int],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 17-Apr-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@SharingProfileObjectName nvarchar(100),
		@FieldObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SharingProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Sharing Profile')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @SharingProfileObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID AND Domain=2) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @SharingProfileObjectName)
-- Profile belongs to member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE MemberID=@MemberID AND ProfileID=@ProfileID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID AND Active=0) BEGIN
	SET @Error = 7 -- Can't delete while value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SharingProfileObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Active'))
END ELSE BEGIN
	DELETE FROM GBL_SharingProfile
		WHERE ProfileID = @ProfileID	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SharingProfileObjectName, @ErrMsg
END


RETURN @Error

SET NOCOUNT OFF







GO
GRANT EXECUTE ON  [dbo].[sp_VOL_SharingProfile_d] TO [cioc_login_role]
GO
