SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Member_Invoice_u]
	@VMINV_ID [int],
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@InvoiceNumber [varchar](10),
	@InvoiceDate [smalldatetime],
	@PaymentDueDate [smalldatetime],
	@InvoiceAmount [decimal](9, 2),
	@InvoiceVoid [bit],
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
		@VolMemberObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @InvoiceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Invoice')
SET @VolMemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Member')

DECLARE @VMEM_ID int
SELECT @VMEM_ID = VMEM_ID FROM VOL_Member_Invoice WHERE VMINV_ID=@VMINV_ID

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @VolMemberObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Invoice ID given ?
END ELSE IF @VMINV_ID IS NULL BEGIN
	SET @Error = 2 -- ID can't be NULL
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @InvoiceObjectName, NULL)
-- Invoice ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Member_Invoice WHERE VMINV_ID=@VMINV_ID) BEGIN
	SET @Error = 3 -- ID not found
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@VMINV_ID AS nvarchar), @InvoiceObjectName)
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
-- Invoice Number already in use ?
END ELSE IF @InvoiceNumber IS NOT NULL
		AND EXISTS(SELECT * FROM VOL_Member_Invoice WHERE VMEM_ID=@VMEM_ID AND VMINV_ID<>@VMINV_ID AND InvoiceNumber=@InvoiceNumber) BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @InvoiceNumber, @InvoiceObjectName)
-- Invoice date given ?
END ELSE IF @InvoiceDate IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Invoice Date'), @InvoiceObjectName)
-- Due date given ?
END ELSE IF @PaymentDueDate IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Payment Due Date'), @InvoiceObjectName)
-- Invoice Amount given ?
END ELSE IF @InvoiceAmount IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Invoice Amount'), @InvoiceObjectName)
-- Invoice Amount valid ?
END ELSE IF @InvoiceAmount <= 0 BEGIN
	SET @Error = 22 -- Not valid value
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@InvoiceAmount AS nvarchar(30)), @InvoiceObjectName)
END ELSE BEGIN
	UPDATE VOL_Member_Invoice
	SET MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= @MODIFIED_BY,
		InvoiceNumber	= @InvoiceNumber,
		InvoiceDate		= @InvoiceDate, 
		PaymentDueDate	= @PaymentDueDate,
		InvoiceAmount	= @InvoiceAmount,
		InvoiceVoid		= @InvoiceVoid
	WHERE VMINV_ID=@VMINV_ID
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @InvoiceObjectName, @ErrMsg OUTPUT
END

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Member_Invoice_u] TO [cioc_login_role]
GO
