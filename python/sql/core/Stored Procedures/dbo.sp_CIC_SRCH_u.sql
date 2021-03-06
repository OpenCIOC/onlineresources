SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_SRCH_u]
	@NUM varchar(8) = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 28-Aug-2015
	Action: NO ACTION REQUIRED
	Notes: In future, may want to limit the scope of this function, esp. with multiple members
*/

/* Update SRCH_Subjects */
UPDATE cbtd
	SET	SRCH_Subjects_U = 0,
		CMP_Subjects = dbo.fn_CIC_NUMToAuthorizedTerms(cbtd.NUM,cbtd.LangID),
		CMP_SubjectsWeb = dbo.fn_CIC_NUMToAuthorizedTerms_Web(cbtd.NUM,cbtd.LangID,'[H]','[P]'),
		SRCH_Subjects = ISNULL(dbo.fn_CIC_NUMToAuthorizedTerms(cbtd.NUM,cbtd.LangID) ,'')
			+ ' ; ' + ISNULL(dbo.fn_CIC_NUMToLocalTerms(NULL,cbtd.NUM,cbtd.LangID),'')
			+ ' ; ' + ISNULL(dbo.fn_CIC_NUMToBroaderTerms(cbtd.NUM,cbtd.LangID),'')
			+ ' ; ' +  ISNULL(dbo.fn_CIC_NUMToUsedForTerms(bt.MemberID,cbtd.NUM,cbtd.LangID),'')
	FROM GBL_BaseTable bt
	INNER JOIN CIC_BaseTable_Description cbtd
		ON bt.NUM=cbtd.NUM
	WHERE cbtd.SRCH_Subjects_U = 1 AND (@NUM IS NULL OR bt.NUM=@NUM)

/* Update SRCH_Taxonomy */
UPDATE cbtd
	SET SRCH_Taxonomy_U = 0,
		CMP_Taxonomy = dbo.fn_CIC_NUMToTaxTerms(cbtd.NUM,cbtd.LangID),
		CMP_TaxonomyWeb = dbo.fn_CIC_NUMToTaxTerms_Web(cbtd.NUM,0,cbtd.LangID,'[H]','[P]'),
		CMP_TaxonomyWebStaff = dbo.fn_CIC_NUMToTaxTerms_Web(cbtd.NUM,1,cbtd.LangID,'[H]','[P]'),
		SRCH_Taxonomy = dbo.fn_TAX_SRCH_Taxonomy(cbtd.NUM,cbtd.LangID)
	FROM CIC_BaseTable_Description cbtd
	WHERE cbtd.SRCH_Taxonomy_U = 1 AND (@NUM IS NULL OR cbtd.NUM=@NUM)

/* Update SRCH_Org */
UPDATE btd
	SET	SRCH_Org_U = 0,
		SRCH_Org = ISNULL(btd.ORG_LEVEL_1 + ' ; ','')
			+ ISNULL(btd.ORG_LEVEL_2 + ' ; ','')
			+ ISNULL(btd.ORG_LEVEL_3 + ' ; ','')
			+ ISNULL(btd.ORG_LEVEL_4 + ' ; ','')
			+ ISNULL(btd.ORG_LEVEL_5 + ' ; ','')
			+ ISNULL(btd.LEGAL_ORG + ' ; ',ISNULL((SELECT obtd.LEGAL_ORG FROM GBL_BaseTable_Description obtd WHERE obtd.NUM=bt.ORG_NUM AND obtd.LangID=btd.LangID) + ' ; ', ''))
			+ ISNULL(btd.LOCATION_NAME + ' ; ','')
			+ ISNULL(btd.SERVICE_NAME_LEVEL_1 + ' ; ','')
			+ ISNULL(btd.SERVICE_NAME_LEVEL_2 + ' ; ','')
			+ ISNULL(btd.CMP_AltOrg + ' ; ','')
			+ ISNULL(btd.CMP_FormerOrg,'')
	FROM GBL_BaseTable_Description btd
	INNER JOIN GBL_BaseTable bt
		ON btd.NUM=bt.NUM
	WHERE btd.SRCH_Org_U = 1 AND (@NUM IS NULL OR bt.NUM=@NUM)

/* Update SRCH_Anywhere */
UPDATE btd
	SET	SRCH_Anywhere_U = 0,
		SRCH_Anywhere = 
		/* Organization Names */
		ISNULL(btd.SRCH_Org,'') + ' '
		/* Subjects / Classifications */
		+ ISNULL(cbtd.SRCH_Subjects,'') + ' ' 
		+ ISNULL(cbtd.SRCH_Taxonomy,'') + ' '
		+ ISNULL(cbtd.CMP_NAICS,'') + ' '
		/* Descriptions */
		+ ISNULL(btd.[DESCRIPTION],'') + ' '
		+ ISNULL(btd.[LOCATION_DESCRIPTION],'') + ' '
		+ ISNULL(btd.[ORG_DESCRIPTION],'') + ' '
		+ CASE WHEN dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'SUP_DESCRIPTION')=1 THEN '' ELSE ISNULL(cbtd.SUP_DESCRIPTION,'') END + ' '
		/* Languages */
		+ ISNULL(cbtd.CMP_Languages,'') + ' '
		/* Location and Communities */
		+ ISNULL(btd.CMP_LocatedIn,'') + ' '
		+ ISNULL(cbtd.CMP_AreasServed,'') + ' '
		+ CASE WHEN dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'INTERSECTION')=1 THEN '' ELSE ISNULL(cbtd.INTERSECTION,'') END + ' '
		+ CASE WHEN dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'SITE_LOCATION')=1 THEN '' ELSE ISNULL(cbtd.SITE_LOCATION,'') END + ' '
		+ ISNULL(btd.SITE_BUILDING,'') + ' '
		+ ISNULL(btd.CMP_Accessibility,'') + ' '
		+ ISNULL(cbtd.TRANSPORTATION,'') + ' '
		/* Contacts */
		+ CASE WHEN dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'CONTACT_1')=1 THEN '' ELSE ISNULL((SELECT CMP_Name FROM GBL_Contact c WHERE c.GblContactType='CONTACT_1' AND c.GblNUM=btd.NUM AND c.LangID=btd.LangID),'') END + ' '
		+ CASE WHEN dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'CONTACT_2')=1 THEN '' ELSE ISNULL((SELECT CMP_Name FROM GBL_Contact c WHERE c.GblContactType='CONTACT_2' AND c.GblNUM=btd.NUM AND c.LangID=btd.LangID),'') END + ' '
		+ CASE WHEN dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'EXEC_1')=1 THEN '' ELSE ISNULL((SELECT CMP_Name FROM GBL_Contact c WHERE c.GblContactType='EXEC_1' AND c.GblNUM=btd.NUM AND c.LangID=btd.LangID),'') END + ' '
		+ CASE WHEN dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'EXEC_2')=1 THEN '' ELSE ISNULL((SELECT CMP_Name FROM GBL_Contact c WHERE c.GblContactType='EXEC_2' AND c.GblNUM=btd.NUM AND c.LangID=btd.LangID),'') END + ' '
		+ CASE WHEN dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'EXTRA_CONTACT_A')=1 THEN '' ELSE ISNULL((SELECT CMP_Name FROM GBL_Contact c WHERE c.GblContactType='EXTRA_CONTACT_A' AND GblNUM=btd.NUM AND c.LangID=btd.LangID),'') END + ' '
		+ CASE WHEN dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'VOLCONTACT')=1 THEN '' ELSE ISNULL((SELECT CMP_Name FROM GBL_Contact c WHERE c.GblContactType='VOCONTACT' AND c.GblNUM=btd.NUM AND c.LangID=btd.LangID),'') END + ' '
		/* Child Care */
		+ ISNULL(dbo.fn_CCR_DisplayTypeOfProgram(ccbt.TYPE_OF_PROGRAM,btd.LangID),'') + ' '
		+ ISNULL(dbo.fn_CCR_NUMToTypeOfCare(btd.NUM,ccbtd.TYPE_OF_CARE_NOTES,btd.LangID),'') + ' '
		+ ISNULL(dbo.fn_CCR_NUMToSchoolsInArea(btd.NUM,ccbtd.SCHOOLS_IN_AREA_NOTES,btd.LangID),'') + ' '
		/* Other Details */
		+ CASE WHEN dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'ELIGIBILITY')=1 THEN '' ELSE ISNULL(cbtd.ELIGIBILITY_NOTES,'') END + ' '
		+ CASE WHEN dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'FEES')=1 THEN '' ELSE ISNULL(cbtd.CMP_Fees,'') END + ' '
		+ CASE WHEN dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'FUNDING')=1 THEN '' ELSE ISNULL(cbtd.CMP_Funding,'') END + ' '
		+ ISNULL(dbo.fn_CIC_SRCH_EXTRA_TEXT(bt.NUM,btd.LangID,bt.PRIVACY_PROFILE),'')
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
	LEFT JOIN CIC_BaseTable cbt
		ON bt.NUM=cbt.NUM
	LEFT JOIN CIC_BaseTable_Description cbtd
		ON cbt.NUM=cbtd.NUM AND cbtd.LangID=btd.LangID
	LEFT JOIN CCR_BaseTable ccbt
		ON bt.NUM=ccbt.NUM
	LEFT JOIN CCR_BaseTable_Description ccbtd
		ON ccbt.NUM=ccbtd.NUM AND ccbtd.LangID=btd.LangID
WHERE btd.SRCH_Anywhere_U = 1 AND (@NUM IS NULL OR bt.NUM=@NUM)

SET NOCOUNT OFF


GO


GRANT EXECUTE ON  [dbo].[sp_CIC_SRCH_u] TO [cioc_login_role]
GO
