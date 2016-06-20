SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_SearchTips_d]
	@SearchTipsID int,
	@MemberID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@SearchTipsObjectName nvarchar(60)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SearchTipsObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Search Tips')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Search Tips ID given ?
END ELSE IF @SearchTipsID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SearchTipsObjectName, NULL)
-- Search Tips exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SearchTips WHERE SearchTipsID=@SearchTipsID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SearchTipsID AS varchar), @SearchTipsObjectName)
-- Search Tips belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_SearchTips WHERE SearchTipsID=@SearchTipsID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- In use by a View ?
END ELSE IF EXISTS (SELECT * FROM CIC_View_Description WHERE SearchTips=@SearchTipsID)
		OR EXISTS (SELECT * FROM VOL_View_Description WHERE SearchTips=@SearchTipsID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SearchTipsObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('View'))
END ELSE BEGIN
	DELETE GBL_SearchTips WHERE SearchTipsID=@SearchTipsID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SearchTipsObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SearchTips_d] TO [cioc_login_role]
GO
