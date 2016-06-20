SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Member_Invoice_lf]
	@MemberID int,
	@VMEM_ID int
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

SELECT vm.NUM, dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL
	FROM VOL_Member vm
	LEFT JOIN GBL_BaseTable bt
		ON vm.NUM=bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=bt.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vm.VMEM_ID=@VMEM_ID

SELECT vmi.VMINV_ID, InvoiceNumber, InvoiceDate, PaymentDueDate, InvoiceAmount, InvoiceVoid, 
		InvoiceAmount - IsNull(PaymentAmount,0) AS AmountOwing
FROM VOL_Member_Invoice vmi
LEFT JOIN (SELECT VMINV_ID, SUM(PaymentAmount) AS PaymentAmount, MAX(PaymentDate) AS PaymentDate
		FROM VOL_Member_Payment WHERE PaymentVoid=0 GROUP BY VMINV_ID) vmp
	ON vmi.VMINV_ID=vmp.VMINV_ID
WHERE vmi.VMEM_ID=@VMEM_ID
ORDER BY InvoiceDate, InvoiceNumber

RETURN @Error

SET NOCOUNT OFF






GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Member_Invoice_lf] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Member_Invoice_lf] TO [cioc_vol_search_role]
GO
