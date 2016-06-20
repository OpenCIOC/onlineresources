SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Template_Layout_d]
	@LayoutID [int] OUTPUT,
	@MemberID int,
	@AgencyCode [char](3),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 16-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@LayoutObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @LayoutObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Template Layout')


-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Layout given ?
END ELSE IF @LayoutID IS NULL BEGIN
	SET @Error = 10 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LayoutObjectName, NULL)
-- Layout exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Template_Layout WHERE LayoutID=@LayoutID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@LayoutID AS varchar), @LayoutObjectName)
-- Not a System Layout ?
END ELSE IF EXISTS (SELECT * FROM GBL_Template_Layout WHERE LayoutID=@LayoutID AND SystemLayout=1) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('System Layout'), NULL)
-- Layout belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Template_Layout WHERE LayoutID=@LayoutID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Template_Layout WHERE LayoutID=@LayoutID AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LayoutObjectName, NULL)
-- In use by a Template ?
END ELSE IF EXISTS(SELECT * FROM GBL_Template WHERE HeaderLayout=@LayoutID OR FooterLayout=@LayoutID OR SearchLayoutCIC=@LayoutID OR SearchLayoutVOL=@LayoutID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LayoutObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Design Template'))
END

IF @Error = 0 BEGIN
	DELETE FROM GBL_Template_Layout
	WHERE LayoutID=@LayoutID
		
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @LayoutObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Template_Layout_d] TO [cioc_login_role]
GO
