SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_iCarolExport_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		INT
SET @Error = 0

DECLARE @nLine char(2),
		@nLine10 char(1)

SET @nLine = CHAR(13) + CHAR(10)
SET @nLine10 = CHAR(10)

DECLARE @ADD_TO_BT_LOCATION_SERVICE table ( NUM varchar(8) PRIMARY KEY )
INSERT INTO @ADD_TO_BT_LOCATION_SERVICE
		(NUM)
SELECT bt.NUM
FROM dbo.GBL_BaseTable bt
WHERE ORG_NUM='ZZZ00001'
	AND EXISTS(SELECT * FROM dbo.GBL_BT_OLS pr INNER JOIN dbo.GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code='TOPIC' WHERE pr.NUM=bt.NUM)
	AND NOT EXISTS(SELECT * FROM dbo.GBL_BT_LOCATION_SERVICE WHERE SERVICE_NUM=bt.NUM)

UPDATE dbo.GBL_BaseTable SET DISPLAY_LOCATION_NAME=0 WHERE DISPLAY_LOCATION_NAME=1 AND EXISTS(SELECT * FROM @ADD_TO_BT_LOCATION_SERVICE WHERE NUM=GBL_BaseTable.NUM)

INSERT INTO dbo.GBL_BT_LOCATION_SERVICE (LOCATION_NUM, SERVICE_NUM)
SELECT 'ZZZ00002', bt.NUM
FROM @ADD_TO_BT_LOCATION_SERVICE bt

DECLARE @SiteCityTable table (
	SITE_CITY nvarchar(100) PRIMARY KEY NOT NULL,
	EXPORT_CITY nvarchar(100)
)

INSERT INTO @SiteCityTable ( SITE_CITY )
SELECT DISTINCT SITE_CITY FROM dbo.GBL_BaseTable_Description WHERE SITE_CITY IS NOT NULL

UPDATE @SiteCityTable
	SET EXPORT_CITY =
		(SELECT TOP 1
		CASE WHEN excm.AIRSExportType='Community'
			THEN (SELECT AreaName FROM dbo.GBL_Community_External_Community excm2 WHERE excm2.EXT_ID=excm.Parent_ID)
			ELSE AreaName
		END
		FROM dbo.GBL_Community_External_Community excm
		WHERE excm.SystemCode= 'ICAROLSTD' -- 'ONTARIO211'
			AND (
				excm.AreaName=SITE_CITY
				OR EXISTS(SELECT *
					FROM dbo.GBL_Community_External_Map map
					INNER JOIN dbo.GBL_Community_Name cmn ON cmn.CM_ID=map.CM_ID
						AND cmn.Name=SITE_CITY AND cmn.ProvinceStateCache=9
					WHERE excm.EXT_ID=map.MapOneEXTID
				)
			)
		ORDER BY
			CASE WHEN excm.AreaName=SITE_CITY THEN 0 ELSE 1 END,
			CASE WHEN excm.AIRSExportType='City' THEN 0 ELSE 1 END,
			CASE WHEN excm.AIRSExportType='Community' THEN 0 ELSE 1 END
		)

SELECT TOP (100)
	bt.NUM, ols.Code OLSCode, btols.EXTERNAL_ID, btols.BT_OLS_ID,
	(SELECT 
	   -- Deletions need to happen in reverse order to undo links. They should be handled separately
	   -- TODO - Deletions will be soft delete via status inactive & exclude from public resource directory(website) & exclude from print directory
	   -- REPLACE(cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(btd.DELETION_DATE), ' ', 'T') AS "@deletionDate",
	   bt.NUM AS "@uniquePriorID",
	   CASE WHEN btd.LangID=0 THEN 'en' ELSE 'fr' END AS "@cultureCode",
	   CASE 
			WHEN ols.Code = 'AGENCY' THEN 'Agency'
			WHEN ols.Code = 'SITE' THEN 'Site'
			WHEN ols.Code = 'SERVICE' THEN 'Program'
			WHEN ols.Code = 'TOPIC' THEN 'Program'
		END AS "@type",
		'Active'AS "@status",
		CASE WHEN ols.CODE  IN ('SERVICE',  'TOPIC') THEN cbtd.CMP_AreasServed ELSE NULL END AS "@coverageNote",
		CASE 
			WHEN ols.Code = 'AGENCY' THEN ISNULL(ISNULL(
				CASE WHEN btd.ORG_DESCRIPTION LIKE '%<br>%' OR btd.DESCRIPTION LIKE '%<p>%' THEN REPLACE(btd.ORG_DESCRIPTION,'<br>','<br />') ELSE REPLACE(btd.ORG_DESCRIPTION,@nLine10,@nLine10 + '<br />') END,
				CASE WHEN btd.DESCRIPTION LIKE '%<br>%' OR btd.DESCRIPTION LIKE '%<p>%' THEN REPLACE(btd.DESCRIPTION,'<br>','<br />') ELSE REPLACE(btd.DESCRIPTION,@nLine10,@nLine10 + '<br />') END),
				'Agency')
			WHEN ols.Code = 'SITE' THEN ISNULL(btd.LOCATION_DESCRIPTION,cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Agency Location',btd.LangID))
			WHEN ols.Code in ('SERVICE', 'TOPIC') THEN CASE WHEN btd.DESCRIPTION LIKE '%<br>%' OR btd.DESCRIPTION LIKE '%<p>%' THEN REPLACE(btd.DESCRIPTION,'<br>','<br />') ELSE REPLACE(btd.DESCRIPTION,@nLine10,@nLine10 + '<br />') END 
		END AS "@description",
		CASE WHEN ols.CODE = 'AGENCY' THEN dbo.fn_CIC_NUMToServiceLevel(bt.NUM,btd.LangID) ELSE NULL END AS "@legalStatus",
		CASE WHEN ols.CODE  IN ('SERVICE',  'TOPIC') THEN cbtd.CMP_Languages ELSE NULL END AS "@languagesOfferedText",
		btd.NON_PUBLIC AS "@isConfidential",
		CASE WHEN ols.CODE  IN ('SERVICE',  'TOPIC') THEN cbtd.CMP_Fees ELSE NULL END AS "@fees",
		CASE WHEN ols.CODE  IN ('SERVICE',  'TOPIC') THEN cbtd.DOCUMENTS_REQUIRED ELSE NULL END AS "@requiredDocumentation",
		CASE WHEN ols.CODE  IN ('SERVICE',  'TOPIC') THEN cbtd.APPLICATION ELSE NULL END AS "@applicationProcess",
		CASE WHEN ols.CODE = 'AGENCY' THEN dbo.fn_CIC_DisplayAccreditation(cbt.ACCREDITED,btd.LangID) ELSE NULL END AS "@licenseAccreditation",
		CASE WHEN ols.CODE = 'AGENCY' THEN btd.ESTABLISHED ELSE NULL END AS "@yearIncorporated",
		CASE WHEN ols.CODE  IN ('SERVICE',  'TOPIC') THEN STUFF(
			COALESCE('<br />' + cioc_shared.dbo.fn_SHR_CIC_FullEligibility(MIN_AGE, MAX_AGE, cbtd.ELIGIBILITY_NOTES),'') +
			COALESCE('<br />Residency Requirements: ' + cbtd.BOUNDARIES,''),
			1, 6, ''
		) ELSE NULL END AS "@eligibility",
		btd.UPDATED_BY AS "@lastVerificationApprovedBy",
		btd.SOURCE_EMAIL AS "@lastVerifiedByEmail",
		btd.SOURCE_NAME AS "@lastVerifiedByName",
		btd.SOURCE_PHONE AS "@lastVerifiedByPhoneNumber",
		btd.SOURCE_TITLE AS "@lastVerifiedByTitle",
		REPLACE(cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(btd.UPDATE_DATE), ' ', 'T') AS "@lastVerifiedOn",

	   (SELECT 
	       (SELECT 
			CASE WHEN ols.Code = 'AGENCY' THEN 
					STUFF(
			COALESCE(', ' + btd.ORG_LEVEL_1,'') +
			COALESCE(', ' + btd.ORG_LEVEL_2,'') +
			COALESCE(', ' + btd.ORG_LEVEL_3,'') +
			COALESCE(', ' + btd.ORG_LEVEL_4,'') +
			COALESCE(', ' + btd.ORG_LEVEL_5,''),
			1, 2, ''
		)
		WHEN ols.Code = 'SITE' THEN 
			(SELECT 
				ISNULL(btd.LOCATION_NAME,
				ISNULL(STUFF(
						COALESCE(', ' + CASE WHEN btd.ORG_LEVEL_1=abtd.ORG_LEVEL_1 THEN NULL ELSE btd.ORG_LEVEL_1 END,'')
						+ COALESCE(', ' + CASE WHEN btd.ORG_LEVEL_1=abtd.ORG_LEVEL_1 AND btd.ORG_LEVEL_2=abtd.ORG_LEVEL_2 THEN NULL ELSE btd.ORG_LEVEL_2 END,'')
						+ COALESCE(', ' + CASE WHEN btd.ORG_LEVEL_1=abtd.ORG_LEVEL_1 AND btd.ORG_LEVEL_2=abtd.ORG_LEVEL_2 AND btd.ORG_LEVEL_3=abtd.ORG_LEVEL_3 THEN NULL ELSE btd.ORG_LEVEL_3 END,'')
						+ COALESCE(', ' + CASE WHEN btd.ORG_LEVEL_1=abtd.ORG_LEVEL_1 AND btd.ORG_LEVEL_2=abtd.ORG_LEVEL_2 AND btd.ORG_LEVEL_3=abtd.ORG_LEVEL_3 AND btd.ORG_LEVEL_4=abtd.ORG_LEVEL_4 THEN NULL ELSE btd.ORG_LEVEL_4 END,'')
						+ COALESCE(', ' + btd.ORG_LEVEL_5,''),
						1, 2, ''
					),
					ISNULL(btd.ORG_LEVEL_1,'') + ISNULL(', ' + btd.ORG_LEVEL_2,'') + ISNULL(', ' + btd.ORG_LEVEL_3,'') + ISNULL(', ' + btd.ORG_LEVEL_4,'') + ISNULL(', ' + btd.ORG_LEVEL_5,'')
				)
				)
			FROM (VALUES (ISNULL(bt.ORG_NUM, bt.NUM), btd.LangID)) AS sbt(ORG_NUM, LangID)
			LEFT JOIN GBL_BaseTable_Description abtd
				ON abtd.NUM = sbt.ORG_NUM AND abtd.LangID = sbt.LangID
			)
		WHEN ols.Code in ('SERVICE', 'TOPIC') THEN 
			(SELECT
				ISNULL(STUFF(
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,''),
					1, 2, ''
					),
					ISNULL(STUFF(
							COALESCE(', ' + CASE WHEN btd.ORG_LEVEL_1=abtd.ORG_LEVEL_1 THEN NULL ELSE btd.ORG_LEVEL_1 END,'')
							+ COALESCE(', ' + CASE WHEN btd.ORG_LEVEL_1=abtd.ORG_LEVEL_1 AND btd.ORG_LEVEL_2=abtd.ORG_LEVEL_2 THEN NULL ELSE btd.ORG_LEVEL_2 END,'')
							+ COALESCE(', ' + CASE WHEN btd.ORG_LEVEL_1=abtd.ORG_LEVEL_1 AND btd.ORG_LEVEL_2=abtd.ORG_LEVEL_2 AND btd.ORG_LEVEL_3=abtd.ORG_LEVEL_3 THEN NULL ELSE btd.ORG_LEVEL_3 END,'')
							+ COALESCE(', ' + CASE WHEN btd.ORG_LEVEL_1=abtd.ORG_LEVEL_1 AND btd.ORG_LEVEL_2=abtd.ORG_LEVEL_2 AND btd.ORG_LEVEL_3=abtd.ORG_LEVEL_3 AND btd.ORG_LEVEL_4=abtd.ORG_LEVEL_4 THEN NULL ELSE btd.ORG_LEVEL_4 END,'')
							+ COALESCE(', ' + btd.ORG_LEVEL_5,''),
							1, 2, ''
						),
						ISNULL(btd.ORG_LEVEL_1,'') + ISNULL(', ' + btd.ORG_LEVEL_2,'') + ISNULL(', ' + btd.ORG_LEVEL_3,'') + ISNULL(', ' + btd.ORG_LEVEL_4,'') + ISNULL(', ' + btd.ORG_LEVEL_5,'')
					)
				)
			FROM (VALUES (ISNULL(bt.ORG_NUM, bt.NUM), btd.LangID)) AS sbt(ORG_NUM, LangID)
			LEFT JOIN GBL_BaseTable_Description abtd
				ON abtd.NUM = sbt.ORG_NUM AND abtd.LangID = sbt.LangID
			)
		END AS "@value",
		'Primary' AS "@purpose"
		FOR XML PATH('item'), TYPE),
		(SELECT
				btd.CMP_AltOrg AS "@value",
				'Alternate' AS "@purpose"
			WHERE btd.CMP_AltOrg IS NOT NULL
			FOR XML PATH ('item'), TYPE)
	   FOR XML PATH('names'), TYPE),


		(SELECT
				REPLACE(tax.LinkedCode, ' ~ ', ' * ') AS item
			FROM fn_CIC_NUMToTaxCodes_rst(bt.NUM) AS tax
			WHERE ols.Code IN ('SERVICE', 'TOPIC')
		FOR XML PATH(''), TYPE) AS taxonomy,



		(SELECT 
			(SELECT
				rbtols.EXTERNAL_ID AS "@id",
				rbtols.NUM AS "@uniquePriorID",
				'Agency' AS "@type"
			FROM dbo.GBL_BT_OLS rbtols
				INNER JOIN dbo.GBL_OrgLocationService rols
					ON rbtols.OLS_ID=rols.OLS_ID
			WHERE ols.Code <> 'Agency' AND rbtols.NUM=ISNULL(bt.ORG_NUM, bt.NUM) AND rols.Code = 'AGENCY'
			FOR XML PATH('item'), TYPE
			),
			(SELECT
				rbtols.EXTERNAL_ID AS "@id",
				rbtols.NUM AS "@uniquePriorID",
				'Site' AS "@type",
			(SELECT TOP(1) ibtd.LOCATION_NAME
				FROM dbo.GBL_BaseTable_Description ibtd WHERE ibtd.NUM=rbtols.NUM ORDER BY CASE WHEN ibtd.LangID=btd.LangID THEN 0 ELSE 1 END, ibtd.LangID
			) + STUFF(
				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,''),
				1, 2, ' - '
			) AS "@name"
			FROM dbo.GBL_BT_OLS rbtols
				INNER JOIN dbo.GBL_OrgLocationService rols
					ON rbtols.OLS_ID=rols.OLS_ID
			WHERE ols.Code in ('SERVICE', 'TOPIC') AND rols.Code='SITE' AND (rbtols.NUM=bt.NUM OR EXISTS(SELECT * FROM dbo.GBL_BT_LOCATION_SERVICE ls WHERE ls.LOCATION_NUM=rbtols.NUM AND ls.SERVICE_NUM=bt.NUM))
			FOR XML PATH ('item'), TYPE
			)
		 FOR XML PATH('related'), TYPE),
		 (SELECT
			(SELECT
				CASE WHEN EXISTS(SELECT *
					FROM dbo.GBL_PrivacyProfile_Fld pvf
					INNER JOIN dbo.GBL_FieldOption fo
						ON pvf.FieldID=fo.FieldID AND fo.FieldName='SITE_ADDRESS'
					WHERE pvf.ProfileID=bt.PRIVACY_PROFILE)
					THEN 1 ELSE 0 END AS "@isConfidential",
				(SELECT
				'physicalLocation' AS "@type",
				'Physical' AS "@purpose",
				CASE WHEN bt.GEOCODE_TYPE = 0 THEN NULL ELSE CAST(bt.LATITUDE AS VARCHAR(30)) END AS "@latitude",
				CASE WHEN bt.GEOCODE_TYPE = 0 THEN NULL ELSE CAST(bt.LONGITUDE AS VARCHAR(30)) END AS "@longitude",
				CASE WHEN bt.GEOCODE_TYPE = 1 THEN 'AddressGeocode' WHEN bt.GEOCODE_TYPE = 2 THEN 'GeneralArea' WHEN bt.GEOCODE_TYPE = 3 THEN 'Precise' WHEN bt.GEOCODE_TYPE = 0 THEN NULL ELSE 'Unknown' END AS "@precision",
				-- NOTE: not translated
				CASE WHEN bt.GEOCODE_TYPE = 0 THEN NULL ELSE cioc_shared.dbo.fn_SHR_GBL_DisplayGeoCodeType(bt.GEOCODE_TYPE) END "@source",
				--btd.SITE_BUILDING AS "@careOf",
				dbo.fn_GBL_FullAddress(NULL,NULL,btd.SITE_LINE_1,btd.SITE_LINE_2,btd.SITE_BUILDING,btd.SITE_STREET_NUMBER,btd.SITE_STREET,btd.SITE_STREET_TYPE,btd.SITE_STREET_TYPE_AFTER,btd.SITE_STREET_DIR,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,btd.LangID,0) AS "@line1",
				btd.SITE_SUFFIX AS "@line2",
				COALESCE(
					(SELECT EXPORT_CITY FROM @SiteCityTable WHERE SITE_CITY=btd.SITE_CITY),
					btd.SITE_CITY,
					(SELECT excm.AreaName
						FROM dbo.GBL_Community_External_Map cmap
						INNER JOIN dbo.GBL_Community_External_Community excm
							ON excm.EXT_ID = cmap.MapOneEXTID AND excm.SystemCode='ICAROLSTD' --'ONTARIO211'
						WHERE cmap.CM_ID=bt.LOCATED_IN_CM),
					btd.MAIL_CITY,
					cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown')
					) AS "@city",
				ISNULL(btd.SITE_PROVINCE,(SELECT mem.DefaultProvince FROM STP_Member mem WHERE MemberID=bt.MemberID)) AS "@stateProvince",
				bt.SITE_POSTAL_CODE AS "@zipPostalCode",
				ISNULL(btd.SITE_COUNTRY,ISNULL((SELECT mem.DefaultCountry FROM STP_Member mem WHERE MemberID=bt.MemberID),'Canada')) AS "@country"
			FOR XML PATH('contact'), TYPE)
			WHERE (btd.CMP_SiteAddress IS NOT NULL OR bt.LOCATED_IN_CM IS NOT NULL AND ols.Code NOT IN ('SERVICE', 'TOPIC'))
		FOR XML PATH('item'),TYPE),
		(SELECT
				CASE WHEN EXISTS(SELECT *
					FROM dbo.GBL_PrivacyProfile_Fld pvf
					INNER JOIN dbo.GBL_FieldOption fo
						ON pvf.FieldID=fo.FieldID AND fo.FieldName='MAIL_ADDRESS'
					WHERE pvf.ProfileID=bt.PRIVACY_PROFILE)
					THEN 1 ELSE 0 END AS "@isConfidential",
			(SELECT

				'postalAddress' AS "@type",
				'Mailing' AS "@purpose",
				REPLACE(dbo.fn_GBL_FullAddress(NULL,NULL,NULL,NULL,btd.MAIL_BUILDING,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,btd.MAIL_CARE_OF,NULL,NULL,NULL,NULL,btd.LangID,0),@nLine,', ') AS "@careOf",
				REPLACE(dbo.fn_GBL_FullAddress(NULL,NULL,btd.MAIL_LINE_1,btd.MAIL_LINE_2,NULL,btd.MAIL_STREET_NUMBER,btd.MAIL_STREET,btd.MAIL_STREET_TYPE,btd.MAIL_STREET_TYPE_AFTER,btd.MAIL_STREET_DIR,NULL,NULL,NULL,NULL,NULL,NULL,btd.MAIL_BOX_TYPE,btd.MAIL_PO_BOX,NULL,NULL,btd.LangID,0),@nLine,', ') AS "@line1",
				btd.MAIL_SUFFIX AS "@line2",
				COALESCE(btd.MAIL_CITY,btd.SITE_CITY,cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Unknown',btd.LangID)) AS "@city",
				ISNULL(btd.MAIL_PROVINCE,(SELECT mem.DefaultProvince FROM STP_Member mem WHERE MemberID=bt.MemberID)) AS "@stateProvince",
				bt.MAIL_POSTAL_CODE AS "@zipPostalCode",
				ISNULL(btd.MAIL_COUNTRY,ISNULL((SELECT mem.DefaultCountry FROM STP_Member mem WHERE MemberID=bt.MemberID),'Canada')) AS "@country"
			FOR XML PATH('contact'), TYPE)
		WHERE btd.CMP_MailAddress IS NOT NULL AND ols.Code NOT IN ('SERVICE', 'TOPIC')
		FOR XML PATH('item'),TYPE),

			(SELECT 
				phone."Confidential" AS "@isConfidential", 
				(
				SELECT 
					'phoneNumber' AS "@type",
					phone."Description" AS "@description",
					phone."Label" AS "@label",
					phone.Purpose AS "@purpose",
					phone.PhoneNumber AS "@number",
					phone.TTY AS "@isTTY",
					phone.Fax AS "@isFax",
					phone."TollFree" AS "@isTollFree"	
				FOR XML PATH('contact'), TYPE
				)
			FROM (
			SELECT 0 AS "TollFree",
					0 AS "Confidential",
					0 AS TTY,
					0 AS Fax,
					btd.OFFICE_PHONE AS PhoneNumber,
					'Phone1' AS Purpose,
					CASE WHEN btd.LangID=0 THEN 'Office' ELSE 'Bureau' END AS [Label],
					NULL AS [Description]
				WHERE btd.OFFICE_PHONE IS NOT NULL
			UNION SELECT 0 AS "TollFree",
					0 AS "Confidential",
					0 AS TTY,
					0 AS Fax,
					cbtd.AFTER_HRS_PHONE AS PhoneNumber,
					'After-Hours' AS Purpose, 
					CASE WHEN btd.LangID=0 THEN 'After Hours' ELSE 'après fermeture' END AS [Label],
					NULL AS [Description]
				WHERE cbtd.AFTER_HRS_PHONE IS NOT NULL
			UNION SELECT 0 AS "TollFree",
					0 AS "Confidential",
					0 AS TTY,
					0 AS Fax,
					cbtd.CRISIS_PHONE AS PhoneNumber,
					'Phone2' AS Purpose,
					CASE WHEN btd.LangID=0 THEN 'Crisis' ELSE 'Crise' END AS [Label], 
					NULL AS [Description]
				WHERE cbtd.CRISIS_PHONE IS NOT NULL
			UNION SELECT 0 AS "TollFree",
					0 AS "Confidential",
					0 AS TTY,
					1 AS Fax,
					btd.FAX AS PhoneNumber,
					'Fax' AS Purpose,
					'Fax' AS [Label],
					NULL AS [Description]
				WHERE btd.FAX IS NOT NULL
			UNION SELECT 0 AS "TollFree",
					0 AS "Confidential",
					1 AS TTY,
					0 AS Fax,
					cbtd.TDD_PHONE AS PhoneNumber,
					'TTY' AS Purpose,
					'TTY' AS [Label],
					NULL AS [Description]
				WHERE cbtd.TDD_PHONE IS NOT NULL
			UNION SELECT
					1 AS "TollFree",
					0 AS "Confidential",
					0 AS TTY,
					0 AS Fax,
					btd.TOLL_FREE_PHONE AS PhoneNumber,
					'Toll-Free' AS Purpose,
					CASE WHEN btd.LangID=0 THEN 'Toll-Free' ELSE 'sans frais' END AS [Label],
					NULL AS [Description]
				WHERE btd.TOLL_FREE_PHONE IS NOT NULL
			) phone
			WHERE ols.CODE != 'SITE'
			FOR XML PATH('item'), TYPE),


		(SELECT
				CASE WHEN EXISTS(SELECT *
					FROM dbo.GBL_PrivacyProfile_Fld pvf
					INNER JOIN dbo.GBL_FieldOption fo
						ON pvf.FieldID=fo.FieldID AND fo.FieldName=c.GblContactType
					WHERE pvf.ProfileID=bt.PRIVACY_PROFILE)
					THEN 1 ELSE 0 END AS "@isConfidential",		
			(SELECT
				'person' AS "@type",
				CASE WHEN ols.Code = 'AGENCY' THEN
					CASE WHEN c.GblContactType = 'EXEC_1' THEN 'Senior Worker'
					ELSE 'Main Contact' END 
				ELSE
					CASE WHEN c.GblContactType = 'CONTACT_1' THEN 'Main Contact'
					ELSE 'Senior Worker' END
				END	AS "@label",
				c.ORG AS "@companyName",
	

			(SELECT c.TITLE AS item WHERE c.TITLE IS NOT NULL FOR XML PATH('titles'), TYPE),
		

			(SELECT
				c.CMP_Name AS "@displayName"
			WHERE c.CMP_Name IS NOT NULL
			FOR XML PATH('name'), TYPE),

			(SELECT 
		

				(SELECT 'emailAddress' as "@type", LTRIM(ItemID) AS "@address" FROM dbo.fn_GBL_ParseVarCharIDList(c.EMAIL,',') FOR XML PATH('item'), TYPE),


			(SELECT 
					'phoneNumber' AS "@type",
                    c.CMP_PhoneFull "@number"
				WHERE c.CMP_PhoneFull IS NOT NULL
				FOR XML PATH('item'), TYPE)
				FOR XML PATH('contactMethods'), TYPE)
			FOR XML PATH('contact'), TYPE)		
		FROM dbo.GBL_Contact c
		WHERE c.GblNUM=bt.NUM AND c.LangID=btd.LangID
			AND c.CMP_Name IS NOT NULL
			AND ((ols.Code = 'AGENCY' AND c.GblContactType IN ('EXEC_1','EXEC_2')) OR (ols.Code IN ('SERVICE', 'TOPIC') AND c.GblContactType IN ('CONTACT_1', 'CONTACT_2')))
		ORDER BY c.GblContactType DESC
		FOR XML PATH('item'), TYPE),
			(SELECT 0 AS "@isConfidential",
				(SELECT
					'website' AS "@type",
					ISNULL(btd.WWW_ADDRESS_PROTOCOL, 'http://') + btd.WWW_ADDRESS AS "@url" 
				FOR XML PATH('contact'), TYPE)
			WHERE btd.WWW_ADDRESS IS NOT NULL
			FOR XML PATH('item'), TYPE),
			(SELECT 0 AS "@isConfidential",
				(SELECT
					'emailAddress' AS "@type",
					'Main' AS "@label",
					btd.E_MAIL AS "@address" 
				FOR XML PATH('contact'), TYPE)
			WHERE btd.E_MAIL IS NOT NULL
			FOR XML PATH('item'), TYPE)

	FOR XML PATH('contactDetails'), TYPE),
	(SELECT 
				(SELECT
					CAST(N'<item type="postalAddress" purpose="CoverageArea" ' +  excm.attributename + N'="' + (SELECT excm.AreaName AS [text()] FOR XML PATH('')) + N'" />' AS XML) AS [node()]

				FROM (SELECT DISTINCT excm.AreaName, cmat.[Order], t.attributeName
					FROM dbo.GBL_Community_External_Community excm
					INNER JOIN (
						VALUES 
							('CensusTrack', 'region'),
							('City', 'city') ,
							('Community', 'district'),
							('Country', 'country'),
							('County', 'county'),
							('State', 'stateProvince'),
							('ZipCode', 'zipPostalCode')

					) AS t (AIRSExportType, attributeName)
						ON excm.AIRSExportType = t.AIRSExportType
					LEFT JOIN dbo.GBL_Community_AIRSType cmat
						ON cmat.AIRSExportType = excm.AIRSExportType
					WHERE  excm.EXT_ID=map.EXT_ID
				) AS excm
				ORDER BY excm.[Order]
			FOR XML PATH(''), TYPE
			)
			FROM dbo.CIC_BT_CM cpr
			INNER JOIN dbo.GBL_Community cm
				ON cm.CM_ID=cpr.CM_ID
			INNER JOIN dbo.GBL_Community_External_Map_All map
				ON cm.CM_ID=map.CM_ID AND map.SystemCode = 'ICAROLSTD' --'ONTARIO211'
			WHERE cbtd.CMP_AreasServed IS NOT NULL AND cpr.NUM=bt.NUM AND ols.Code IN ('SERVICE', 'TOPIC')
			FOR XML PATH(''), TYPE
		) AS coverage,

		(SELECT 
					CASE WHEN cbtd.HOURS IS NULL THEN CASE WHEN cbtd.DATES IS NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Meetings',cbtd.LangID) + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',cbtd.LangID) + cbtd.MEETINGS ELSE + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Dates',cbtd.LangID) +  + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',cbtd.LangID) + cbtd.DATES + ISNULL(@nLine + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Meetings',cbtd.LangID) + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',cbtd.LangID) + cbtd.MEETINGS,'') END
					ELSE cbtd.HOURS + ISNULL(@nLine + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Dates',cbtd.LangID) + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',cbtd.LangID) + cbtd.DATES,'') + ISNULL(@nLine + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Meetings',cbtd.LangID) + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',cbtd.LangID) + cbtd.MEETINGS,'')
					END AS "@note"
			WHERE (cbtd.HOURS IS NOT NULL OR cbtd.DATES IS NOT NULL) AND ols.Code != 'SITE'
			FOR XML PATH('hours'), TYPE
		),
		(SELECT
			-- TODO: Import and AIRS export don't agree, which is right? This is AIRS Export
			cbtd.COMMENTS AS "@Internal",
			cbtd.CMP_InternalMemo AS "@Editors"
		FOR XML PATH('notes'), TYPE),
		(SELECT

			STUFF(
				(SELECT ' ; ' + 
					CASE WHEN RouteName IS NULL 
						THEN RouteNumber
						ELSE CASE
							WHEN RouteNumber IS NULL THEN ''
							ELSE RouteNumber + ' - '
						END + RouteName
					END
				FROM dbo.fn_CIC_NUMToBusRoutes_rst(bt.num, btd.LangID) br
				FOR XML PATH(''),TYPE).value('.', 'nvarchar(max)')
				, 1, 3, ''
			) AS "@Bus",
			dbo.fn_GBL_NUMToAccessibility(btd.NUM,btd.ACCESSIBILITY_NOTES,btd.LangID) AS "@Disabled"
			WHERE ols.Code IN ('AGENCY', 'SITE')
		FOR XML PATH('accessibility'), TYPE),
		(SELECT 
			(SELECT
				'Minimum Age' AS "@label",
				(SELECT 
					CAST(CAST(cbt.MIN_AGE AS float) AS nvarchar) AS "item"
				FOR XML PATH('selectedValues'), TYPE)
			WHERE cbt.MIN_AGE IS NOT NULL AND btd.LangID=0 -- Checklist custom values only in english
				AND ols.Code IN ('SERVICE', 'TOPIC')
			FOR XML PATH('item'), TYPE),
			(SELECT
				'Maximum Age' AS "@label",
				(SELECT 
					CAST(CAST(cbt.MAX_AGE AS float) AS nvarchar) AS "item"
				FOR XML PATH('selectedValues'), TYPE)
			WHERE cbt.MAX_AGE IS NOT NULL AND btd.LangID=0 -- Checklist custom values only in english
				AND ols.Code IN ('SERVICE', 'TOPIC')
			FOR XML PATH('item'), TYPE),
			(SELECT
				'Record Owner (controlled)' AS "@label",
				(SELECT
				bt.RECORD_OWNER AS "item"
				FOR XML PATH('selectedValues'), TYPE)
				WHERE bt.RECORD_OWNER IS NOT NULL AND btd.LangID=0
			FOR XML PATH('item'), TYPE),
			(SELECT
				'Public Comments' AS "@label",
				cbtd.PUBLIC_COMMENTS AS "@valueText"
				WHERE cbtd.PUBLIC_COMMENTS IS NOT NULL AND ols.Code IN ('SERVICE', 'TOPIC')
			FOR XML PATH('item'), TYPE),
			(SELECT
				'Legal Name' AS "@label",
				btd.LEGAL_ORG AS "@valueText"
				WHERE btd.LEGAL_ORG IS NOT NULL AND ols.Code = 'AGENCY'
			FOR XML PATH('item'), TYPE),
			(SELECT
				'Neighbourhood' AS "@label",
				(SELECT  
					'TNB' + RIGHT('000' + sp.RightItem, 3) + ' ' + sp.LeftItem AS "item"
					FROM dbo.CIC_BT_EXD exd
					INNER JOIN dbo.CIC_ExtraDropDown dd
						ON exd.EXD_ID=dd.EXD_ID
					INNER JOIN dbo.CIC_ExtraDropDown_Name ddn
						ON ddn.EXD_ID=dd.EXD_ID AND ddn.LangID=0  -- Checklist custom values only in english
				    CROSS APPLY dbo.fn_GBL_ParseVarCharIDPairList(ddn.Name, ';', ', ') AS sp
					WHERE exd.FieldName_Cache = 'EXTRA_DROPDOWN_NEIGHBOURHOOD' AND exd.NUM=bt.NUM 
				FOR XML PATH('selectedValues'), TYPE)
			WHERE EXISTS(SELECT * FROM dbo.CIC_BT_EXD exd WHERE exd.FieldName_Cache='EXTRA_DROPDOWN_NEIGHBOURHOOD' AND exd.NUM=bt.NUM) AND btd.LangID=0 -- Checklist custom values only in english
				AND ols.Code = 'SITE'
			FOR XML PATH('item'), TYPE),		
			(SELECT
				CASE WHEN sm.DefaultName = 'X (Twitter)' THEN 'Twitter' ELSE sm.DefaultName END AS "@label",
				pr.Protocol + pr.URL AS "@valueText"
			FROM dbo.GBL_BT_SM pr 
				INNER JOIN dbo.GBL_SocialMedia sm 
					ON sm.SM_ID = pr.SM_ID
			WHERE pr.NUM=bt.NUM AND pr.LangID=btd.LangID AND sm.DefaultName IN ('X (Twitter)', 'Instagram', 'YouTube', 'LinkedIn', 'Facebook') AND ols.Code != 'SITE'
			FOR XML PATH('item'), TYPE)
		FOR XML PATH('customFields'), TYPE)
 	   

	   -- TODO - handle deletion
       --bt.DELETION_DATE - tombstone for delete,

	   -- EXTRA_ICAROLEXCLUDEFROMWEBSITE, EXTRA_DATE_ICAROLMADEINACTIVEON, EXTRA_DROPDOWN_ICAROLAGENCYSTATUS 

	   -- bt.RECORD_OWNER,

	FROM dbo.GBL_BaseTable_Description btd
	LEFT JOIN CIC_BaseTable_Description cbtd
	ON bt.NUM=cbtd.NUM AND cbtd.LangID=btd.LangID
	WHERE bt.NUM=btd.NUM AND btd.LangID IN (0, 2) AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
	ORDER BY btd.LangID
	FOR XML PATH('item'), ROOT('root'), TYPE
) AS datachange
FROM dbo.GBL_BT_OLS btols
    INNER JOIN dbo.GBL_OrgLocationService ols
        ON ols.OLS_ID = btols.OLS_ID
INNER JOIN dbo.GBL_BaseTable bt
	ON bt.NUM=btols.NUM
LEFT JOIN CIC_BaseTable cbt
	ON bt.NUM = cbt.NUM


WHERE btols.QUEUE_FOR_EXPORT = 1 AND bt.SOURCE_FROM_ICAROL = 0 AND EXISTS(SELECT * FROM dbo.GBL_BaseTable_Description btd WHERE bt.NUM=btd.NUM AND btd.LangID IN (0,2))
ORDER BY CASE
             WHEN ols.Code = 'AGENCY' THEN
                 1
             WHEN ols.Code = 'SITE' THEN
                 2
             WHEN ols.Code = 'SERVICE' THEN
                 3
			WHEN ols.Code = 'TOPIC' THEN
				4
         END,
         CASE
             WHEN btols.EXTERNAL_ID IS NULL THEN
                 0
             ELSE
                 1
         END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_iCarolExport_l] TO [cioc_login_role]
GO
