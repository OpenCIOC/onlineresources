SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_InclusionPolicy_d]
	@InclusionPolicyID int,
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
		@InclusionPolicyObjectName nvarchar(60)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @InclusionPolicyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Inclusion Policy')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Inclusion Policy ID given ?
END ELSE IF @InclusionPolicyID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @InclusionPolicyObjectName, NULL)
-- Inclusion Policy exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_InclusionPolicy WHERE InclusionPolicyID=@InclusionPolicyID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@InclusionPolicyID AS varchar), @InclusionPolicyObjectName)
-- Inclusion Policy belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_InclusionPolicy WHERE InclusionPolicyID=@InclusionPolicyID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- In use by a View ?
END ELSE IF EXISTS (SELECT * FROM CIC_View_Description WHERE InclusionPolicy=@InclusionPolicyID)
		OR EXISTS (SELECT * FROM VOL_View_Description WHERE InclusionPolicy=@InclusionPolicyID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @InclusionPolicyObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('View'))
END ELSE BEGIN
	DELETE GBL_InclusionPolicy WHERE InclusionPolicyID=@InclusionPolicyID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @InclusionPolicyObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_InclusionPolicy_d] TO [cioc_login_role]
GO
