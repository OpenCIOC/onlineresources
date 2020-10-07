SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CIC_iCarolImport_CreateSharing]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		INT
SET @Error = 0

DECLARE @updated AS TABLE
(
	ResourceAgencyNum NVARCHAR(50) COLLATE Latin1_General_100_CI_AI  NOT NULL,
	LangID TINYINT NOT NULL,
	TaxonomyLevelName NVARCHAR(MAX) COLLATE Latin1_General_100_CI_AI NULL,
	PRIMARY KEY (ResourceAgencyNum, LangID)
)


-- Hypothesis: There should be a transaction around this and the SQL below to prevent updating the DATE_IMPORTED if there is a failure in the export generation SQL
UPDATE i SET i.DATE_IMPORTED=GETDATE() 
OUTPUT deleted.ResourceAgencyNum, deleted.LangID, deleted.TaxonomyLevelName INTO @updated
FROM dbo.CIC_iCarolImportRollup i
LEFT JOIN dbo.GBL_BaseTable ib 
	ON ib.EXTERNAL_ID=i.ResourceAgencyNum AND ib.SOURCE_DB_CODE = 'ICAROL'
WHERE (i.DATE_IMPORTED IS NULL OR i.DATE_IMPORTED < i.DATE_MODIFIED OR i.DATE_IMPORTED < i.DELETION_DATE) AND ((ib.EXTERNAL_ID IS NOT NULL AND ib.MemberID=@MemberID) OR EXISTS(SELECT * FROM dbo.GBL_Agency a WHERE a.MemberID=@MemberID AND a.AgencyCode = i.RECORD_OWNER AND a.AutoImportFromICarol=1))


SELECT CAST((SELECT (
	-- Agency
	SELECT 
	 a.ResourceAgencyNum AS [@NUM], COALESCE(bt.RECORD_OWNER, a.RECORD_OWNER) AS [@RECORD_OWNER],
		1 AS [@HAS_ENGLISH], CASE WHEN f.ResourceAgencyNum IS NOT NULL THEN 1 ELSE NULL END AS [@HAS_FRENCH],
		(SELECT a.DisabilitiesAccess AS [@N], f.DisabilitiesAccess AS [@NF] FOR XML PATH('ACCESSIBILITY'), TYPE),
		(SELECT a.LicenseAccreditation AS [@V], f.LicenseAccreditation AS [@VF] FOR XML PATH('ACCREDITED'), TYPE),
		(SELECT
			 CASE WHEN a.PhoneNumberAfterHours IS NOT NULL AND a.PhoneNumberAfterHoursDescription  IS NOT NULL THEN a.PhoneNumberAfterHoursDescription + ': ' ELSE '' END + a.PhoneNumberAfterHours AS [@V],
			 CASE WHEN a.PhoneNumberAfterHours IS NOT NULL AND f.PhoneNumberAfterHoursDescription  IS NOT NULL THEN f.PhoneNumberAfterHoursDescription + ': ' ELSE '' END + f.PhoneNumberAfterHours AS [@VF]
		  FOR XML PATH('AFTER_HRS_PHONE'), TYPE), 
		(SELECT 
				(SELECT
					'E' AS [@LANG],
					 l.ItemID AS [@V]
				 FROM  dbo.fn_GBL_ParseVarCharIDList(a.AlternateName, ';') l
				 FOR XML PATH('NM'), TYPE
				),
				(SELECT
					'F' AS [@LANG],
					 l.ItemID AS [@V]
				 FROM  dbo.fn_GBL_ParseVarCharIDList(f.AlternateName, ';') l
				 FOR XML PATH('NM'), TYPE
				)
			FOR XML PATH('ALT_ORG'), TYPE),
			
		(SELECT a.ApplicationProcess AS [@V], f.ApplicationProcess AS [@VF] FOR XML PATH('APPLICATION'), TYPE),
		(SELECT -- NOTE: This needs some work
			(SELECT COALESCE(cmn.Name,i.AreaName) AS [@V], i.Prov AS [@PRV] FROM (
				SELECT DISTINCT FIRST_VALUE(ItemID) OVER (PARTITION BY t.TotalItemID ORDER BY t.cm_level DESC) AS AreaName, FIRST_VALUE(ItemID) OVER (PARTITION BY t.TotalItemID ORDER BY t.cm_level) AS Prov,
				 REPLACE(REPLACE(REPLACE(REPLACE(FIRST_VALUE(cm_level) OVER (PARTITION BY t.TotalItemID ORDER BY cm_level DESC), 1, 'State'), 2, 'County'), 3, 'City'), '4', 'Community') AS cm_level
				FROM (
				SELECT areas.ItemID AS TotalItemID, ROW_NUMBER() OVER (PARTITION BY areas.ItemID ORDER BY (SELECT 1)) AS cm_level, levels.* 
				FROM dbo.fn_GBL_ParseVarCharIDList(a.Coverage, ';') AS areas
				CROSS APPLY dbo.fn_GBL_ParseVarCharIDList(areas.ItemID, '-') AS levels
				) AS t
			) AS i
			LEFT JOIN dbo.GBL_Community_External_Community c
				ON i.cm_level=c.AIRSExportType COLLATE Latin1_General_100_CI_AI AND i.AreaName=c.AreaName COLLATE Latin1_General_100_CI_AI AND c.SystemCode='ONTARIO211'
			LEFT JOIN dbo.GBL_Community_External_Map_All m 
					ON m.EXT_ID = c.EXT_ID
			LEFT JOIN dbo.GBL_Community_Name cmn
				ON cmn.CM_ID = m.CM_ID AND cmn.LangID=(SELECT TOP(1) LangID FROM dbo.GBL_Community_Name ic WHERE cmn.CM_ID = ic.CM_ID ORDER BY CASE WHEN ic.LangID=@@LANGID THEN 0 ELSE 1 END, ic.LangID)
			FOR XML PATH('CM'), TYPE)
		FOR XML PATH ('AREAS_SERVED'), TYPE),
		(SELECT a.BusServiceAccess AS [@N], f.BusServiceAccess AS [@NF] FOR XML PATH('BUS_ROUTES'),TYPE),
		(SELECT a.InternalNotesForEditorsAndViewers AS [@V], f.InternalNotesForEditorsAndViewers AS [@VF] FOR XML PATH('COMMENTS'), TYPE),
		(SELECT 
			(SELECT 'E' AS [@LANG], a.MainContactName AS [@NMLAST], a.MainContactTitle AS [@TTL], a.MainContactPhoneNumber AS [@PH1N], a.MainContactEmailAddress AS [@EML]
			-- NOTE a.MainContactType didn't have any data in it so it was not mapped
			WHERE a.MainContactName IS NOT NULL OR a.MainContactTitle IS NOT NULL OR a.MainContactPhoneNumber IS NOT NULL OR a.MainContactEmailAddress IS NOT NULL
			FOR XML PATH('CONTACT'), TYPE),
			(SELECT 'F' AS [@LANG], f.MainContactName AS [@NMLAST], f.MainContactTitle AS [@TTL], f.MainContactPhoneNumber AS [@PH1N], f.MainContactEmailAddress AS [@EML]
			-- NOTE a.MainContactType didn't have any data in it so it was not mapped
			WHERE f.MainContactName IS NOT NULL OR f.MainContactTitle IS NOT NULL OR f.MainContactPhoneNumber IS NOT NULL OR f.MainContactEmailAddress IS NOT NULL
			FOR XML PATH('CONTACT'), TYPE)
		FOR XML PATH('CONTACT_1') ,TYPE),
		(SELECT
			 CASE WHEN a.PhoneNumberHotline IS NOT NULL AND a.PhoneNumberHotlineDescription  IS NOT NULL THEN a.PhoneNumberHotlineDescription + ': ' ELSE '' END + a.PhoneNumberHotline AS [@V],
			 CASE WHEN f.PhoneNumberHotline IS NOT NULL AND f.PhoneNumberHotlineDescription  IS NOT NULL THEN f.PhoneNumberHotlineDescription + ': ' ELSE '' END + f.PhoneNumberHotline AS [@VF]
		  FOR XML PATH('CRISIS_PHONE'), TYPE), 
		(SELECT a.DELETION_DATE AS [@V], f.DELETION_DATE AS [@VF] FOR XML PATH('DELETION_DATE'), TYPE),
		(SELECT a.DESCRIPTION AS [@V], f.DESCRIPTION AS [@VF] FOR XML PATH('DESCRIPTION'), TYPE),
		(SELECT a.DocumentsRequired AS [@V], f.DocumentsRequired AS [@VF] FOR XML PATH('DOCUMENTS_REQUIRED'), TYPE),
		(SELECT a.EmailAddressMain AS [@V], f.EmailAddressMain AS [@VF] FOR XML PATH('E_MAIL'), TYPE),
		(SELECT a.Eligibility AS [@N], f.Eligibility AS [@NF], a.[Custom_Minimum Age] AS [@MIN_AGE], a.[Custom_Maximum Age] AS [@MAX_AGE] FOR XML PATH('ELIGIBILITY'), TYPE),
		(SELECT a.YearIncorporated AS [@V], f.YearIncorporated AS [@VF] FOR XML PATH('ESTABLISHED'), TYPE),
		(SELECT
			(SELECT 'E' AS [@LANG], a.SeniorWorkerName AS [@NMLAST], a.SeniorWorkerTitle AS [@TTL], a.SeniorWorkerPhoneNumber AS [@PH1N], a.SeniorWorkerEmailAddress AS [@EML]
				WHERE a.SeniorWorkerName IS NOT NULL OR a.SeniorWorkerTitle IS NOT NULL OR a.SeniorWorkerPhoneNumber IS NOT NULL OR a.SeniorWorkerEmailAddress IS NOT NULL
			 FOR XML PATH('CONTACT'), TYPE),
			(SELECT 'F' AS [@LANG], f.SeniorWorkerName AS [@NMLAST], f.SeniorWorkerTitle AS [@TTL], f.SeniorWorkerPhoneNumber AS [@PH1N], f.SeniorWorkerEmailAddress AS [@EML]
				WHERE f.SeniorWorkerName IS NOT NULL OR f.SeniorWorkerTitle IS NOT NULL OR f.SeniorWorkerPhoneNumber IS NOT NULL OR f.SeniorWorkerEmailAddress IS NOT NULL
			 FOR XML PATH('CONTACT'), TYPE)
		 FOR XML PATH('EXEC_1'),TYPE),
		(SELECT a.PhoneFax AS [@V], f.PhoneFax AS [@VF] FOR XML PATH('FAX'), TYPE),
		(SELECT a.FeeStructureSource AS [@N], f.FeeStructureSource AS [@NF] FOR XML PATH('FEES'), TYPE),
		(SELECT
		-- I think this is now handled in the rollup so we can go back to checking for NULL
			 CASE WHEN a.Latitude IS NOT NULL AND a.Longitude IS NOT NULL THEN 3 ELSE 0 END AS [@TYPE],
			 a.Latitude AS [@LAT],
			 a.Longitude AS [@LONG]
		  FOR XML PATH('GEOCODE'), TYPE),
		(SELECT COALESCE(a.HoursOfOperation, a.Hours) AS [@V], COALESCE(f.HoursOfOperation, f.Hours) AS [@VF] FOR XML PATH('HOURS'), TYPE),
		(SELECT
			(SELECT
				a.InternalMemoGUID AS [@GID],
				REPLACE(COALESCE(a.UpdatedOn, cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(GETDATE())), ' ', 'T') AS [@CREATED],
				'E' AS [@LANG],
				REPLACE(COALESCE(a.UpdatedOn, cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(GETDATE())), ' ', 'T') AS [@MOD],
				a.InternalNotes AS [@V]
				WHERE a.InternalNotes IS NOT NULL
			 FOR XML PATH('N'),TYPE ),
			(SELECT
				f.InternalMemoGUID AS [@GID],
				REPLACE(COALESCE(f.UpdatedOn, cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(GETDATE())), ' ', 'T') AS [@CREATED],
				'F' AS [@LANG],
				REPLACE(COALESCE(f.UpdatedOn, cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(GETDATE())), ' ', 'T') AS [@MOD],
				f.InternalNotes AS [@V]
				WHERE f.InternalNotes IS NOT NULL
			 FOR XML PATH('N'),TYPE )
		 FOR XML PATH ('INTERNAL_MEMO'), TYPE),
		(SELECT COALESCE(a.LanguagesOffered, a.LanguagesOfferedList) AS [@N], COALESCE(f.LanguagesOffered, f.LanguagesOfferedList) AS [@NF] FOR XML PATH('LANGUAGES'), TYPE),
		(SELECT COALESCE(a.[Custom_Legal Name], a.[OfficialName]) AS [@V], COALESCE(f.[Custom_Legal Name], f.[OfficialName]) AS [@VF] FOR XML PATH('LEGAL_ORG'), TYPE),
		(SELECT a.LOCATION_DESCRIPTION AS [@V], f.LOCATION_DESCRIPTION AS [@VF] FOR XML PATH('LOCATION_DESCRIPTION'), TYPE),
		(SELECT a.LOCATION_NAME AS [@V], f.LOCATION_NAME AS [@VF] FOR XML PATH('LOCATION_NAME'), TYPE),
		(SELECT DISTINCT irr.ResourceAgencyNum AS [@V] FROM dbo.CIC_iCarolImportRollup irr WHERE a.TaxonomyLevelName = 'Site' AND irr.ConnectsToSiteNum=a.ResourceAgencyNum AND irr.TaxonomyLevelName='ProgramAtSite' AND irr.DELETION_DATE IS NULL FOR XML PATH('SERVICE_NUM'), ROOT('LOCATION_SERVICES'), TYPE),
		(SELECT 
			 a.MailingAddress1 AS [@LN1],
			 a.MailingAddress2 AS [@LN2],
			 a.MailingCity AS [@CTY],
			 a.MailingStateProvince AS [@PRV],
			 CASE WHEN a.MailingPostalCode LIKE '[a-zA-Z][0-9][a-zA-Z][0-9][a-zA-Z][0-9]' THEN LEFT(a.MailingPostalCode,3) + ' ' + RIGHT(a.MailingPostalCode, 3) ELSE a.MailingPostalCode END AS [@PC],
			 a.MailingCountry AS [@CTRY],

			 f.MailingAddress1 AS [@LN1F],
			 f.MailingAddress2 AS [@LN2F],
			 f.MailingCity AS [@CTYF],
			 f.MailingStateProvince AS [@PRVF],
			 -- NOTE: Postal Code is shared
			 -- f.MailingPostalCode AS [@PC],
			 f.MailingCountry AS [@CTRYF]
			FOR XML PATH('MAIL_ADDRESS'), TYPE
		),
		(SELECT CASE WHEN COALESCE(a.ExcludeFromWebsite, 'No') = 'Yes' THEN 1 ELSE 0 END AS [@V], CASE WHEN COALESCE(f.ExcludeFromWebsite, 'No') = 'Yes' THEN 1 ELSE 0 END AS [@VF] FOR XML PATH('NON_PUBLIC'), TYPE),
		(SELECT
			 (SELECT STUFF((SELECT '; ' + NumberValue FROM (

			SELECT CASE WHEN a.PhoneNumberBusinessLine  IS NOT NULL AND a.PhoneNumberBusinessLineDescription  IS NOT NULL THEN a.PhoneNumberBusinessLineDescription + ': ' ELSE '' END + a.PhoneNumberBusinessLine AS NumberValue
			UNION ALL SELECT 
				CASE WHEN PhoneNumber IS NOT NULL AND PhoneName IS NOT NULL THEN PhoneName + ': ' ELSE '' END + PhoneNumber AS NumberValue
				FROM (
					VALUES 
						(a.Phone1Number, a.Phone1Name),
						(a.Phone2Number, a.Phone2Name),
						(a.Phone3Number, a.Phone3Name),
						(a.Phone4Number, a.Phone4Name),
						(a.Phone5Number, a.Phone5Name),
						(a.PhoneNumberOutOfArea, a.PhoneNumberOutOfAreaDescription)
					) AS cte (PhoneNumber, PhoneName)
					WHERE cte.PhoneNumber IS NOT NULL
				) AS i FOR XML PATH(''),TYPE).value('.', 'nvarchar(max)'), 1, 2, '')
			
			 ) AS [@V],
			 (SELECT STUFF((SELECT '; ' + NumberValue FROM (

			SELECT CASE WHEN f.PhoneNumberBusinessLine  IS NOT NULL AND f.PhoneNumberBusinessLineDescription  IS NOT NULL THEN f.PhoneNumberBusinessLineDescription + ': ' ELSE '' END + f.PhoneNumberBusinessLine AS NumberValue
			UNION ALL SELECT 
				CASE WHEN PhoneNumber IS NOT NULL AND PhoneName IS NOT NULL THEN PhoneName + ': ' ELSE '' END + PhoneNumber AS NumberValue
				FROM (
					VALUES 
						(f.Phone1Number, f.Phone1Name),
						(f.Phone2Number, f.Phone2Name),
						(f.Phone3Number, f.Phone3Name),
						(f.Phone4Number, f.Phone4Name),
						(f.Phone5Number, f.Phone5Name),
						(f.PhoneNumberOutOfArea, f.PhoneNumberOutOfAreaDescription)
					) AS cte (PhoneNumber, PhoneName)
					WHERE cte.PhoneNumber IS NOT NULL
				) AS i FOR XML PATH(''),TYPE).value('.', 'nvarchar(max)') , 1, 2, '')
			
			 ) AS [@VF]
		  FOR XML PATH('OFFICE_PHONE'), TYPE),
		(SELECT a.ORG_DESCRIPTION AS [@V], f.ORG_DESCRIPTION AS [@VF] FOR XML PATH('ORG_DESCRIPTION'), TYPE),
		(SELECT a.ORG_LEVEL_1 AS [@V], f.ORG_LEVEL_1 AS [@VF] FOR XML PATH('ORG_LEVEL_1'), TYPE),
		(SELECT a.ORG_LOCATION_SERVICE AS [@V] FOR XML PATH('CD'), ROOT('ORG_LOCATION_SERVICE'), TYPE),
		(SELECT NULLIF(a.ParentAgencyNum, '0') AS [@V]  FOR XML PATH('ORG_NUM'),TYPE),
		(SELECT a.[Custom_Public Comments] AS [@V], f.[Custom_Public Comments] AS [@VF] FOR XML PATH('PUBLIC_COMMENTS'), TYPE),
		(SELECT a.SERVICE_NAME_LEVEL_1 AS [@V], f.SERVICE_NAME_LEVEL_1 AS [@VF] FOR XML PATH('SERVICE_NAME_LEVEL_1'), TYPE),
		(SELECT CASE WHEN a.SERVICE_NAME_LEVEL_2 <> a.SERVICE_NAME_LEVEL_1 THEN a.SERVICE_NAME_LEVEL_2 ELSE NULL END AS [@V], CASE WHEN f.SERVICE_NAME_LEVEL_2 <> f.SERVICE_NAME_LEVEL_1 THEN f.SERVICE_NAME_LEVEL_2 ELSE NULL END AS [@VF] FOR XML PATH('SERVICE_NAME_LEVEL_2'), TYPE),
		(SELECT 
			 a.PhysicalAddress1 AS [@LN1],
			 a.PhysicalAddress2 AS [@LN2],
			 a.PhysicalCity AS [@CTY],
			 a.PhysicalStateProvince AS [@PRV],
			 CASE WHEN a.PhysicalPostalCode LIKE '[a-zA-Z][0-9][a-zA-Z][0-9][a-zA-Z][0-9]' THEN LEFT(a.PhysicalPostalCode,3) + ' ' + RIGHT(a.PhysicalPostalCode, 3) ELSE a.PhysicalPostalCode END AS [@PC],
			 a.PhysicalCountry AS [@CTRY],

			 f.PhysicalAddress1 AS [@LN1F],
			 f.PhysicalAddress2 AS [@LN2F],
			 f.PhysicalCity AS [@CTYF],
			 f.PhysicalStateProvince AS [@PRVF],

			 -- Only one Postal Code Value Allowed, using English
			 -- f.PhysicalPostalCode AS [@PC],
			 f.PhysicalCountry AS [@CTRYF]
			FOR XML PATH('SITE_ADDRESS'), TYPE
		),
		(SELECT
			(SELECT 'Twitter' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(a.Custom_Twitter, 'https://', ''), 'http://', '') AS [@URL]
				WHERE a.Custom_Twitter IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Instagram' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(a.Custom_Instagram, 'https://', ''), 'http://', '') AS [@URL]
				WHERE a.Custom_Instagram IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'YouTube' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(a.Custom_YouTube, 'https://', ''), 'http://', '') AS [@URL]
				WHERE a.Custom_YouTube IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'LinkedIn' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(a.Custom_LinkedIn, 'https://', ''), 'http://', '') AS [@URL]
				WHERE a.Custom_LinkedIn IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Facebook' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(a.Custom_Facebook, 'https://', ''), 'http://', '') AS [@URL]
				WHERE a.Custom_Facebook IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Twitter' AS [@NM],
				'https://' AS [@PROTOCOL],
				'F' AS [@LANG],
				REPLACE(REPLACE(f.Custom_Twitter, 'https://', ''), 'http://', '') AS [@URL]
				WHERE f.Custom_Twitter IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Instagram' AS [@NM],
				'https://' AS [@PROTOCOL],
				'F' AS [@LANG],
				REPLACE(REPLACE(f.Custom_Instagram, 'https://', ''), 'http://', '') AS [@URL]
				WHERE f.Custom_Instagram IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'YouTube' AS [@NM],
				'https://' AS [@PROTOCOL],
				'F' AS [@LANG],
				REPLACE(REPLACE(f.Custom_YouTube, 'https://', ''), 'http://', '') AS [@URL]
				WHERE f.Custom_YouTube IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'LinkedIn' AS [@NM],
				'https://' AS [@PROTOCOL],
				'F' AS [@LANG],
				REPLACE(REPLACE(f.Custom_LinkedIn, 'https://', ''), 'http://', '') AS [@URL]
				WHERE f.Custom_LinkedIn IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Facebook' AS [@NM],
				'https://' AS [@PROTOCOL],
				'F' AS [@LANG],
				REPLACE(REPLACE(f.Custom_Facebook, 'https://', ''), 'http://', '') AS [@URL]
				WHERE f.Custom_Facebook IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			)
		FOR XML PATH('SOCIAL_MEDIA'), TYPE),
		(SELECT 
			a.LastVerifiedByName [@NM],
			a.LastVerifiedByTitle [@TTL],
			a.LastVerifiedByPhoneNumber [@PHN],
			a.LastVerifiedByEmailAddress [@EML],
			f.LastVerifiedByName [@NMF],
			f.LastVerifiedByTitle [@TTLF],
			f.LastVerifiedByPhoneNumber [@PHNF],
			f.LastVerifiedByEmailAddress [@EMLF]
		FOR XML PATH('SOURCE'), TYPE),
		(SELECT 1 AS [@V] FOR XML PATH('SOURCE_FROM_ICAROL'),TYPE),
		(SELECT 
			(SELECT
				(SELECT i.ItemID AS [@V]
				FROM dbo.fn_GBL_ParseVarCharIDList(l.ItemId, '*') i
				FOR XML PATH('TM'), TYPE)
			FROM dbo.fn_GBL_ParseVarCharIDList(a.TaxonomyCodes, ';') l
			FOR XML PATH('LNK'), TYPE)
		FOR XML PATH('TAXONOMY'), TYPE),
		(SELECT
			 CASE WHEN a.PhoneTTY  IS NOT NULL AND a.PhoneTTYDescription  IS NOT NULL THEN a.PhoneTTYDescription + ': ' ELSE '' END + a.PhoneTTY AS [@V],
			 CASE WHEN f.PhoneTTY  IS NOT NULL AND f.PhoneTTYDescription  IS NOT NULL THEN f.PhoneTTYDescription + ': ' ELSE '' END + f.PhoneTTY AS [@VF]
		  FOR XML PATH('TDD_PHONE'), TYPE),
		(SELECT 
			CASE WHEN a.PhoneTollFree  IS NOT NULL AND a.PhoneTollFreeDescription  IS NOT NULL THEN a.PhoneTollFreeDescription + ': ' ELSE '' END + a.PhoneTollFree AS [@V],
			CASE WHEN f.PhoneTollFree  IS NOT NULL AND f.PhoneTollFreeDescription  IS NOT NULL THEN f.PhoneTollFreeDescription + ': ' ELSE '' END + f.PhoneTollFree AS [@VF]
		 FOR XML PATH('TOLL_FREE_PHONE'), TYPE),
		(SELECT REPLACE(a.LastVerifiedOn, ' ', 'T') AS [@V], REPLACE(a.LastVerifiedOn, ' ', 'T') AS [@VF] FOR XML PATH('UPDATE_DATE'), TYPE),
		(SELECT a.LastVerificationApprovedBy AS [@V], a.LastVerificationApprovedBy AS [@VF] FOR XML PATH('UPDATED_BY'), TYPE),
		(SELECT REPLACE(REPLACE(a.WebsiteAddress, 'https://', ''), 'http://', '') AS [@V], REPLACE(REPLACE(a.WebsiteAddress, 'https://', ''), 'http://', '') AS [@VF] FOR XML PATH('WWW_ADDRESS'), TYPE)
	
	FOR XML PATH('RECORD'), TYPE)) as nvarchar(MAX)) AS record
	FROM dbo.CIC_iCarolImportRollup AS a
	LEFT JOIN dbo.CIC_iCarolImportRollup AS f
		ON a.ResourceAgencyNum=f.ResourceAgencyNum AND a.LangID=0 AND f.LangID=2
	LEFT JOIN dbo.GBL_BaseTable bt ON
		bt.EXTERNAL_ID=a.ResourceAgencyNum
	-- MemberID check isn't needed because we did it above and we can simplify this check?
	WHERE a.LangID=0 AND ((bt.MemberID IS NOT NULL AND bt.MemberID=@MemberID) OR (bt.MemberID IS NULL AND EXISTS(SELECT * FROM dbo.GBL_Agency ac WHERE ac.AgencyCode=a.RECORD_OWNER AND ac.AutoImportFromICarol=1 AND ac.MemberID=@MemberID)))
		AND EXISTS(SELECT * FROM @updated AS u WHERE u.ResourceAgencyNum = a.ResourceAgencyNum AND u.TaxonomyLevelName=a.TaxonomyLevelName)
	-- Records MUST be in order of Agency, ProgramAtSite, Site so that ProgramAtSite and Site can reference agency in ORG_NUM and Site can reference ProgramAtSite in LOCATION_SERVICES
	-- Records will be processed by import system in the order they appear in this file.
	ORDER BY CASE WHEN a.TaxonomyLevelName = 'Agency' THEN 0 WHEN a.TaxonomyLevelName='ProgramAtSite' THEN 1 WHEN a.TaxonomyLevelName = 'Site' THEN 2 ELSE 3 END

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_iCarolImport_CreateSharing] TO [cioc_login_role]
GO
