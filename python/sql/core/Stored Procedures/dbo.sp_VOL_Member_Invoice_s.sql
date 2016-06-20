SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Member_Invoice_s]
	@MemberID int,
	@VMINV_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 02-Oct-2013
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE @VMEM_ID int
SELECT @VMEM_ID=VMEM_ID FROM VOL_Member_Invoice WHERE VMINV_ID=@VMINV_ID

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

SELECT vm.VMEM_ID, vm.NUM,
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		vmi.VMINV_ID, InvoiceNumber, InvoiceDate, PaymentDueDate, InvoiceAmount, InvoiceVoid, 
		InvoiceAmount - PaymentAmount AS AmountOwing
	FROM VOL_Member vm
	INNER JOIN VOL_Member_Invoice vmi
		ON vm.VMEM_ID=vmi.VMEM_ID 
	LEFT JOIN GBL_BaseTable bt
		ON vm.NUM=bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN (SELECT VMINV_ID, SUM(PaymentAmount) AS PaymentAmount, MAX(PaymentDate) AS PaymentDate
				FROM VOL_Member_Payment WHERE PaymentVoid=0 GROUP BY VMINV_ID) vmp
		ON vmi.VMINV_ID=vmp.VMINV_ID
WHERE vmi.VMINV_ID=@VMINV_ID

SELECT VMPMT_ID, vmp.VMINV_ID, cioc_shared.dbo.fn_SHR_GBL_DateString(PaymentDate) AS PaymentDate, PaymentAmount, PaymentVoid, vmp.Notes 
	FROM VOL_Member_Payment vmp
	INNER JOIN VOL_Member_Invoice vmi
		ON vmi.VMINV_ID=vmp.VMINV_ID
WHERE vmp.VMINV_ID=@VMINV_ID
ORDER BY PaymentDate

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Member_Invoice_s] TO [cioc_login_role]
GO
