
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[CLBC_LOS_EXPORT]
AS
SELECT
	btd.ORG_LEVEL_1,
	btd.LangID,
	(SELECT
		bt.RSN AS [@ID],
		bt.NUM AS [@Code],
		btd.ORG_LEVEL_2 AS [@Name],
		-- Extra Dropdown A
		(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM CIC_ExtraDropDown exd INNER JOIN CIC_BT_EXD btexd ON btexd.EXD_ID = exd.EXD_ID WHERE bt.NUM=btexd.NUM AND exd.FieldName='EXTRA_DROPDOWN_A' ) AS [@StatusCode],
		-- This will end in disaster
		(SELECT TOP 1 Code FROM CIC_BT_CM o INNER JOIN GBL_Community cm ON cm.CM_ID=o.CM_ID WHERE o.NUM=bt.NUM AND Code <> 'NOF' AND Code IS NOT NULL) AS [@ManagingAreaCode],
		
		E_MAIL AS [@GeneralEmail],
		ISNULL(btd.CREATED_BY,ISNULL(bt.CREATED_BY,'(import)')) AS [@CreatedBy],
		cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(btd.CREATED_DATE) AS [@CreatedOn],
		btd.MODIFIED_BY AS [@LastUpdatedBy],
		cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(btd.MODIFIED_DATE) AS [@LastUpdatedOn],
		
		(SELECT
			BT_EXC_ID AS [@ID],
			Code AS [@Code]
			
			FROM CIC_ExtraChecklist excd
				INNER JOIN CIC_BT_EXC btexcd
			ON btexcd.EXC_ID=excd.EXC_ID
			WHERE btexcd.NUM=bt.NUM AND excd.FieldName='EXTRA_CHECKLIST_D' AND Code IS NOT NULL AND Code <> 'NOF'
		FOR XML PATH('LocationOfServiceProgram'), TYPE) AS [node()],

		(SELECT
			ba.BADDR_ID AS [@AddressID],
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
		FOR XML PATH('LocationOfServiceAddress'), TYPE) AS [node()],

		(SELECT 
			act.BT_ACT_ID AS [@ID],
			actn.ActivityName AS [@Name],
			actn.ActivityDescription AS [@Description],
			(SELECT CASE WHEN Code IS NULL OR Code = 'NOF' THEN NULL ELSE Code END FROM CIC_Activity_Status acts WHERE acts.ASTAT_ID=act.ASTAT_ID) AS [@StatusCode]
			FROM CIC_BT_ACT act
			INNER JOIN CIC_BT_ACT_Notes actn
				ON act.BT_ACT_ID=actn.BT_ACT_ID
			WHERE act.NUM=bt.NUM AND btd.LangID=actn.LangID
		FOR XML PATH('LocationOfServiceActivity'), TYPE) AS [node()],
			
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
		FOR XML PATH('LocationOfServiceContact'), TYPE) AS [node()]

	FOR XML PATH ('LocationOfService'),TYPE) AS LOS
FROM GBL_BaseTable bt
LEFT JOIN GBL_BaseTable_Description btd
	ON bt.NUM=btd.NUM
LEFT JOIN CIC_BaseTable cbt
	ON bt.NUM = cbt.NUM
LEFT JOIN CIC_BaseTable_Description cbtd
	ON cbt.NUM=cbtd.NUM AND btd.LangID=cbtd.LangID
INNER JOIN CIC_RecordType rt
	ON cbt.RECORD_TYPE = rt.RT_ID AND rt.RecordType = 'L'


GO

GRANT SELECT ON  [dbo].[CLBC_LOS_EXPORT] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CLBC_LOS_EXPORT] TO [cioc_login_role]
GO
