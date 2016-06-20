SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Member_Renewal_i]
	@VMEM_ID [int],
	@MemberID int,
	@RenewalDate [smalldatetime],
	@NextRenewalDate [smalldatetime],
	@VMINV_ID [int],
	@ErrMsg [varchar](500) OUTPUT
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
		@InvoiceObjectName nvarchar(100),
		@VolMemberObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @MembershipRenewalObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Membership Renewal')
SET @InvoiceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Invoice')
SET @VolMemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Member')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @VolMemberObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
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
-- Renewal Date given ?
END ELSE IF @RenewalDate IS NULL BEGIN
	SET @Error = 10 -- Field required
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Renewal Date'), @MembershipRenewalObjectName)
-- Renwal Date already exists ?
END ELSE IF EXISTS(SELECT * FROM VOL_Member_Renewal WHERE VMEM_ID=@VMEM_ID AND RenewalDate=@RenewalDate) BEGIN
	SET @Error = 6 -- Value already in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_GBL_DateString(@RenewalDate), @MembershipRenewalObjectName)
-- Invoice exists ?
END ELSE IF @RenewalDate IS NOT NULL AND @VMINV_ID IS NOT NULL 
		AND NOT EXISTS(SELECT * FROM VOL_Member_Invoice WHERE VMEM_ID=@VMEM_ID AND VMINV_ID=@VMINV_ID) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@VMINV_ID AS nvarchar), @InvoiceObjectName)
END ELSE BEGIN
	IF @RenewalDate IS NOT NULL BEGIN
		INSERT INTO VOL_Member_Renewal ( VMEM_ID, RenewalDate, VMINV_ID )
			VALUES (@VMEM_ID, @RenewalDate, @VMINV_ID)
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @MembershipRenewalObjectName, @ErrMsg OUTPUT
	END

	UPDATE VOL_Member SET NextRenewalDate = @NextRenewalDate
	WHERE VMEM_ID=@VMEM_ID
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolMemberObjectName, @ErrMsg OUTPUT
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Member_Renewal_i] TO [cioc_login_role]
GO
