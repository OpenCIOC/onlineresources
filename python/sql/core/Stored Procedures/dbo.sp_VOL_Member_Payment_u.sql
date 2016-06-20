SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Member_Payment_u]
	@VMPMT_ID [int],
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@PaymentDate [smalldatetime],
	@PaymentAmount [decimal](9, 2),
	@PaymentVoid [bit],
	@Notes [varchar](255),
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
		@InvoiceObjectName nvarchar(100),
		@PaymentObjectName nvarchar(100),
		@VolMemberObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @InvoiceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Invoice')
SET @PaymentObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Payment')
SET @VolMemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Member')

DECLARE @VMEM_ID int
SELECT @VMEM_ID = VMEM_ID
	FROM VOL_Member_Invoice vmi
	INNER JOIN VOL_Member_Payment vmp
		ON vmi.VMINV_ID=vmp.VMINV_ID
WHERE vmp.VMPMT_ID=@VMPMT_ID

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @VolMemberObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Payment ID given ?
END ELSE IF @VMPMT_ID IS NULL BEGIN
	SET @Error = 2 -- ID can't be NULL
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @InvoiceObjectName, NULL)
-- Payment ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Member_Payment WHERE VMPMT_ID=@VMPMT_ID) BEGIN
	SET @Error = 3 -- ID not found
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@VMPMT_ID AS nvarchar), @InvoiceObjectName)
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
-- Payment date given ?
END ELSE IF @PaymentDate IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Payment Date'), @PaymentObjectName)
-- Payment Amount given ?
END ELSE IF @PaymentAmount IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Payment Amount'), @PaymentObjectName)
-- Payment Amount valid ?
END ELSE IF @PaymentAmount <= 0 BEGIN
	SET @Error = 22 -- Invalid value
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PaymentAmount AS nvarchar(30)), @PaymentObjectName)
END ELSE BEGIN
	UPDATE VOL_Member_Payment SET MODIFIED_DATE=GetDate(),MODIFIED_BY=@MODIFIED_BY,PaymentDate=@PaymentDate, PaymentAmount=@PaymentAmount, 
			PaymentVoid=@PaymentVoid, Notes=@Notes 
		WHERE VMPMT_ID=@VMPMT_ID

	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PaymentObjectName, @ErrMsg OUTPUT

END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Member_Payment_u] TO [cioc_login_role]
GO
