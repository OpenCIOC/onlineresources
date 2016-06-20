
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [dbo].[CIC_SHARE_VIEW_FR]
AS

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 27-Sep-2014
	Action: NO ACTION REQUIRED
*/

SELECT bt.NUM,
		bt.RECORD_OWNER,
		bt.PRIVACY_PROFILE AS XPRIVACY,
		btf.NON_PUBLIC AS XNP,
		btf.DELETION_DATE  AS XDEL,
		btf.UPDATE_DATE AS XUPD,
		0 AS HAS_ENGLISH, 
		1 AS HAS_FRENCH,
ACCESSIBILITY = (
	SELECT
		btf.ACCESSIBILITY_NOTES "@NF",
		(SELECT
				ac.Code "@CD",
				acne.Name "@V",
				acnf.Name "@VF",
				prnf.Notes "@NF"
			FROM GBL_BT_AC pr
			LEFT JOIN GBL_BT_AC_Notes prnf
				ON pr.BT_AC_ID=prnf.BT_AC_ID AND prnf.LangID=btf.LangID
			INNER JOIN GBL_Accessibility ac
				ON pr.AC_ID=ac.AC_ID
			INNER JOIN GBL_Accessibility_Name acne
				ON ac.AC_ID=acne.AC_ID AND acne.LangID=(SELECT TOP 1 LangID FROM GBL_Accessibility_Name WHERE AC_ID=acne.AC_ID ORDER BY CASE WHEN LangID=bte.LangID THEN 0 ELSE 1 END, LangID)
			LEFT JOIN GBL_Accessibility_Name acnf
				ON ac.AC_ID=acnf.AC_ID AND acnf.LangID=btf.LangID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('CHK'), TYPE)
	FOR XML PATH('ACCESSIBILITY'), TYPE
	),
ACCREDITED = ISNULL((
	SELECT
		acr.Code "@CD",
		acrne.Name "@V",
		(SELECT acrnf.Name FROM CIC_Accreditation_Name acrnf WHERE acrnf.ACR_ID=acr.ACR_ID AND acrnf.LangID=btf.LangID) "@VF"
	FROM CIC_Accreditation acr
	INNER JOIN CIC_Accreditation_Name acrne
		ON acrne.ACR_ID=acr.ACR_ID AND acrne.LangID=(SELECT TOP 1 LangID FROM CIC_Accreditation_Name WHERE ACR_ID=acrne.ACR_ID ORDER BY CASE WHEN LangID=bte.LangID THEN 0 ELSE 1 END, LangID)
	WHERE acr.ACR_ID=cbt.ACCREDITED
	FOR XML PATH('ACCREDITED'), TYPE
	), CAST('<ACCREDITED/>' AS xml)),
ACTIVITY_INFO = (
	SELECT
		cbtf.ACTIVITY_NOTES "@NF",
		(SELECT
				pr.GUID "@GID",
				prnf.ActivityName "@NMF",
				prnf.ActivityDescription "@DESCF",
				asne.Name "@STAT",
				asnf.Name "@STATF",
				prnf.Notes "@NF"
			FROM CIC_BT_ACT pr
			LEFT JOIN CIC_BT_ACT_Notes prnf
				ON pr.BT_ACT_ID=prnf.BT_ACT_ID AND prnf.LangID=btf.LangID
			LEFT JOIN CIC_Activity_Status ast
				ON pr.ASTAT_ID=ast.ASTAT_ID
			LEFT JOIN CIC_Activity_Status_Name asne
				ON ast.ASTAT_ID=asne.ASTAT_ID AND asne.LangID=(SELECT TOP 1 LangID FROM CIC_Activity_Status_Name WHERE ASTAT_ID=asne.ASTAT_ID ORDER BY CASE WHEN LangID=bte.LangID THEN 0 ELSE 1 END, LangID)
			LEFT JOIN CIC_Activity_Status_Name asnf
				ON ast.ASTAT_ID=asnf.ASTAT_ID AND asnf.LangID=btf.LangID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('UNIT'), TYPE)
	FOR XML PATH('ACTIVITY_INFO'), TYPE
	),
AFTER_HRS_PHONE = (SELECT cbtf.AFTER_HRS_PHONE "@VF" FOR XML PATH('AFTER_HRS_PHONE'), TYPE),
ALT_ORG = ISNULL((
	SELECT
		(SELECT
				ao.ALT_ORG "@V",
				ao.PUBLISH "@PB",
				CASE WHEN ao.LangID=0 THEN 'E' WHEN LangID=2 THEN 'F' ELSE '?' END "@LANG"
			FROM GBL_BT_ALTORG ao
			WHERE ao.NUM=bt.NUM AND (ao.LangID=btf.LangID)
			FOR XML PATH('NM'), TYPE)
	FOR XML PATH('ALT_ORG'), TYPE
	),CAST('<ALT_ORG/>' AS xml)),
[APPLICATION] = (SELECT cbtf.APPLICATION "@VF" FOR XML PATH('APPLICATION'), TYPE),
AREAS_SERVED = (
	SELECT
		cbtf.AREAS_SERVED_NOTES "@NF",
		(SELECT
				cm.Code "@CD",
				cmne.Name "@V",
				cmnf.Name "@VF",
				dbo.fn_GBL_Community_AuthParent(cm.CM_ID,cm.CM_ID,5,bte.LangID) "@AP",
				dbo.fn_GBL_Community_AuthParent(cm.CM_ID,cm.CM_ID,5,btf.LangID) "@APF",
				pst.NameOrCode AS "@PRV",
				pst.Country AS "@CTRY",
				prnf.Notes "@NF"
			FROM CIC_BT_CM pr
			LEFT JOIN CIC_BT_CM_Notes prnf
				ON pr.BT_CM_ID=prnf.BT_CM_ID AND prnf.LangID=btf.LangID
			INNER JOIN GBL_Community cm
				ON pr.CM_ID=cm.CM_ID
			INNER JOIN GBL_Community_Name cmne
				ON cm.CM_ID=cmne.CM_ID AND cmne.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmne.CM_ID ORDER BY CASE WHEN LangID=bte.LangID THEN 0 ELSE 1 END, LangID)
			LEFT JOIN GBL_Community_Name cmnf
				ON cm.CM_ID=cmnf.CM_ID AND cmnf.LangID=btf.LangID
			LEFT JOIN GBL_ProvinceState pst
				ON cm.ProvinceState=pst.ProvID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('CM'),TYPE)
	FOR XML PATH('AREAS_SERVED'),TYPE
	),
BEST_TIME_TO_CALL = (SELECT ccbtf.BEST_TIME_TO_CALL "@VF" FOR XML PATH('BEST_TIME_TO_CALL'), TYPE),
BILLING_ADDRESSES = (
	SELECT
		(SELECT
			CASE WHEN LangID=0 THEN 'E' WHEN ba.LangID=2 THEN 'F' ELSE '?' END "@LANG",
			ba.GUID "@GID",
			AT.Code "@TYPE",
			ba.PRIORITY "@PRI",
			ba.SITE_CODE "@CD",
			ba.CAS_CONFIRMATION_DATE "@CCD",
			ba.LINE_1 "@LN1",
			ba.LINE_2 "@LN2",
			ba.LINE_3 "@LN3",
			ba.LINE_4 "@LN4",
			ba.CITY "@CTY",
			ba.PROVINCE "@PRV",
			ba.COUNTRY "@CTRY",
			ba.POSTAL_CODE "@PC"
		FROM GBL_BT_BILLINGADDRESS ba
		INNER JOIN GBL_BillingAddressType AT
			ON ba.ADDRTYPE=AT.AddressTypeID
		WHERE ba.NUM=bt.NUM AND (ba.LangID=btf.LangID)
		FOR XML PATH('ADDR'), TYPE)
	FOR XML PATH('BILLING_ADDRESSES'), TYPE
	),
BOUNDARIES = (SELECT cbtf.BOUNDARIES "@VF" FOR XML PATH('BOUNDARIES'), TYPE),
BUS_ROUTES = ISNULL((
	SELECT
		(SELECT
				br.RouteNumber "@NO",
				brne.NAME "@NM",
				brnf.NAME "@NMF",
				cmne.NAME "@MUN",
				cmnf.NAME "@MUNF"
			FROM CIC_BT_BR pr
			INNER JOIN CIC_BusRoute br
				ON pr.BR_ID=br.BR_ID
			LEFT JOIN CIC_BusRoute_Name brne
				ON br.BR_ID=brne.BR_ID AND brne.LangID=(SELECT TOP 1 LangID FROM CIC_BusRoute_Name WHERE BR_ID=brne.BR_ID ORDER BY CASE WHEN LangID=bte.LangID THEN 0 ELSE 1 END, LangID)
			LEFT JOIN CIC_BusRoute_Name brnf
				ON br.BR_ID=brnf.BR_ID AND brnf.LangID=btf.LangID
			LEFT JOIN GBL_Community cm
				ON br.Municipality=cm.CM_ID
			LEFT JOIN GBL_Community_Name cmne
				ON cm.CM_ID=cmne.CM_ID AND cmne.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmne.CM_ID ORDER BY CASE WHEN LangID=bte.LangID THEN 0 ELSE 1 END, LangID)
			LEFT JOIN GBL_Community_Name cmnf
				ON cm.CM_ID=cmnf.CM_ID AND cmnf.LangID=btf.LangID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('RT'), TYPE)
	FOR XML PATH('BUS_ROUTES'), TYPE
	),CAST('<BUS_ROUTES/>' AS XML)),
CC_LICENSE_INFO = (
	SELECT
		ccbt.LICENSE_NUMBER "@NO",
		ccbt.LICENSE_RENEWAL "@DATE",
		ccbt.LC_TOTAL "@TOT",
		ccbt.LC_INFANT "@INF",
		ccbt.LC_TODDLER "@TOD",
		ccbt.LC_PRESCHOOL "@PRE",
		ccbt.LC_KINDERGARTEN "@KIN",
		ccbt.LC_SCHOOLAGE "@SCH",
		ccbtf.LC_NOTES "@NF" 
	FOR XML PATH('CC_LICENSE_INFO'), TYPE
	),
CERTIFIED = ISNULL((
	SELECT
		crt.Code "@CD",
		crtne.NAME "@V",
		(SELECT crtnf.NAME FROM CIC_Certification_Name crtnf WHERE crtnf.CRT_ID=crt.CRT_ID AND crtnf.LangID=btf.LangID) "@VF"
	FROM CIC_Certification crt
	INNER JOIN CIC_Certification_Name crtne
		ON crtne.CRT_ID=crt.CRT_ID AND crtne.LangID=(SELECT TOP 1 LangID FROM CIC_Certification_Name WHERE CRT_ID=crtne.CRT_ID ORDER BY CASE WHEN LangID=bte.LangID THEN 0 ELSE 1 END, LangID)
	WHERE crt.CRT_ID=cbt.CERTIFIED
	FOR XML PATH('CERTIFIED'), TYPE
	), CAST('<CERTIFIED/>' AS XML)),
COLLECTED_BY = (SELECT btf.COLLECTED_BY "@VF" FOR XML PATH('COLLECTED_BY'), TYPE),
COLLECTED_DATE = (SELECT btf.COLLECTED_DATE "@VF" FOR XML PATH('COLLECTED_DATE'), TYPE),
COMMENTS = (SELECT cbtf.COMMENTS "@VF" FOR XML PATH('COMMENTS'), TYPE),
CONTACT_1 = (SELECT	dbo.fn_GBL_XML_Contact(
			'CONTACT_1',bt.NUM,
			0,
			1) AS [node()] FOR XML PATH('CONTACT_1'),TYPE),
CONTACT_2 = (SELECT	dbo.fn_GBL_XML_Contact(
			'CONTACT_2',bt.NUM,
			0,
			1) AS [node()] FOR XML PATH('CONTACT_2'),TYPE),
CONTRACT_SIGNATURE = (
	SELECT
		(SELECT
			cts.GUID "@GID",
			sig.Code "@STATUS",
			cts.SIGNATORY "@SIGNAME",
			cts.DATE "@DATE",
			cts.NOTES "@N"
		FROM GBL_BT_CONTRACTSIGNATURE cts
		INNER JOIN GBL_SignatureStatus sig
			ON cts.SIGSTATUS=sig.SIG_ID
		WHERE cts.NUM=bt.NUM
		FOR XML PATH('SIGNATURE'), TYPE)
	FOR XML PATH('CONTRACT_SIGNATURE'), TYPE
	),
CORP_REG_NO = (SELECT cbt.CORP_REG_NO "@V" FOR XML PATH('CORP_REG_NO'), TYPE),
CREATED_BY = (SELECT btf.CREATED_BY "@VF" FOR XML PATH('CREATED_BY'), TYPE),
CREATED_DATE = (SELECT btf.CREATED_DATE "@VF" FOR XML PATH('CREATED_DATE'), TYPE),
CRISIS_PHONE = (SELECT cbtf.CRISIS_PHONE "@VF" FOR XML PATH('CRISIS_PHONE'), TYPE),
DATES = (SELECT cbtf.DATES "@VF" FOR XML PATH('DATES'), TYPE),
DD_CODE = (SELECT cbt.DD_CODE "@V" FOR XML PATH('DD_CODE'), TYPE),
DELETED_BY = (SELECT btf.DELETED_BY "@VF" FOR XML PATH('DELETED_BY'), TYPE),
DELETION_DATE = (SELECT btf.DELETION_DATE "@VF" FOR XML PATH('DELETION_DATE'), TYPE),
DESCRIPTION = (SELECT btf.DESCRIPTION "@VF" FOR XML PATH('DESCRIPTION'), TYPE),
E_MAIL = (SELECT btf.E_MAIL "@VF" FOR XML PATH('E_MAIL'), TYPE),
ELECTIONS = (SELECT cbtf.ELECTIONS "@VF" FOR XML PATH('ELECTIONS'), TYPE),
ELIGIBILITY = (
	SELECT
		cbt.MIN_AGE "@MIN_AGE",
		cbt.MAX_AGE "@MAX_AGE",
		cbtf.ELIGIBILITY_NOTES "@NF"
	FOR XML PATH('ELIGIBILITY'), TYPE
	),
EMAIL_UPDATE_DATE = (SELECT bt.EMAIL_UPDATE_DATE "@V" FOR XML PATH('EMAIL_UPDATE_DATE'), TYPE),
EMPLOYEES = (
	SELECT
		cbt.EMPLOYEES_FT "@FT",
		cbt.EMPLOYEES_PT "@PT",
		cbt.EMPLOYEES_TOTAL "@TOT"
	FOR XML PATH('EMPLOYEES'), TYPE
	),
ESTABLISHED = (SELECT btf.ESTABLISHED "@VF" FOR XML PATH('ESTABLISHED'), TYPE),
EXEC_1 = (SELECT	dbo.fn_GBL_XML_Contact(
			'EXEC_1',bt.NUM,
			0,
			1) AS [node()] FOR XML PATH('EXEC_1'),TYPE),
EXEC_2 = (SELECT	dbo.fn_GBL_XML_Contact(
			'EXEC_2',bt.NUM,
			0,
			1) AS [node()] FOR XML PATH('EXEC_2'),TYPE),
EXTERNAL_ID = (SELECT bt.EXTERNAL_ID "@V" FOR XML PATH('EXTERNAL_ID'), TYPE),
EXTRA_CONTACT_A = (SELECT	dbo.fn_GBL_XML_Contact(
			'EXTRA_CONTACT_A',bt.NUM,
			0,
			1) AS [node()] FOR XML PATH('EXTRA_CONTACT_A'),TYPE),
FAX = (SELECT btf.FAX "@VF" FOR XML PATH('FAX'), TYPE),
FEES = (
	SELECT
		cbtf.FEE_NOTES "@NF",
		cbt.FEE_ASSISTANCE_AVAILABLE "@ASSIST",
		cbtf.FEE_ASSISTANCE_FOR "@ASSIST_FORF",
		cbtf.FEE_ASSISTANCE_FROM "@ASSIST_FROMF",
		(SELECT
				ft.Code "@CD",
				ftne.NAME "@V",
				ftnf.NAME "@VF",
				prnf.Notes "@NF"
			FROM CIC_BT_FT pr
			LEFT JOIN CIC_BT_FT_Notes prnf
				ON pr.BT_FT_ID=prnf.BT_FT_ID AND prnf.LangID=btf.LangID
			INNER JOIN CIC_FeeType ft
				ON pr.FT_ID=ft.FT_ID
			INNER JOIN CIC_FeeType_Name ftne
				ON ft.FT_ID=ftne.FT_ID AND ftne.LangID=(SELECT TOP 1 LangID FROM CIC_FeeType_Name WHERE FT_ID=ftne.FT_ID ORDER BY CASE WHEN LangID=bte.LangID THEN 0 ELSE 1 END, LangID)
			LEFT JOIN CIC_FeeType_Name ftnf
				ON ft.FT_ID=ftnf.FT_ID AND ftnf.LangID=btf.LangID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('CHK'),TYPE)
	FOR XML PATH('FEES'),TYPE
	),
FISCAL_YEAR_END = ISNULL((
	SELECT
		fye.Code "@CD",
		(SELECT fyene.NAME FROM CIC_FiscalYearEnd_Name fyene WHERE fyene.FYE_ID=fye.FYE_ID AND fyene.LangID=bte.LangID) "@V",
		(SELECT fyenf.NAME FROM CIC_FiscalYearEnd_Name fyenf WHERE fyenf.FYE_ID=fye.FYE_ID AND fyenf.LangID=btf.LangID) "@VF"
	FROM CIC_FiscalYearEnd fye
	WHERE fye.FYE_ID=cbt.FISCAL_YEAR_END
	FOR XML PATH('FISCAL_YEAR_END'), TYPE
	), CAST('<FISCAL_YEAR_END/>' AS XML)),
FORMER_ORG = ISNULL((
	SELECT
		(SELECT
				fo.FORMER_ORG "@V",
				fo.DATE_OF_CHANGE "@DATE",
				fo.PUBLISH "@PB",
				CASE WHEN fo.LangID=0 THEN 'E' WHEN LangID=2 THEN 'F' ELSE '?' END "@LANG"
			FROM GBL_BT_FORMERORG fo
			WHERE fo.NUM=bt.NUM AND (fo.LangID=btf.LangID)
			FOR XML PATH('NM'), TYPE)
	FOR XML PATH('FORMER_ORG'), TYPE
	),CAST('<FORMER_ORG/>' AS XML)),
FUNDING = (
	SELECT
		cbtf.FUNDING_NOTES "@NF",
		(SELECT
				fd.Code "@CD",
				fdne.NAME "@V",
				fdnf.NAME "@VF",
				prnf.Notes "@NF"
			FROM CIC_BT_FD pr
			LEFT JOIN CIC_BT_FD_Notes prnf
				ON pr.BT_FD_ID=prnf.BT_FD_ID AND prnf.LangID=btf.LangID
			INNER JOIN CIC_Funding fd
				ON pr.FD_ID=fd.FD_ID
			LEFT JOIN CIC_Funding_Name fdne
				ON fd.FD_ID=fdne.FD_ID AND fdne.LangID=bte.LangID
			LEFT JOIN CIC_Funding_Name fdnf
				ON fd.FD_ID=fdnf.FD_ID AND fdnf.LangID=btf.LangID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('CHK'),TYPE)
	FOR XML PATH('FUNDING'),TYPE
	),
GEOCODE = (
	SELECT
		bt.GEOCODE_TYPE "@TYPE",
		bt.LATITUDE "@LAT",
		bt.LONGITUDE "@LONG",
		btf.GEOCODE_NOTES "@NF"
	FOR XML PATH('GEOCODE'), TYPE
	),
[HOURS] = (SELECT cbtf.HOURS "@VF" FOR XML PATH('HOURS'), TYPE),
(SELECT	dbo.fn_GBL_XML_RecordNote(
			'INTERNAL_MEMO',bt.NUM,
			0,
			1) AS [node()] FOR XML PATH('INTERNAL_MEMO'),TYPE) AS INTERNAL_MEMO,
INTERSECTION = (SELECT cbtf.INTERSECTION "@VF" FOR XML PATH('INTERSECTION'), TYPE),
LANGUAGES = (
	SELECT
		cbtf.LANGUAGE_NOTES "@NF",
		(SELECT
				ln.Code "@CD",
				COALESCE(lnne.Name,lnnf.Name,ln.Code) "@V",
				lnnf.Name "@VF",
				prnf.Notes "@NF",
				(SELECT
						lnd.Code "@CD",
						COALESCE(lndne.Name,lndnf.Name,ln.Code) "@V",
						lndnf.Name "@VF"
					FROM dbo.CIC_BT_LN_LND prlnd
					INNER JOIN dbo.GBL_Language_Details lnd
						ON lnd.LND_ID=prlnd.LND_ID
					LEFT JOIN dbo.GBL_Language_Details_Name lndne
						ON lnd.LND_ID=lndne.LND_ID AND lndne.LangID=bte.LangID
					LEFT JOIN dbo.GBL_Language_Details_Name lndnf
						ON lnd.LND_ID=lndnf.LND_ID AND lndnf.LangID=btf.LangID
					WHERE prlnd.BT_LN_ID=pr.BT_LN_ID
					FOR XML PATH('SERVICE_TYPE'), TYPE)
			FROM CIC_BT_LN pr
			LEFT JOIN CIC_BT_LN_Notes prnf
				ON pr.BT_LN_ID=prnf.BT_LN_ID AND prnf.LangID=btf.LangID
			INNER JOIN GBL_Language ln
				ON pr.LN_ID=ln.LN_ID
			LEFT JOIN GBL_Language_Name lnne
				ON ln.LN_ID=lnne.LN_ID AND lnne.LangID=bte.LangID
			LEFT JOIN GBL_Language_Name lnnf
				ON ln.LN_ID=lnnf.LN_ID AND lnnf.LangID=btf.LangID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('CHK'),TYPE)
	FOR XML PATH('LANGUAGES'),TYPE
	),
LEGAL_ORG = (
	SELECT
		btf.LEGAL_ORG "@VF",
		btf.LO_PUBLISH "@PBF"
	FOR XML PATH('LEGAL_ORG'), TYPE
	),
LOCATED_IN_CM = ISNULL((
	SELECT
		cm.Code "@CD",
		(SELECT cmne.NAME FROM GBL_Community_Name cmne WHERE cmne.CM_ID=cm.CM_ID AND cmne.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmne.CM_ID ORDER BY CASE WHEN LangID=bte.LangID THEN 0 ELSE 1 END, LangID)) "@V",
		(SELECT cmnf.NAME FROM GBL_Community_Name cmnf WHERE cmnf.CM_ID=cm.CM_ID AND cmnf.LangID=btf.LangID) "@VF",
		dbo.fn_GBL_Community_AuthParent(cm.CM_ID,cm.CM_ID,5,bte.LangID) "@AP",
		dbo.fn_GBL_Community_AuthParent(cm.CM_ID,cm.CM_ID,5,btf.LangID) "@APF",
		pst.NameOrCode AS "@PRV",
		pst.Country AS "@CTRY"
	FROM GBL_Community cm
	LEFT JOIN GBL_ProvinceState pst
		ON cm.ProvinceState=pst.ProvID
	WHERE cm.CM_ID=bt.LOCATED_IN_CM
	FOR XML PATH('LOCATED_IN_CM'), TYPE
	), CAST('<LOCATED_IN_CM/>' AS XML)),
LOCATION_DESCRIPTION = (SELECT btf.LOCATION_DESCRIPTION "@VF" FOR XML PATH('LOCATION_DESCRIPTION'), TYPE),
LOCATION_NAME = (
	SELECT
		btf.LOCATION_NAME "@VF"
	FOR XML PATH('LOCATION_NAME'), TYPE
	),
LOCATION_SERVICES = (
	SELECT
		(SELECT
				pr.SERVICE_NUM "@V"
			FROM GBL_BT_LOCATION_SERVICE pr
			WHERE pr.LOCATION_NUM=bt.NUM
			FOR XML PATH('SERVICE_NUM'),TYPE)
	FOR XML PATH('LOCATION_SERVICES'),TYPE
	),
LOGO_ADDRESS = (SELECT cbtf.LOGO_ADDRESS "@VF" FOR XML PATH('LOGO_ADDRESS'), TYPE),
MAIL_ADDRESS = (
	SELECT 
		btf.MAIL_CARE_OF "@COF",
		btf.MAIL_BOX_TYPE "@BXTPF",
		btf.MAIL_PO_BOX "@BOXF",
		btf.MAIL_BUILDING "@BLDF",
		btf.MAIL_STREET_NUMBER "@STNUMF",
		btf.MAIL_STREET "@STF",
		btf.MAIL_STREET_TYPE "@STTYPEF",
		btf.MAIL_STREET_TYPE_AFTER "@STTYPEAFTERF",
		btf.MAIL_STREET_DIR "@STDIRF",
		btf.MAIL_SUFFIX "@SFXF",
		btf.MAIL_CITY "@CTYF",
		btf.MAIL_PROVINCE "@PRVF",
		btf.MAIL_COUNTRY "@CTRYF",
		bt.MAIL_POSTAL_CODE "@PC"
	FOR XML PATH('MAIL_ADDRESS'), TYPE
	),
MEETINGS = (SELECT cbtf.MEETINGS "@VF" FOR XML PATH('MEETINGS'), TYPE),
MEMBERSHIP = (
	SELECT
		cbtf.MEMBERSHIP_NOTES "@NF",
		(SELECT
				mt.Code "@CD",
				mtne.NAME "@V",
				mtnf.NAME "@VF"
			FROM CIC_BT_MT pr
			INNER JOIN CIC_MembershipType mt
				ON pr.MT_ID=mt.MT_ID
			LEFT JOIN CIC_MembershipType_Name mtne
				ON mt.MT_ID=mtne.MT_ID AND mtne.LangID=bte.LangID
			LEFT JOIN CIC_MembershipType_Name mtnf
				ON mt.MT_ID=mtnf.MT_ID AND mtnf.LangID=btf.LangID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('CHK'),TYPE)
	FOR XML PATH('MEMBERSHIP'),TYPE
	),
MODIFIED_BY = (SELECT btf.MODIFIED_BY "@VF" FOR XML PATH('MODIFIED_BY'), TYPE),
MODIFIED_DATE = (SELECT btf.MODIFIED_DATE "@VF" FOR XML PATH('MODIFIED_DATE'), TYPE),
NAICS = (
	SELECT
		(SELECT
				pr.Code "@V"
			FROM CIC_BT_NC pr
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('CD'),TYPE)
	FOR XML PATH('NAICS'),TYPE
	),
NO_UPDATE_EMAIL = (SELECT bt.NO_UPDATE_EMAIL "@V" FOR XML PATH('NO_UPDATE_EMAIL'), TYPE),
NON_PUBLIC = (SELECT btf.NON_PUBLIC "@VF" FOR XML PATH('NON_PUBLIC'), TYPE),
OCG_NO = (SELECT cbt.OCG_NO "@V" FOR XML PATH('OCG_NO'), TYPE),
OFFICE_PHONE = (SELECT btf.OFFICE_PHONE "@VF" FOR XML PATH('OFFICE_PHONE'), TYPE),
ORG_DESCRIPTION = (SELECT btf.ORG_DESCRIPTION "@VF" FOR XML PATH('ORG_DESCRIPTION'), TYPE),
ORG_LEVEL_1 = (
	SELECT
		btf.ORG_LEVEL_1 "@VF"
	FOR XML PATH('ORG_LEVEL_1'), TYPE
	),
ORG_LEVEL_2 = (
	SELECT
		btf.ORG_LEVEL_2 "@VF",
		btf.O2_PUBLISH "@PBF"
	FOR XML PATH('ORG_LEVEL_2'), TYPE
	),
ORG_LEVEL_3 = (
	SELECT
		btf.ORG_LEVEL_3 "@VF",
		btf.O3_PUBLISH "@PBF"
	FOR XML PATH('ORG_LEVEL_3'), TYPE
	),
ORG_LEVEL_4 = (
	SELECT
		btf.ORG_LEVEL_4 "@VF",
		btf.O4_PUBLISH "@PBF"
	FOR XML PATH('ORG_LEVEL_4'), TYPE
	),
ORG_LEVEL_5 = (
	SELECT
		btf.ORG_LEVEL_5 "@VF",
		btf.O5_PUBLISH "@PBF"
	FOR XML PATH('ORG_LEVEL_5'), TYPE
	),
ORG_LOCATION_SERVICE = (
	SELECT
		(SELECT
				ols.Code "@V"
			FROM GBL_BT_OLS pr
			INNER JOIN GBL_OrgLocationService ols
				ON pr.OLS_ID=ols.OLS_ID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('CD'), TYPE)
	FOR XML PATH('ORG_LOCATION_SERVICE'), TYPE
	),
ORG_NUM = (SELECT
		bt.ORG_NUM "@V",
		bt.DISPLAY_ORG_NAME "@DISPLAY_ORG_NAME"
	FOR XML PATH('ORG_NUM'), TYPE),
OTHER_ADDRESSES = (
	SELECT
		(SELECT
			CASE WHEN LangID=0 THEN 'E' WHEN pr.LangID=2 THEN 'F' ELSE '?' END "@LANG",
			pr.GUID "@GID",
			pr.TITLE "@TTL",
			pr.SITE_CODE "@CD",
			pr.CARE_OF "@CO",
			pr.BOX_TYPE "@BXTP",
			pr.PO_BOX "@BOX",
			pr.BUILDING "@BLD",
			pr.STREET_NUMBER "@STNUM",
			pr.STREET "@ST",
			pr.STREET_TYPE "@STTYPE",
			pr.STREET_TYPE_AFTER "@STTYPEAFTER",
			pr.STREET_DIR "@STDIR",
			pr.SUFFIX "@SFX",
			pr.CITY "@CTY",
			pr.PROVINCE "@PRV",
			pr.COUNTRY "@CTRY",
			pr.POSTAL_CODE "@PC"
			FROM CIC_BT_OTHERADDRESS pr
			WHERE pr.NUM=bt.NUM AND (pr.LangID=btf.LangID)
			FOR XML PATH('ADDR'),TYPE)
	FOR XML PATH('OTHER_ADDRESSES'),TYPE
	),
PAYMENT_TERMS = ISNULL((
	SELECT
		pyt.Code "@CD",
		(SELECT pytne.NAME FROM GBL_PaymentTerms_Name pytne WHERE pytne.PYT_ID=pyt.PYT_ID AND pytne.LangID=bte.LangID) "@V",
		(SELECT pytnf.NAME FROM GBL_PaymentTerms_Name pytnf WHERE pytnf.PYT_ID=pyt.PYT_ID AND pytnf.LangID=btf.LangID) "@VF"
	FROM GBL_PaymentTerms pyt
	WHERE pyt.PYT_ID=cbt.PAYMENT_TERMS
	FOR XML PATH('PAYMENT_TERMS'), TYPE
	), CAST('<PAYMENT_TERMS/>' AS XML)),
PREF_CURRENCY = ISNULL((
	SELECT
		cur.Currency "@V"
	FROM GBL_Currency cur
	WHERE cur.CUR_ID=cbt.PREF_CURRENCY
	FOR XML PATH('PREF_CURRENCY'), TYPE
	), CAST('<PREF_CURRENCY/>' AS XML)),
PREF_PAYMENT_METHOD = ISNULL((
	SELECT
		pay.Code "@CD",
		(SELECT payne.NAME FROM GBL_PaymentMethod_Name payne WHERE payne.PAY_ID=pay.PAY_ID AND payne.LangID=bte.LangID) "@V",
		(SELECT paynf.NAME FROM GBL_PaymentMethod_Name paynf WHERE paynf.PAY_ID=pay.PAY_ID AND paynf.LangID=btf.LangID) "@VF"
	FROM GBL_PaymentMethod pay
	WHERE pay.PAY_ID=cbt.PREF_PAYMENT_METHOD
	FOR XML PATH('PREF_PAYMENT_METHOD'), TYPE
	), CAST('<PREF_PAYMENT_METHOD/>' AS XML)),
PRINT_MATERIAL = (SELECT cbtf.PRINT_MATERIAL "@VF" FOR XML PATH('PRINT_MATERIAL'), TYPE),
PUBLIC_COMMENTS = (SELECT cbtf.PUBLIC_COMMENTS "@VF" FOR XML PATH('PUBLIC_COMMENTS'), TYPE),
QUALITY = ISNULL((
	SELECT
		rq.Quality "@V"
	FROM CIC_Quality rq
	WHERE rq.RQ_ID=cbt.QUALITY
	FOR XML PATH('QUALITY'), TYPE
	), CAST('<QUALITY/>' AS XML)),
RECORD_TYPE = ISNULL((
	SELECT
		rt.RecordType "@V"
	FROM CIC_RecordType rt
	WHERE rt.RT_ID=cbt.RECORD_TYPE
	FOR XML PATH('RECORD_TYPE'), TYPE
	), CAST('<RECORD_TYPE/>' AS XML)),
RESOURCES = (SELECT cbtf.RESOURCES "@VF" FOR XML PATH('RESOURCES'), TYPE),
SERVICE_LEVEL = (
	SELECT
		(SELECT
				sl.ServiceLevelCode "@V"
			FROM CIC_BT_SL pr
			INNER JOIN CIC_ServiceLevel sl
				ON pr.SL_ID=sl.SL_ID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('CD'),TYPE)
	FOR XML PATH('SERVICE_LEVEL'),TYPE
	),
SERVICE_NAME_LEVEL_1 = (
	SELECT
		btf.SERVICE_NAME_LEVEL_1 "@VF",
		btf.S1_PUBLISH "@PBF"
	FOR XML PATH('SERVICE_NAME_LEVEL_1'), TYPE
	),
SERVICE_NAME_LEVEL_2 = (
	SELECT
		btf.SERVICE_NAME_LEVEL_2 "@VF",
		btf.S2_PUBLISH "@PBF"
	FOR XML PATH('SERVICE_NAME_LEVEL_2'), TYPE
	),
SCHOOL_ESCORT = (
	SELECT
		ccbtf.SCHOOL_ESCORT_NOTES "@NF",
		(SELECT
				schne.NAME "@V",
				schnf.NAME "@VF",
				sch.SchoolBoard "@BRD",				
				prnf.EscortNotes "@NF"
			FROM CCR_BT_SCH pr
			LEFT JOIN CCR_BT_SCH_Notes prnf
				ON pr.BT_SCH_ID=prnf.BT_SCH_ID AND prnf.LangID=btf.LangID
			INNER JOIN CCR_School sch
				ON pr.SCH_ID=sch.SCH_ID
			LEFT JOIN CCR_School_Name schne
				ON sch.SCH_ID=schne.SCH_ID AND schne.LangID=bte.LangID
			LEFT JOIN CCR_School_Name schnf
				ON sch.SCH_ID=schnf.SCH_ID AND schnf.LangID=btf.LangID
			WHERE pr.NUM=bt.NUM
				AND pr.Escort=1
			FOR XML PATH('CHK'),TYPE)
	FOR XML PATH('SCHOOL_ESCORT'),TYPE
	),
SCHOOLS_IN_AREA = (
	SELECT
		ccbtf.SCHOOLS_IN_AREA_NOTES "@NF",
		(SELECT
				schne.NAME "@V",
				schnf.NAME "@VF",
				sch.SchoolBoard "@BRD",				
				prnf.InAreaNotes "@NF"
			FROM CCR_BT_SCH pr
			LEFT JOIN CCR_BT_SCH_Notes prnf
				ON pr.BT_SCH_ID=prnf.BT_SCH_ID AND prnf.LangID=btf.LangID
			INNER JOIN CCR_School sch
				ON pr.SCH_ID=sch.SCH_ID
			LEFT JOIN CCR_School_Name schne
				ON sch.SCH_ID=schne.SCH_ID AND schne.LangID=bte.LangID
			LEFT JOIN CCR_School_Name schnf
				ON sch.SCH_ID=schnf.SCH_ID AND schnf.LangID=btf.LangID
			WHERE pr.NUM=bt.NUM
				AND pr.InArea=1
			FOR XML PATH('CHK'),TYPE)
	FOR XML PATH('SCHOOLS_IN_AREA'),TYPE
	),
SITE_ADDRESS = (
	SELECT 
		btf.SITE_BUILDING "@BLDF",
		btf.SITE_STREET_NUMBER "@STNUMF",
		btf.SITE_STREET "@STF",
		btf.SITE_STREET_TYPE "@STTYPEF",
		btf.SITE_STREET_TYPE_AFTER "@STTYPEAFTERF",
		btf.SITE_STREET_DIR "@STDIRF",
		btf.SITE_SUFFIX "@SFXF",
		btf.SITE_CITY "@CTYF",
		btf.SITE_PROVINCE "@PRVF",
		btf.SITE_COUNTRY "@CTRYF",
		bt.SITE_POSTAL_CODE "@PC"
	FOR XML PATH('SITE_ADDRESS'), TYPE
	),
SITE_LOCATION = (SELECT cbtf.SITE_LOCATION "@VF" FOR XML PATH('SITE_LOCATION'), TYPE),
SOCIAL_MEDIA = (
	SELECT
		(SELECT
				sm.DefaultName "@NM",
				CASE WHEN pr.Protocol <> 'http://' THEN Protocol ELSE NULL END "@PROTOCOL",
				pr.URL "@URL",
				CASE WHEN pr.LangID=0 THEN 'E' WHEN LangID=2 THEN 'F' ELSE '?' END "@LANG"
			FROM GBL_BT_SM pr
			INNER JOIN GBL_SocialMedia sm
				ON pr.SM_ID=sm.SM_ID
			WHERE pr.NUM=bt.NUM AND pr.LangID=btf.LangID
			FOR XML PATH('TYPE'), TYPE)
	FOR XML PATH('SOCIAL_MEDIA'), TYPE
	),
SORT_AS = (SELECT btf.SORT_AS "@VF" FOR XML PATH('SORT_AS'), TYPE),
[SOURCE] = (
	SELECT 
		btf.SOURCE_NAME "@NMF",
		btf.SOURCE_TITLE "@TTLF",
		btf.SOURCE_ORG "@ORGF",
		btf.SOURCE_PHONE "@PHNF",
		btf.SOURCE_FAX "@FAXF",
		btf.SOURCE_EMAIL "@EMLF",
		btf.SOURCE_BUILDING "@BLDF",
		btf.SOURCE_ADDRESS "@ADDRF",
		btf.SOURCE_CITY "@CTYF",
		btf.SOURCE_PROVINCE "@PRVF",
		btf.SOURCE_POSTAL_CODE "@PCF"
	FOR XML PATH('SOURCE'), TYPE
	),
SPACE_AVAILABLE = (
	SELECT
		ccbt.SPACE_AVAILABLE "@V",
		ccbtf.SPACE_AVAILABLE_NOTES "@NF",
		ccbt.SPACE_AVAILABLE_DATE "@DATE"
	FOR XML PATH('SPACE_AVAILABLE'), TYPE
	),
SUBJECTS = (
	SELECT
		(SELECT
				sjne.NAME "@V",
				sjnf.NAME "@VF"
			FROM CIC_BT_SBJ pr
			INNER JOIN THS_Subject sj
				ON pr.Subj_ID=sj.Subj_ID
			LEFT JOIN THS_Subject_Name sjne
				ON sj.Subj_ID=sjne.Subj_ID AND sjne.LangID=(SELECT TOP 1 LangID FROM THS_Subject_Name WHERE Subj_ID=sjne.Subj_ID ORDER BY CASE WHEN LangID=bte.LangID THEN 0 ELSE 1 END, LangID)
			LEFT JOIN THS_Subject_Name sjnf
				ON sj.Subj_ID=sjnf.Subj_ID AND sjnf.LangID=btf.LangID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('TM'),TYPE)
	FOR XML PATH('SUBJECTS'),TYPE
	),
SUBSIDY = (SELECT ccbt.SUBSIDY "@V" FOR XML PATH('SUBSIDY'), TYPE),
SUP_DESCRIPTION = (SELECT cbtf.SUP_DESCRIPTION "@VF" FOR XML PATH('SUP_DESCRIPTION'), TYPE),
TAX_REG_NO = (SELECT cbt.TAX_REG_NO "@V" FOR XML PATH('TAX_REG_NO'), TYPE),
TAXONOMY = (
	SELECT
		cbt.TAX_MODIFIED_BY "@MODBY",
		cbt.TAX_MODIFIED_DATE "@MOD",
		(SELECT
			(SELECT
				tlt.Code "@V"
			FROM CIC_BT_TAX_TM tlt
			WHERE tlt.BT_TAX_ID = tl.BT_TAX_ID
			FOR XML PATH('TM'),TYPE)
		FROM CIC_BT_TAX tl
		WHERE tl.NUM = bt.NUM
		FOR XML PATH('LNK'),TYPE)
	FOR XML PATH('TAXONOMY'),TYPE
	),
TDD_PHONE = (SELECT cbtf.TDD_PHONE "@VF" FOR XML PATH('TDD_PHONE'), TYPE),
TOLL_FREE_PHONE = (SELECT btf.TOLL_FREE_PHONE "@VF" FOR XML PATH('TOLL_FREE_PHONE'), TYPE),
TRANSPORTATION = (SELECT cbtf.TRANSPORTATION "@VF" FOR XML PATH('TRANSPORTATION'), TYPE),
TYPE_OF_CARE = (
	SELECT
		ccbtf.TYPE_OF_CARE_NOTES "@NF",
		(SELECT
				tocne.NAME "@V",
				tocnf.NAME "@VF",	
				prnf.Notes "@NF"
			FROM CCR_BT_TOC pr
			LEFT JOIN CCR_BT_TOC_Notes prnf
				ON pr.BT_TOC_ID=prnf.BT_TOC_ID AND prnf.LangID=btf.LangID
			INNER JOIN CCR_TypeOfCare toc
				ON pr.TOC_ID=toc.TOC_ID
			LEFT JOIN CCR_TypeOfCare_Name tocne
				ON toc.TOC_ID=tocne.TOC_ID AND tocne.LangID=bte.LangID
			LEFT JOIN CCR_TypeOfCare_Name tocnf
				ON toc.TOC_ID=tocnf.TOC_ID AND tocnf.LangID=btf.LangID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('CHK'),TYPE)
	FOR XML PATH('TYPE_OF_CARE'),TYPE
	),
TYPE_OF_PROGRAM = ISNULL((
	SELECT
		[top].Code "@CD",
		(SELECT topne.NAME FROM CCR_TypeOfProgram_Name topne WHERE topne.TOP_ID=[top].TOP_ID AND topne.LangID=bte.LangID) "@V",
		(SELECT topnf.NAME FROM CCR_TypeOfProgram_Name topnf WHERE topnf.TOP_ID=[top].TOP_ID AND topnf.LangID=btf.LangID) "@VF"
	FROM CCR_TypeOfProgram [top]
	WHERE [top].TOP_ID=ccbt.TYPE_OF_PROGRAM
	FOR XML PATH('TYPE_OF_PROGRAM'), TYPE
	), CAST('<TYPE_OF_PROGRAM/>' AS XML)),
UPDATE_DATE = (SELECT btf.UPDATE_DATE "@VF" FOR XML PATH('UPDATE_DATE'), TYPE),
UPDATE_EMAIL = (SELECT bt.UPDATE_EMAIL "@V" FOR XML PATH('UPDATE_EMAIL'), TYPE),
UPDATE_HISTORY = (SELECT btf.UPDATE_HISTORY "@VF" FOR XML PATH('UPDATE_HISTORY'), TYPE),
UPDATE_SCHEDULE = (SELECT btf.UPDATE_SCHEDULE "@VF" FOR XML PATH('UPDATE_SCHEDULE'), TYPE),
UPDATED_BY = (SELECT btf.UPDATED_BY "@VF" FOR XML PATH('UPDATED_BY'), TYPE),
VACANCY_INFO = (
	SELECT
		cbtf.VACANCY_NOTES "@NF",
		(SELECT
			pr.GUID "@GID",
			prnf.ServiceTitle "@SVCF",
			vutne.NAME "@NM",
			vutnf.NAME "@NMF",
			pr.Capacity "@CAP",
			pr.FundedCapacity "@FUNDCAP",
			pr.HoursPerDay "@HOURS",
			pr.DaysPerWeek "@DAYS",
			pr.WeeksPerYear "@WEEKS",
			pr.FullTimeEquivalent "@FTE",
			pr.Vacancy "@VAC",
			pr.WaitList "@WAIT",
			pr.WaitListDate "@WAITD",
			prnf.Notes "@NF",
			vut.MODIFIED_DATE "@MOD",
			(SELECT
				vtpne.NAME "@NM",
				vtpnf.NAME "@NMF"
				FROM CIC_BT_VUT_TP vtp
				INNER JOIN CIC_Vacancy_TargetPop tp
					ON vtp.VTP_ID = tp.VTP_ID
				LEFT JOIN CIC_Vacancy_TargetPop_Name vtpne
					ON vtp.VTP_ID=vtpne.VTP_ID AND vtpne.LangID=bte.LangID
				LEFT JOIN CIC_Vacancy_TargetPop_Name vtpnf
					ON vtp.VTP_ID=vtpnf.VTP_ID AND vtpnf.LangID=btf.LangID
				WHERE vtp.BT_VUT_ID = pr.BT_VUT_ID
				FOR XML PATH('TP'),TYPE)
			FROM CIC_BT_VUT pr
			LEFT JOIN CIC_BT_VUT_Notes prnf
				ON pr.BT_VUT_ID=prnf.BT_VUT_ID AND prnf.LangID=btf.LangID
			INNER JOIN CIC_Vacancy_UnitType vut
				ON pr.VUT_ID=vut.VUT_ID
			LEFT JOIN CIC_Vacancy_UnitType_Name vutne
				ON vut.VUT_ID=vutne.VUT_ID AND vutne.LangID=bte.LangID
			LEFT JOIN CIC_Vacancy_UnitType_Name vutnf
				ON vut.VUT_ID=vutnf.VUT_ID AND vutnf.LangID=btf.LangID
			WHERE pr.NUM=bt.NUM
			FOR XML PATH('UNIT'),TYPE)
	FOR XML PATH('VACANCY_INFO'),TYPE
	),
VOLCONTACT = (SELECT	dbo.fn_GBL_XML_Contact(
			'VOLCONTACT',bt.NUM,
			0,
			1) AS [node()] FOR XML PATH('VOLCONTACT'),TYPE),
WARD = ISNULL((
	SELECT
		wd.WardNumber "@V",
		(SELECT cmne.NAME FROM GBL_Community_Name cmne WHERE cmne.CM_ID=cm.CM_ID AND cmne.LangID=bte.LangID) "@MUN",
		(SELECT cmnf.NAME FROM GBL_Community_Name cmnf WHERE cmnf.CM_ID=cm.CM_ID AND cmnf.LangID=btf.LangID) "@MUNF",
		dbo.fn_GBL_Community_AuthParent(cm.CM_ID,cm.CM_ID,5,bte.LangID) "@AP",
		dbo.fn_GBL_Community_AuthParent(cm.CM_ID,cm.CM_ID,5,btf.LangID) "@APF",
		pst.NameOrCode AS "@PRV",
		pst.Country AS "@CTRY"
	FROM CIC_Ward wd
	LEFT JOIN GBL_Community cm
		ON wd.Municipality=cm.CM_ID
	LEFT JOIN GBL_ProvinceState pst
		ON cm.ProvinceState=pst.ProvID
	WHERE wd.WD_ID=cbt.WARD
	FOR XML PATH('WARD'), TYPE
	), CAST('<WARD/>' AS XML)),
WCB_NO = (SELECT cbt.WCB_NO "@V" FOR XML PATH('WCB_NO'), TYPE),
WWW_ADDRESS = (SELECT btf.WWW_ADDRESS "@VF" FOR XML PATH('WWW_ADDRESS'), TYPE)
FROM (SELECT 0 AS LangID) bte,
	GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btf
		ON bt.NUM=btf.NUM AND btf.LangID=2
	LEFT JOIN CIC_BaseTable cbt
		ON bt.NUM = cbt.NUM
	LEFT JOIN CIC_BaseTable_Description cbtf
		ON cbt.NUM=cbtf.NUM AND cbtf.LangID=btf.LangID
	LEFT JOIN CCR_BaseTable ccbt
		ON bt.NUM = ccbt.NUM
	LEFT JOIN CCR_BaseTable_Description ccbtf
		ON ccbt.NUM=ccbtf.NUM AND ccbtf.LangID=btf.LangID











GO




GRANT SELECT ON  [dbo].[CIC_SHARE_VIEW_FR] TO [cioc_login_role]
GO
