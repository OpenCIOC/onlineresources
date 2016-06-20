
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[CLBC_VENDOR_EXPORT]
AS
SELECT
	(SELECT
		bt.RSN AS [@ID],
		bt.NUM AS [@Code],
		(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM CIC_ExtraDropDown exd INNER JOIN CIC_BT_EXD btex ON btex.EXD_ID = exd.EXD_ID WHERE btex.NUM=bt.NUM AND exd.FieldName='EXTRA_DROPDOWN_B') AS [@StatusCode],
		(SELECT cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat((SELECT [Value] FROM CIC_BT_EXTRA_DATE WHERE NUM=cbtd.NUM AND FieldName='EXTRA_DATE_B'))) AS [@CASConfirmDate],
		OCG_NO AS [@OCGNumber],
		WCB_NO AS [@WCBNumber],
		CORP_REG_NO AS [@BusinessNumber],
		TAX_REG_NO AS [@GSTHSTNumber],
		-- extra dropdown C
		(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM CIC_ExtraDropDown exd INNER JOIN CIC_BT_EXD btex ON btex.EXD_ID = exd.EXD_ID WHERE btex.NUM=bt.NUM AND exd.FieldName='EXTRA_DROPDOWN_C') AS [@BusinessTypeCode],
		-- This will end in disaster
		(SELECT TOP 1 Code FROM CIC_BT_CM o INNER JOIN GBL_Community cm ON cm.CM_ID=o.CM_ID WHERE o.NUM=bt.NUM AND Code <> 'NOF' AND Code IS NOT NULL) AS [@ManagingAreaCode],
		
		(SELECT CASE WHEN [Currency] IS NULL OR [Currency] = 'NOF' THEN NULL ELSE [Currency] END FROM GBL_Currency WHERE PREF_CURRENCY=CUR_ID) AS [@DefaultCurrencyCode],
		(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM CIC_FiscalYearEnd WHERE FISCAL_YEAR_END=FYE_ID) AS [@FiscalYearEndCode],
		(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM GBL_PaymentMethod WHERE PREF_PAYMENT_METHOD=PAY_ID) AS [@PaymentMethodCode],
		(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM GBL_PaymentTerms WHERE PAYMENT_TERMS=PYT_ID) AS [@PaymentTermsCode],
		-- extra drop down G
		(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM CIC_ExtraDropDown exd INNER JOIN CIC_BT_EXD btex ON btex.EXD_ID = exd.EXD_ID WHERE btex.NUM=bt.NUM AND exd.FieldName='EXTRA_DROPDOWN_G') AS [@MIPEligible],
		(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM CIC_Certification WHERE CERTIFIED=CRT_ID) AS [@Certified],
		(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM CIC_Accreditation WHERE ACCREDITED=ACR_ID) AS [@Accredited],
		--(SELECT cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat((SELECT [Value] FROM CIC_BT_EXTRA_DATE WHERE NUM=cbtd.NUM AND FieldName='EXTRA_DATE_A'))) AS [@AccreditationExpiryDate],
		-- extra drop down F
		(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM CIC_ExtraDropDown exd INNER JOIN CIC_BT_EXD btex ON btex.EXD_ID = exd.EXD_ID WHERE btex.NUM=bt.NUM AND exd.FieldName='EXTRA_DROPDOWN_F') AS [@AccreditingBodyCode],
		-- extra drop down H
		(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM CIC_ExtraDropDown exd INNER JOIN CIC_BT_EXD btex ON btex.EXD_ID = exd.EXD_ID WHERE btex.NUM=bt.NUM AND exd.FieldName='EXTRA_DROPDOWN_H') AS [@CommunicationsCode],
		-- extra drop down E
		(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM CIC_ExtraDropDown exd INNER JOIN CIC_BT_EXD btex ON btex.EXD_ID = exd.EXD_ID WHERE btex.NUM=bt.NUM AND exd.FieldName='EXTRA_DROPDOWN_E') AS [@Aboriginal],
		E_MAIL AS [@GeneralEmail],
		OFFICE_PHONE AS [@OfficePhone],
		ISNULL(btd.CREATED_BY,ISNULL(bt.CREATED_BY,'(import)')) AS [@CreatedBy],
		cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(btd.CREATED_DATE) AS [@CreatedOn],
		btd.MODIFIED_BY AS [@LastUpdatedBy],
		cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(btd.MODIFIED_DATE) AS [@LastUpdatedOn],
		(SELECT 
			Code AS [@RoleCode]
			FROM CIC_ExtraChecklist excc
			INNER JOIN CIC_BT_EXC btexcc
				ON btexcc.EXC_ID=excc.EXC_ID
			WHERE btexcc.NUM=bt.NUM AND FieldName = 'EXTRA_CHECKLIST_C' AND Code IS NOT NULL AND Code <> 'NOF'
		FOR XML PATH('VendorRole'), TYPE) AS [node()],
		(SELECT 
			Code AS [@RoleCode]
			FROM CIC_ExtraChecklist exca
				INNER JOIN CIC_BT_EXC btexca
			ON btexca.EXC_ID=exca.EXC_ID
			WHERE btexca.NUM=bt.NUM AND FieldName='EXTRA_CHECKLIST_A' AND Code IS NOT NULL AND Code <> 'NOF'
		FOR XML PATH('ServiceProviderRole'), TYPE) AS [node()],
		(SELECT
			ba.BADDR_ID AS [@AddressID],
			ba.CAS_CONFIRMATION_DATE AS [@CASConfirmDate],
			SITE_CODE AS [@Code],
			(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM GBL_BillingAddressType WHERE AddressTypeID=ADDRTYPE) AS [@RoleCode],
			LINE_1 AS [@Line1],
			LINE_2 AS [@Line2],
			LINE_3 AS [@Line3],
			LINE_4 AS [@Line4],
			CITY AS [@City],
			PROVINCE AS [@Province],
			COUNTRY AS [@Country],
			POSTAL_CODE AS [@PostalCode],
			ISNULL(btd.CREATED_BY,ISNULL(bt.CREATED_BY,'(import)')) AS [@CreatedBy],
			cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(btd.CREATED_DATE) AS [@CreatedOn],
			btd.MODIFIED_BY AS [@LastUpdatedBy],
			cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(btd.MODIFIED_DATE) AS [@LastUpdatedOn]			
			FROM GBL_BT_BILLINGADDRESS ba
			WHERE ba.NUM=bt.NUM AND ba.LangID=btd.LangID
		FOR XML PATH('VendorAddress'), TYPE) AS [node()],
		(SELECT 
			Code AS [@AssociationCode]
			FROM CIC_MembershipType mt
				INNER JOIN CIC_BT_MT btmt
			ON btmt.MT_ID=mt.MT_ID
			WHERE btmt.NUM=bt.NUM AND Code IS NOT NULL AND Code <> 'NOF'
		FOR XML PATH('EmployersAssociation'), TYPE) AS [node()],			
		CASE WHEN btd.ORG_LEVEL_1 IS NULL THEN NULL ELSE (SELECT 
			'LEGAL' AS [@NameTypeCode],
			btd.ORG_LEVEL_1 AS [@Name]
		FOR XML PATH('VendorName'), TYPE) END AS [node()],			
		CASE WHEN NOT EXISTS(SELECT * FROM CIC_BT_EXTRA_TEXT WHERE NUM=bt.NUM AND LangID=btd.LangID AND FieldName='EXTRA_C') THEN NULL ELSE (SELECT 
			'RPT' AS [@NameTypeCode],
			(SELECT [Value] FROM CIC_BT_EXTRA_TEXT WHERE NUM=cbtd.NUM AND LangID=btd.LangID AND FieldName='EXTRA_C') AS [@Name]
		FOR XML PATH('VendorName'), TYPE) END AS [node()],
		(SELECT TOP 3
				'DBA' + CAST(ROW_NUMBER() OVER (ORDER BY ALT_ORG) AS varchar) AS [@NameTypeCode],
				ALT_ORG AS [@Name]
			FROM GBL_BT_ALTORG ao
			WHERE bt.NUM=ao.NUM AND ao.LangID = btd.LangID
		FOR XML PATH('VendorName'), TYPE) AS [node()],
		(SELECT 
				c.ContactID AS [@ID],
				CASE WHEN c.GblContactType = 'CONTACT_1' THEN 'PRIM'
					 WHEN c.GblContactType = 'CONTACT_2' THEN 'ALT1'
					 WHEN c.GblContactType = 'EXEC_1' THEN 'ALT2'
					 WHEN c.GblContactType = 'EXEC_2' THEN 'ALT3'
				END AS [@RoleCode],
				c.NAME_HONORIFIC AS [@NameTitleCode],
				c.NAME_FIRST AS [@FirstName],
				c.NAME_LAST AS [@Surname],
				c.NAME_SUFFIX AS [@Suffix],
				c.TITLE AS [@Title],
				c.ORG AS [@Organization],
				c.EMAIL AS [@Email],
				
				ISNULL(c.CREATED_BY,ISNULL(bt.CREATED_BY,'(import)')) AS [@CreatedBy],
				cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(c.CREATED_DATE) AS [@CreatedOn],
				c.MODIFIED_BY AS [@LastUpdatedBy],
				cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(c.MODIFIED_DATE) AS [@LastUpdatedOn],

				(SELECT 
					'0' AS [@RoleCode],
					'FAX' AS [@TypeCode],
					c.FAX_NO AS [@Number],
					c.FAX_EXT AS [@Extension],
					c.FAX_NOTE AS [@Notes],
					ISNULL(c.CREATED_BY,ISNULL(bt.CREATED_BY,'(import)')) AS [@CreatedBy],
					cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(c.CREATED_DATE) AS [@CreatedOn],
					c.MODIFIED_BY AS [@LastUpdatedBy],
					cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(c.MODIFIED_DATE) AS [@LastUpdatedOn]
				FOR XML PATH('VendorContactPhone'), TYPE) AS [node()],
				(SELECT 
					'1' AS [@RoleCode],
					c.PHONE_1_TYPE AS [@TypeCode],
					c.PHONE_1_NO AS [@Number],
					c.PHONE_1_EXT AS [@Extension],
					c.PHONE_1_OPTION AS [@Option],
					c.PHONE_1_NOTE AS [@Notes],
					ISNULL(c.CREATED_BY,ISNULL(bt.CREATED_BY,'(import)')) AS [@CreatedBy],
					cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(c.CREATED_DATE) AS [@CreatedOn],
					c.MODIFIED_BY AS [@LastUpdatedBy],
					cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(c.MODIFIED_DATE) AS [@LastUpdatedOn]
				FOR XML PATH('VendorContactPhone'), TYPE) AS [node()],
				(SELECT 
					'2' AS [@RoleCode],
					c.PHONE_2_TYPE AS [@TypeCode],
					c.PHONE_2_NO AS [@Number],
					c.PHONE_2_EXT AS [@Extension],
					c.PHONE_2_OPTION AS [@Option],
					c.PHONE_2_NOTE AS [@Notes],
					ISNULL(c.CREATED_BY,ISNULL(bt.CREATED_BY,'(import)')) AS [@CreatedBy],
					cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(c.CREATED_DATE) AS [@CreatedOn],
					c.MODIFIED_BY AS [@LastUpdatedBy],
					cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(c.MODIFIED_DATE) AS [@LastUpdatedOn]
				FOR XML PATH('VendorContactPhone'), TYPE) AS [node()],
				(SELECT 
					'3' AS [@RoleCode],
					c.PHONE_3_TYPE AS [@TypeCode],
					c.PHONE_3_NO AS [@Number],
					c.PHONE_3_EXT AS [@Extension],
					c.PHONE_3_OPTION AS [@Option],
					c.PHONE_3_NOTE AS [@Notes],
					ISNULL(c.CREATED_BY,ISNULL(bt.CREATED_BY,'(import)')) AS [@CreatedBy],
					cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(c.CREATED_DATE) AS [@CreatedOn],
					c.MODIFIED_BY AS [@LastUpdatedBy],
					cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(c.MODIFIED_DATE) AS [@LastUpdatedOn]
				FOR XML PATH('VendorContactPhone'), TYPE) AS [node()]			
			FROM GBL_Contact c
			WHERE c.GblNUM = bt.NUM AND c.LangID=btd.LangID AND c.GblContactType IN ('CONTACT_1', 'CONTACT_2', 'EXEC_1', 'EXEC_2')
		FOR XML PATH('VendorContact'), TYPE) AS [node()],
		(SELECT LOS AS [node()] FROM CLBC_LOS_EXPORT los WHERE btd.ORG_LEVEL_1=los.ORG_LEVEL_1 AND btd.LangID=los.LangID FOR XML PATH(''), TYPE) AS [node()]

	FOR XML PATH ('Vendor'),TYPE) AS Vendor,
	bt.RSN
FROM GBL_BaseTable bt
LEFT JOIN GBL_BaseTable_Description btd
	ON bt.NUM=btd.NUM AND btd.LangID=0
LEFT JOIN CIC_BaseTable cbt
	ON bt.NUM = cbt.NUM
LEFT JOIN CIC_BaseTable_Description cbtd
	ON cbt.NUM=cbtd.NUM AND btd.LangID=cbtd.LangID
INNER JOIN CIC_RecordType rt
	ON cbt.RECORD_TYPE = rt.RT_ID AND rt.RecordType = 'V'



GO

GRANT SELECT ON  [dbo].[CLBC_VENDOR_EXPORT] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CLBC_VENDOR_EXPORT] TO [cioc_login_role]
GO
