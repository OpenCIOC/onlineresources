SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_View_d]
	@ViewType [int],
	@MemberID [int],
	@AgencyCode [char](3),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 13-Jan-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@NameObjectName nvarchar(100)
		
SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')


-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- View given ?
END ELSE IF @ViewType IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- View exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE MemberID=@MemberID AND ViewType=@ViewType) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType AND (Owner IS NULL OR Owner = @AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- Is a Default View ?
END ELSE IF EXISTS(SELECT * FROM STP_Member WHERE DefaultViewCIC=@ViewType) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Default View'))
-- Used by a User Type ?
END ELSE IF EXISTS(SELECT * FROM CIC_SecurityLevel WHERE ViewType=@ViewType) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Security Level'))
END ELSE BEGIN
	
	DELETE FROM CIC_View_Recurse
	WHERE CanSee = @ViewType

	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg
	
	DELETE FROM CIC_View 
	WHERE ViewType=@ViewType
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg

END

RETURN @Error

SET NOCOUNT OFF








GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_d] TO [cioc_login_role]
GO
