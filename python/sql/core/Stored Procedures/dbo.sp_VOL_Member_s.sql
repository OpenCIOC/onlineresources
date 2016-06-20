SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Member_s]
	@MemberID int,
	@VMEM_ID int,
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
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
	SET @Error = 8 -- Security Failure
-- Vol Member belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Member WHERE VMEM_ID=@VMEM_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @VMEM_ID = NULL
END

DECLARE @SumInvoices int,
		@SumPayments int,
		@ProfileID int,
		@NUM varchar(8),
		@SQLString nvarchar(max)

SELECT @SumInvoices = SUM(InvoiceAmount)
	FROM VOL_Member_Invoice vmi
WHERE VMEM_ID=@VMEM_ID
	AND vmi.InvoiceVoid=0
	AND vmi.PaymentDueDate < GETDATE()

IF @SumInvoices IS NULL SET @SumInvoices=0

SELECT @SumPayments = SUM(vmp.PaymentAmount)
	FROM VOL_Member_Payment vmp
	INNER JOIN VOL_Member_Invoice vmi
		ON vmp.VMINV_ID=vmi.VMINV_ID
WHERE vmp.PaymentVoid=0 AND vmi.VMEM_ID=@VMEM_ID AND vmi.InvoiceVoid=0 AND vmi.PaymentDueDate < GETDATE()

IF @SumPayments IS NULL SET @SumPayments=0

SELECT @ProfileID = PRIVACY_PROFILE, @NUM=bt.NUM
	FROM GBL_BaseTable bt
	INNER JOIN VOL_Member vm
		ON bt.NUM=vm.NUM
WHERE vm.VMEM_ID=@VMEM_ID

SELECT @SQLString = COALESCE(@SQLString + ',','') + dbo.fn_GBL_FieldOption_Display(
			@MemberID,
			NULL,
			fo.FieldID,
			fo.FieldName,
			1,
			fo.PrivacyProfileIDList,
			CASE WHEN NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile WHERE ShareMemberID_Cache=@MemberID) THEN 0 ELSE fo.CanShare END,
			fo.DisplayFM,
			fo.DisplayFMWeb,
			fo.FieldType,
			fo.FormFieldType,
			fo.EquivalentSource,
			fod.CheckboxOnText,
			fod.CheckboxOffText,
			1
		)
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE fo.FieldType='GBL'
	AND fo.FieldName IN ('NUM',
		'ORG_NAME_FULL',
		'CONTACT_1','CONTACT_2','EXEC_1','EXEC_2',
		'OFFICE_PHONE','FAX',
		'SITE_ADDRESS',
		'E_MAIL','WWW_ADDRESS')

SET @SQLString = 'SELECT ' + @SQLString 
	+ ', btd.NON_PUBLIC AS CIC_NON_PUBLIC, btd.DELETION_DATE AS CIC_DELETION_DATE'
	+ ' FROM GBL_BaseTable bt'
	+ ' INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM'
	+ '		AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=' + CAST(@@LANGID AS varchar) + ' THEN 0 ELSE 1 END, LangID)'
	+ ' WHERE bt.NUM=''' + @NUM + ''''

EXEC sp_executesql @SQLString

SELECT cioc_shared.dbo.fn_SHR_GBL_DateString(vm.MemberSince) AS MemberSince, cioc_shared.dbo.fn_SHR_GBL_DateString(vm.NextRenewalDate) AS NextRenewalDate, vm.Active,
	cioc_shared.dbo.fn_SHR_GBL_DateString((SELECT MAX(vmr.RenewalDate) FROM VOL_Member_Renewal vmr WHERE vmr.VMEM_ID=@VMEM_ID)) AS LastRenewalDate,
	cioc_shared.dbo.fn_SHR_GBL_DateString((SELECT MAX(vmi.InvoiceDate) FROM VOL_Member_Invoice vmi WHERE vmi.VMEM_ID=@VMEM_ID)) AS LastInvoiceDate,
	cioc_shared.dbo.fn_SHR_GBL_DateString((SELECT MAX(vmp.PaymentDate) FROM VOL_Member_Payment vmp INNER JOIN VOL_Member_Invoice vmi ON vmp.VMINV_ID=vmi.VMINV_ID WHERE vmi.VMEM_ID=@VMEM_ID AND PaymentVoid=0)) AS LastPaymentDate,
	CASE 
		WHEN NOT EXISTS(SELECT * FROM VOL_Member_Invoice WHERE VMEM_ID=@VMEM_ID) THEN 'U'
		WHEN @SumPayments < @SumInvoices THEN 'A'
		ELSE 'G'
	END AS FinancialStanding
FROM VOL_Member vm
WHERE vm.VMEM_ID=@VMEM_ID

SET NOCOUNT OFF











GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Member_s] TO [cioc_login_role]
GO
