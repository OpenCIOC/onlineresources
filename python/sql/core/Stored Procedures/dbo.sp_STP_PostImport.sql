SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_PostImport]
WITH EXECUTE AS CALLER
AS

UPDATE btd
	SET	CMP_Accessibility = dbo.fn_GBL_NUMToAccessibility(btd.NUM,btd.ACCESSIBILITY_NOTES,btd.LangID),
		CMP_AltOrg = dbo.fn_GBL_NUMToAltOrg(btd.NUM,btd.LangID),
		CMP_CrossRef = dbo.fn_GBL_NUMToCrossRef(btd.NUM,btd.LangID),
		CMP_FormerOrg = dbo.fn_GBL_NUMToFormerOrg(btd.NUM,btd.LangID),
		CMP_LocatedIn = dbo.fn_GBL_DisplayCommunity(bt.LOCATED_IN_CM, btd.LangID),
		CMP_MailAddress = dbo.fn_GBL_FullAddress(NULL,NULL,btd.MAIL_LINE_1,btd.MAIL_LINE_2,btd.MAIL_BUILDING,btd.MAIL_STREET_NUMBER,btd.MAIL_STREET,btd.MAIL_STREET_TYPE,btd.MAIL_STREET_TYPE_AFTER,btd.MAIL_STREET_DIR,btd.MAIL_SUFFIX,btd.MAIL_CITY,btd.MAIL_PROVINCE,btd.MAIL_COUNTRY,bt.MAIL_POSTAL_CODE,btd.MAIL_CARE_OF,btd.MAIL_BOX_TYPE,btd.MAIL_PO_BOX,NULL,NULL,btd.LangID,0),
		CMP_SiteAddress = dbo.fn_GBL_FullAddress(bt.NUM,bt.RSN,btd.SITE_LINE_1,btd.SITE_LINE_2,btd.SITE_BUILDING,btd.SITE_STREET_NUMBER,btd.SITE_STREET,btd.SITE_STREET_TYPE,btd.SITE_STREET_TYPE_AFTER,btd.SITE_STREET_DIR,btd.SITE_SUFFIX,btd.SITE_CITY,btd.SITE_PROVINCE,btd.SITE_COUNTRY,bt.SITE_POSTAL_CODE,NULL,NULL,NULL,bt.LATITUDE,bt.LONGITUDE,btd.LangID,0),
		CMP_SiteAddressWeb = dbo.fn_GBL_FullAddress(bt.NUM,bt.RSN,btd.SITE_LINE_1,btd.SITE_LINE_2,btd.SITE_BUILDING,btd.SITE_STREET_NUMBER,btd.SITE_STREET,btd.SITE_STREET_TYPE,btd.SITE_STREET_TYPE_AFTER,btd.SITE_STREET_DIR,btd.SITE_SUFFIX,btd.SITE_CITY,btd.SITE_PROVINCE,btd.SITE_COUNTRY,bt.SITE_POSTAL_CODE,NULL,NULL,NULL,bt.LATITUDE,bt.LONGITUDE,btd.LangID,1),
		SRCH_Anywhere_U = 1,
		SRCH_Org_U = 1
	FROM GBL_BaseTable_Description btd
	INNER JOIN GBL_BaseTable bt
		ON bt.NUM=btd.NUM
	
UPDATE cbtd
	SET	CMP_AreasServed = dbo.fn_CIC_NUMToAreasServed(cbtd.NUM,cbtd.AREAS_SERVED_NOTES,cbtd.LangID),
		CMP_Funding = dbo.fn_CIC_NUMToFunding(cbtd.NUM,cbtd.FUNDING_NOTES,cbtd.LangID),
		CMP_Languages = dbo.fn_CIC_NUMToLanguages(cbtd.NUM,cbtd.LANGUAGE_NOTES,cbtd.LangID),
		CMP_Fees = dbo.fn_CIC_NUMToFeeType(cbtd.NUM,cbtd.FEE_NOTES,cbt.FEE_ASSISTANCE_AVAILABLE,cbtd.FEE_ASSISTANCE_FOR,cbtd.FEE_ASSISTANCE_FROM,cbtd.LangID),
		CMP_NAICS = dbo.fn_CIC_NUMToNAICS(cbtd.NUM,cbtd.LangID),
		SRCH_Subjects_U = 1,
		SRCH_Taxonomy_U = 1
	FROM CIC_BaseTable_Description cbtd
	INNER JOIN CIC_BaseTable cbt
		ON cbtd.NUM=cbt.NUM

UPDATE vod
	SET SRCH_Anywhere_U = 1
	FROM VOL_Opportunity_Description vod

GO
