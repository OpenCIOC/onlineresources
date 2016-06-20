SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Member_Invoice_l]
	@MemberID int,
	@VMEM_ID int
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

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- Vol Member exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Member WHERE VMEM_ID=@VMEM_ID) BEGIN
	SET @Error = 3 -- No Such Record
-- Vol Member belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Member WHERE VMEM_ID=@VMEM_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @VMEM_ID = NULL
END

SELECT VMINV_ID, InvoiceNumber, cioc_shared.dbo.fn_SHR_GBL_DateString(InvoiceDate) AS InvoiceDate
	FROM VOL_Member_Invoice vmi
WHERE vmi.VMEM_ID=@VMEM_ID
ORDER BY InvoiceDate

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Member_Invoice_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Member_Invoice_l] TO [cioc_vol_search_role]
GO
