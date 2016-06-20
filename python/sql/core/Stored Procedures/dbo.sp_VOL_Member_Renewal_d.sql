SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Member_Renewal_d]
	@VMR_ID int,
	@MemberID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE @MemberObjectName nvarchar(100),
		@MembershipRenewalObjectName nvarchar(100),
		@VolMemberObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @MembershipRenewalObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Membership Renewal')
SET @VolMemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Member')

DECLARE @VMEM_ID int
SELECT @VMEM_ID = VMEM_ID FROM VOL_Member_Renewal WHERE VMR_ID=@VMR_ID

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @VolMemberObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Renewal ID given ?
END ELSE IF @VMR_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MembershipRenewalObjectName, NULL)
-- Renewal ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Member_Renewal WHERE VMR_ID=@VMR_ID) BEGIN
	SET @Error = 3 -- ID not found
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@VMR_ID AS nvarchar), @MembershipRenewalObjectName)
-- Vol Member ID given ?
END ELSE IF @VMEM_ID IS NULL BEGIN
	SET @Error = 2 -- ID cannot be NULL
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolMemberObjectName, NULL)
-- Vol Member exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Member WHERE VMEM_ID=@VMEM_ID) BEGIN
	SET @Error = 3 -- No record with ID
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@VMEM_ID AS nvarchar), @VolMemberObjectName)
-- Vol Member belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Member WHERE VMEM_ID=@VMEM_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE BEGIN
	DELETE VOL_Member_Renewal WHERE VMR_ID=@VMR_ID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @MembershipRenewalObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Member_Renewal_d] TO [cioc_login_role]
GO
