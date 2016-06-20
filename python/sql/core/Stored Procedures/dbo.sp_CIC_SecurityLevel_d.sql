SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_SecurityLevel_d]
	@SL_ID int,
	@MemberID int,
	@AgencyCode char(3),
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
		@SecurityLevelObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SecurityLevelObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User Type')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Security Level ID given?
END ELSE IF @SL_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SecurityLevelObjectName, NULL)
-- Security Level exists ?
END ELSE IF @SL_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM CIC_SecurityLevel WHERE SL_ID = @SL_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SL_ID AS varchar), @SecurityLevelObjectName)
-- Security Level belongs to Member ?
END ELSE IF @SL_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM CIC_SecurityLevel WHERE SL_ID=@SL_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND @SL_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_SecurityLevel WHERE SL_ID=@SL_ID AND (Owner=@AgencyCode OR Owner IS NULL)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SecurityLevelObjectName, NULL)
END ELSE BEGIN
	DELETE CIC_SecurityLevel WHERE SL_ID = @SL_ID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SecurityLevelObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_SecurityLevel_d] TO [cioc_login_role]
GO
