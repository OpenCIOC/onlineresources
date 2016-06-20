
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[O211SC_RECORD_EXPORT]
AS

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 30-Aug-2015
	Action: TESTING REQUIRED
*/

SELECT bt.NUM,
	btd.LangID,
	sl.Culture,
	"record" = (SELECT
		"id" = bt.NUM ,
		"owner" = bt.RECORD_OWNER,
		"language" = sl.Culture, 
		"source_database" = btd.SOURCE_DB,
		"submit_changes_to" = btd.SUBMIT_CHANGES_TO,
		"org_name_1" = btd.ORG_LEVEL_1,
		"org_name_2" = btd.ORG_LEVEL_2,
		"org_name_3" = btd.ORG_LEVEL_3,
		"org_name_4" = btd.ORG_LEVEL_4,
		"org_name_5" = btd.ORG_LEVEL_5,
		"legal_name" = btd.LEGAL_ORG,
		"alternate_names" = 
			(SELECT
					ao.ALT_ORG "value"
					FROM GBL_BT_ALTORG ao
				WHERE ao.NUM=bt.NUM AND ao.LangID=btd.LangID
				FOR XML PATH('name'), TYPE
				),
		"after_hours_phone" = cbtd.AFTER_HRS_PHONE,
		"application" = cbtd.APPLICATION,
		"areas_served" = (SELECT
			cbtd.AREAS_SERVED_NOTES "general_notes",
			(SELECT
					pr.CM_ID "community_id",
					cmn.Name "value",
					prn.Notes "note"
				FROM CIC_BT_CM pr
				LEFT JOIN CIC_BT_CM_Notes prn
					ON pr.BT_CM_ID=prn.BT_CM_ID AND prn.LangID=btd.LangID
				INNER JOIN GBL_Community cm
					ON pr.CM_ID=cm.CM_ID
				INNER JOIN GBL_Community_Name cmn
					ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID)
				WHERE pr.NUM=bt.NUM
				FOR XML PATH('community'),TYPE)
			FOR XML PATH(''),TYPE
			),
		"contacts" = 
			(SELECT
					GblContactType "contact_type",
					(SELECT ISNULL(fod.FieldDisplay,GblContactType)
						FROM GBL_FieldOption fo
						INNER JOIN GBL_FieldOption_Description fod
							ON fo.FieldID=fod.FieldID AND fod.LangID=btd.LangID
						WHERE fo.FieldName=GblContactType) "contact_label",
					CMP_Name "name",
					TITLE "title",
					ORG "organization",
					EMAIL "email",
					CMP_Fax "fax",
					CMP_PhoneFull "phone"
				FROM GBL_Contact
				WHERE GblContactType IN ('CONTACT_1','CONTACT_2','EXEC_1','EXEC_2','VOLCONTACT') AND GblNUM=bt.NUM AND LangID=btd.LangID
				ORDER BY GblContactType
				FOR XML PATH('contact'),TYPE),
		"created_date" = btd.CREATED_DATE,
		"crisis_phone" = cbtd.CRISIS_PHONE,
		"description" = btd.DESCRIPTION,
		"email" = btd.E_MAIL,
		"eligibility" = (SELECT
				cbt.MIN_AGE "min_age",
				cbt.MAX_AGE "max_age",
				cbtd.ELIGIBILITY_NOTES "general_notes"
			FOR XML PATH(''), TYPE
			),
		"fax" = btd.FAX,
		"former_names" = 
			(SELECT
					fo.FORMER_ORG "value",
					fo.DATE_OF_CHANGE "date_of_change"
				FROM GBL_BT_FORMERORG fo
				WHERE fo.NUM=bt.NUM AND fo.LangID=btd.LangID
				FOR XML PATH('name'), TYPE
				),
		"geolocation" = (
			SELECT
				bt.LATITUDE "latitude",
				bt.LONGITUDE "longitude"
			FOR XML PATH(''), TYPE),
		"hours" = cbtd.HOURS,
		"intersection" = cbtd.INTERSECTION,
		"languages" = (
			SELECT
				cbtd.LANGUAGE_NOTES "general_notes",
				(SELECT
						lnne.Name "value",
						CASE WHEN prne.Notes IS NULL AND NOT EXISTS(SELECT * FROM dbo.CIC_BT_LN_LND WHERE BT_LN_ID=pr.BT_LN_ID) THEN NULL ELSE
							ISNULL((SELECT STUFF((SELECT ', ' + ISNULL(lndn.Name,lnd.Code)
								FROM dbo.CIC_BT_LN_LND prlnd
								INNER JOIN dbo.GBL_Language_Details lnd
									ON lnd.LND_ID = prlnd.LND_ID
								LEFT JOIN dbo.GBL_Language_Details_Name lndn
									ON lndn.LND_ID = lnd.LND_ID AND lndn.LangID=btd.LangID
								WHERE prlnd.BT_LN_ID=pr.BT_LN_ID
								FOR XML PATH('')) ,1,2,'')),'')
							+ CASE WHEN prne.Notes IS NULL THEN ''
								ELSE CASE WHEN EXISTS(SELECT * FROM dbo.CIC_BT_LN_LND prlnd WHERE prlnd.BT_LN_ID=pr.BT_LN_ID)
								THEN ', ' ELSE '' END + prne.Notes END
						END "note"
					FROM CIC_BT_LN pr
					LEFT JOIN CIC_BT_LN_Notes prne
						ON pr.BT_LN_ID=prne.BT_LN_ID AND prne.LangID=btd.LangID
					INNER JOIN GBL_Language ln
						ON pr.LN_ID=ln.LN_ID
					LEFT JOIN GBL_Language_Name lnne
						ON ln.LN_ID=lnne.LN_ID AND lnne.LangID=btd.LangID
					WHERE pr.NUM=bt.NUM
					FOR XML PATH('language'),TYPE)
			FOR XML PATH(''),TYPE
			),
		"last_modified" = btd.MODIFIED_DATE,
		"located_in_community" = dbo.fn_GBL_DisplayCommunity(bt.LOCATED_IN_CM,btd.LangID),
		"located_in_community_id" = bt.LOCATED_IN_CM,
		"mail_address" = btd.CMP_MailAddress,
		"office_phone" = btd.OFFICE_PHONE,
		"org_type" = (
			SELECT
				sln.Name "service_level"
				FROM CIC_BT_SL pr
				INNER JOIN CIC_ServiceLevel_Name sln
					ON pr.SL_ID=sln.SL_ID AND sln.LangID=(SELECT TOP 1 LangID FROM CIC_ServiceLevel_Name WHERE SL_ID=sln.SL_ID ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID)
				WHERE pr.NUM=bt.NUM
			FOR XML PATH(''), TYPE
			),
		"physical_access" = (SELECT
			btd.ACCESSIBILITY_NOTES "general_notes",
			(SELECT
					acn.Name "value",
					prn.Notes "note"
				FROM GBL_BT_AC pr
					LEFT JOIN GBL_BT_AC_Notes prn
						ON pr.BT_AC_ID=prn.BT_AC_ID AND prn.LangID=btd.LangID
					INNER JOIN GBL_Accessibility ac
						ON pr.AC_ID=ac.AC_ID
					INNER JOIN GBL_Accessibility_Name acn
						ON ac.AC_ID=acn.AC_ID AND acn.LangID=(SELECT TOP 1 LangID FROM GBL_Accessibility_Name WHERE AC_ID=acn.AC_ID ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID)
					WHERE pr.NUM=bt.NUM
					FOR XML PATH('type'), TYPE)
			FOR XML PATH(''), TYPE
			),
		"public_notice" = cbtd.PUBLIC_COMMENTS,
		"site_address" = (
			SELECT 
				btd.CMP_SiteAddress "full_address",
				btd.SITE_PROVINCE "province",
				bt.SITE_POSTAL_CODE "postal_code"
			WHERE btd.CMP_SiteAddress IS NOT NULL
			FOR XML PATH(''), TYPE
			),
		"subjects" = (SELECT
			sjn.Name "term"
			FROM CIC_BT_SBJ pr
			INNER JOIN THS_Subject_Name sjn
				ON pr.Subj_ID=sjn.Subj_ID AND sjn.LangID=btd.LangID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH(''), TYPE
			),
		"taxonomy" = (SELECT
				(SELECT
					tlt.Code "term"
				FROM CIC_BT_TAX_TM tlt
				WHERE tlt.BT_TAX_ID = tl.BT_TAX_ID
				FOR XML PATH('link'),TYPE)
			FROM CIC_BT_TAX tl
			WHERE tl.NUM = bt.NUM
			FOR XML PATH(''),TYPE
			),
		"tdd_phone" = cbtd.TDD_PHONE,
		"toll_free_phone" = btd.TOLL_FREE_PHONE,
		"website" = btd.WWW_ADDRESS
	FOR XML PATH('record'), TYPE)
	FROM GBL_BaseTable bt
		INNER JOIN GBL_BaseTable_Description btd
			ON bt.NUM=btd.NUM
		LEFT JOIN CIC_BaseTable cbt
			ON bt.NUM = cbt.NUM
		LEFT JOIN CIC_BaseTable_Description cbtd
			ON cbt.NUM=cbtd.NUM AND cbtd.LangID=btd.LangID
		INNER JOIN STP_Language sl
			ON btd.LangID=sl.LangID
	WHERE (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
		AND btd.NON_PUBLIC=0












GO

GRANT SELECT ON  [dbo].[O211SC_RECORD_EXPORT] TO [cioc_login_role]
GO
