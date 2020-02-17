SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CIC_iCarolImport_CreateSharing]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		INT
SET @Error = 0

DECLARE @updated AS TABLE
(
	ResourceAgencyNum NVARCHAR(50) COLLATE Latin1_General_100_CI_AI  NOT NULL  PRIMARY KEY,
	TaxonomyLevelName NVARCHAR(MAX) COLLATE Latin1_General_100_CI_AI NULL
)

UPDATE i SET i.IMPORTED_DATE=GETDATE() 
OUTPUT deleted.ResourceAgencyNum, deleted.TaxonomyLevelName INTO @updated
FROM dbo.CIC_iCarolImport i
INNER JOIN dbo.GBL_BaseTable ib 
	ON ib.EXTERNAL_ID=i.ResourceAgencyNum
WHERE i.LangID=@@LANGID AND i.IMPORTED_DATE IS NULL OR i.IMPORTED_DATE < i.SYNC_DATE AND i.TaxonomyLevelName <> 'Program'


SELECT m.MemberID,
(SELECT (
	-- Agency
	SELECT 
	 a.ResourceAgencyNum AS [@NUM], bt.RECORD_OWNER AS [@RECORD_OWNER],
		1 AS [@HAS_ENGLISH],
		(SELECT a.DisabilitiesAccess AS [@N] FOR XML PATH('ACCESSIBILITY'), TYPE),
		(SELECT a.LicenseAccreditation AS [@V] FOR XML PATH('ACCREDITED'), TYPE),
		(SELECT CASE WHEN a.PhoneNumberAfterHours IS NOT NULL AND a.PhoneNumberAfterHoursDescription  IS NOT NULL THEN a.PhoneNumberAfterHoursDescription + ': ' ELSE '' END + a.PhoneNumberAfterHours AS [@V] FOR XML PATH('AFTER_HRS_PHONE'), TYPE), 
		(SELECT 
				(SELECT
					'E' AS [@LANG],
					 a.AlternateName AS [@V]
				 WHERE a.AlternateName IS NOT NULL
				 FOR XML PATH('NM'), TYPE
				)
			FOR XML PATH('ALT_ORG'), TYPE),
		(SELECT a.ApplicationProcess AS [@V] FOR XML PATH('APPLICATION'), TYPE),
		(SELECT a.BusServiceAccess AS [@N] FOR XML PATH('BUS_ROUTES'),TYPE),
		(SELECT a.InternalNotes AS [@V] FOR XML PATH('COMMENTS'), TYPE),
		(SELECT 'E' AS [@LANG], a.MainContactName AS [@NMLAST], a.MainContactTitle AS [@TTL], a.MainContactPhoneNumber AS [@PH1N], a.MainContactEmailAddress AS [@EML]
		-- NOTE a.MainContactType didn't have any data in it so it was not mapped
		FOR XML PATH('CONTACT'), ROOT('CONTACT_1'),TYPE),
		(SELECT CASE WHEN a.PhoneNumberHotline IS NOT NULL AND a.PhoneNumberHotlineDescription  IS NOT NULL THEN a.PhoneNumberHotlineDescription + ': ' ELSE '' END + a.PhoneNumberHotline AS [@V] FOR XML PATH('CRISIS_PHONE'), TYPE), 
		(SELECT a.DocumentsRequired AS [@V] FOR XML PATH('DOCUMENTS_REQUIRED'), TYPE),
		(SELECT a.EmailAddressMain AS [@V] FOR XML PATH('E_MAIL'), TYPE),
		(SELECT a.YearIncorporated AS [@V] FOR XML PATH('ESTABLISHED'), TYPE),
		(SELECT 'E' AS [@LANG], a.SeniorWorkerName AS [@NMLAST], a.SeniorWorkerTitle AS [@TTL], a.SeniorWorkerPhoneNumber AS [@PH1N], a.SeniorWorkerEmailAddress AS [@EML]
		FOR XML PATH('CONTACT'), ROOT('EXEC_1'),TYPE),
		  /* This doesn't seem to have useful data in it
		(SELECT
			'SEARCHHINTS' AS [@FLD],
			SearchHints AS [@V]
		 FOR XML PATH('EXTRA'), TYPE),
		 */
		(SELECT a.PhoneFax AS [@V] FOR XML PATH('FAX'), TYPE),
		(SELECT a.FeeStructureSource AS [@N] FOR XML PATH('FEES'), TYPE),
		(SELECT
			 CASE WHEN a.Latitude IS NOT NULL AND a.Longitude IS NOT NULL THEN 3 ELSE 0 END AS [@TYPE],
			 a.Latitude AS [@LAT],
			 a.Longitude AS [@LONG]
		  FOR XML PATH('GEOCODE'), TYPE),
		(SELECT COALESCE(a.HoursOfOperation, a.Hours) AS [@V] FOR XML PATH('HOURS'), TYPE),
		(SELECT
			a.InternalMemoGUID AS [@GID],
			REPLACE(COALESCE(a.UpdatedOn, cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(GETDATE())), ' ', 'T') AS [@CREATED],
			'E' AS [@LANG],
			REPLACE(COALESCE(a.UpdatedOn, cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(GETDATE())), ' ', 'T') AS [@MOD],
			a.InternalNotesForEditorsAndViewers AS [@V]
			WHERE a.InternalNotesForEditorsAndViewers IS NOT NULL
		 FOR XML PATH('N'), ROOT('INTERNAL_MEMO'), TYPE),
		(SELECT COALESCE(a.LanguagesOffered, a.LanguagesOfferedList) AS [@N] FOR XML PATH('LANGUAGES'), TYPE),
		(SELECT COALESCE(a.[Custom_Legal Name], a.[OfficialName]) AS [@V] FOR XML PATH('LEGAL_ORG'), TYPE),
		(SELECT 
			 a.MailingAttentionName AS [@CO],
			 a.MailingAddress1 AS [@LN1],
			 a.MailingAddress2 AS [@LN2],
			 a.MailingCity AS [@CTY],
			 a.MailingStateProvince AS [@PRV],
			 a.MailingPostalCode AS [@PC],
			 a.MailingCountry AS [@CTRY]
			FOR XML PATH('MAIL_ADDRESS'), TYPE
		),
		(SELECT CASE WHEN COALESCE(a.ExcludeFromWebsite, 'No') = 'Yes' THEN 1 ELSE 0 END AS [@V] FOR XML PATH('NON_PUBLIC'), TYPE),
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
				) AS i FOR XML PATH('')), 1, 2, '')
			
		 ) AS [@V] FOR XML PATH('OFFICE_PHONE'), TYPE),
		(SELECT a.AgencyDescription AS [@V] FOR XML PATH('ORG_DESCRIPTION'), TYPE),
		(SELECT a.PublicName AS [@V] FOR XML PATH('ORG_LEVEL_1'), TYPE),
		(SELECT 'AGENCY' AS [@V] FOR XML PATH('CD'), ROOT('ORG_LOCATION_SERVICE'), TYPE),
		(SELECT a.[Custom_Public Comments] AS [@V] FOR XML PATH('PUBLIC_COMMENTS'), TYPE),
		(SELECT 
			 a.PhysicalAddress1 AS [@LN1],
			 a.PhysicalAddress2 AS [@LN2],
			 a.PhysicalCity AS [@CTY],
			 a.PhysicalStateProvince AS [@PRV],
			 a.PhysicalPostalCode AS [@PC],
			 a.PhysicalCountry AS [@CTRY]
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
			)
		FOR XML PATH('SOCIAL_MEDIA'), TYPE),
		(SELECT 
			a.LastVerifiedByName [@NM],
			a.LastVerifiedByTitle [@TTL],
			a.LastVerifiedByPhoneNumber [@PHN],
			a.LastVerifiedByEmailAddress [@EML]
		FOR XML PATH('SOURCE'), TYPE),
		(SELECT 
			(SELECT
				(SELECT i.ItemID AS [@V]
				FROM dbo.fn_GBL_ParseVarCharIDList(l.ItemId, '*') i
				FOR XML PATH('TM'), TYPE)
			FROM dbo.fn_GBL_ParseVarCharIDList(a.TaxonomyCodes, ';') l
			FOR XML PATH('LNK'), TYPE)
		FOR XML PATH('TAXONOMY'), TYPE),
		(SELECT CASE WHEN a.PhoneTTY  IS NOT NULL AND a.PhoneTTYDescription  IS NOT NULL THEN a.PhoneTTYDescription + ': ' ELSE '' END + a.PhoneTTY AS [@V] FOR XML PATH('TDD_PHONE'), TYPE),
		(SELECT CASE WHEN a.PhoneTollFree  IS NOT NULL AND a.PhoneTollFreeDescription  IS NOT NULL THEN a.PhoneTollFreeDescription + ': ' ELSE '' END + a.PhoneTollFree AS [@V] FOR XML PATH('TOLL_FREE_PHONE'), TYPE),
		(SELECT REPLACE(a.LastVerifiedOn, ' ', 'T') AS [@V] FOR XML PATH('UPDATE_DATE'), TYPE),
		(SELECT a.LastVerificationApprovedBy AS [@V] FOR XML PATH('UPDATED_BY'), TYPE),
		(SELECT REPLACE(REPLACE(a.WebsiteAddress, 'https://', ''), 'http://', '') AS [@V] FOR XML PATH('WWW_ADDRESS'), TYPE)

	FROM dbo.CIC_iCarolImport AS a
	INNER JOIN @updated AS u
		ON u.ResourceAgencyNum = a.ResourceAgencyNum AND u.TaxonomyLevelName=a.TaxonomyLevelName
	INNER JOIN dbo.GBL_BaseTable bt ON
		bt.EXTERNAL_ID=a.ResourceAgencyNum
	WHERE a.langid=@@LANGID AND a.TaxonomyLevelName='Agency' AND bt.MemberID=m.MemberID
	FOR XML PATH('RECORD'), TYPE
), 
(
	-- Site
	SELECT 
		s.ResourceAgencyNum AS [@NUM], bt.RECORD_OWNER AS [@RECORD_OWNER],
		1 AS [@HAS_ENGLISH],
		(SELECT COALESCE(s.DisabilitiesAccess, a.DisabilitiesAccess) AS [@N] FOR XML PATH('ACCESSIBILITY'), TYPE),
		(SELECT COALESCE(s.LicenseAccreditation, a.LicenseAccreditation) AS [@V] FOR XML PATH('ACCREDITED'), TYPE),
		(SELECT CASE WHEN COALESCE(s.PhoneNumberAfterHours, a.PhoneNumberAfterHours)  IS NOT NULL AND COALESCE(s.PhoneNumberAfterHoursDescription, a.PhoneNumberAfterHoursDescription)  IS NOT NULL THEN COALESCE(s.PhoneNumberAfterHoursDescription, a.PhoneNumberAfterHoursDescription) + ': ' ELSE '' END + COALESCE(s.PhoneNumberAfterHours, a.PhoneNumberAfterHours) AS [@V] FOR XML PATH('AFTER_HRS_PHONE'), TYPE), 
		(SELECT 
				(SELECT 
					'E' AS [@LANG],
					COALESCE(s.AlternateName, a.AlternateName) AS [@V]
				 WHERE a.AlternateName IS NOT NULL OR s.AlternateName IS NOT NULL
				 FOR XML PATH('NM'), TYPE
				)
			FOR XML PATH('ALT_ORG'), TYPE),
		(SELECT COALESCE(s.ApplicationProcess, a.ApplicationProcess) AS [@V] FOR XML PATH('APPLICATION'), TYPE),
		(SELECT COALESCE(s.BusServiceAccess, a.BusServiceAccess) AS [@N] FOR XML PATH('BUS_ROUTES'),TYPE),
		(SELECT COALESCE(s.InternalNotes, a.InternalNotes) AS [@V] FOR XML PATH('COMMENTS'), TYPE),
		(SELECT 'E' AS [@LANG], COALESCE(s.MainContactName, a.MainContactName) AS [@NMLAST], COALESCE(s.MainContactTitle, a.MainContactTitle) AS [@TTL], COALESCE(s.MainContactPhoneNumber, a.MainContactPhoneNumber) AS [@PH1N], COALESCE(s.MainContactEmailAddress, a.MainContactEmailAddress) AS [@EML]
		-- NOTE COALESCE(s.MainContactType, a.MainContactType) didn't have any data in it so it was not mapped
		FOR XML PATH('CONTACT'), ROOT('CONTACT_1'),TYPE),
		(SELECT CASE WHEN COALESCE(s.PhoneNumberHotline, a.PhoneNumberHotline)  IS NOT NULL AND COALESCE(s.PhoneNumberHotlineDescription, a.PhoneNumberHotlineDescription)  IS NOT NULL THEN COALESCE(s.PhoneNumberHotlineDescription, a.PhoneNumberHotlineDescription) + ': ' ELSE '' END + COALESCE(s.PhoneNumberHotline, a.PhoneNumberHotline) AS [@V] FOR XML PATH('CRISIS_PHONE'), TYPE), 
		(SELECT COALESCE(s.DocumentsRequired, a.DocumentsRequired) AS [@V] FOR XML PATH('DOCUMENTS_REQUIRED'), TYPE),
		(SELECT COALESCE(s.EmailAddressMain, a.EmailAddressMain) AS [@V] FOR XML PATH('E_MAIL'), TYPE),
		(SELECT COALESCE(s.YearIncorporated, a.YearIncorporated) AS [@V] FOR XML PATH('ESTABLISHED'), TYPE),
		(SELECT 'E' AS [@LANG], COALESCE(s.SeniorWorkerName, a.SeniorWorkerName) AS [@NMLAST], COALESCE(s.SeniorWorkerTitle, a.SeniorWorkerTitle) AS [@TTL], COALESCE(s.SeniorWorkerPhoneNumber, a.SeniorWorkerPhoneNumber) AS [@PH1N], COALESCE(s.SeniorWorkerEmailAddress, a.SeniorWorkerEmailAddress) AS [@EML]
		FOR XML PATH('CONTACT'), ROOT('EXEC_1'),TYPE),
		  /* This doesn't seem to have useful data in it
		(SELECT
			'SEARCHHINTS' AS [@FLD],
			SearchHints AS [@V]
		 FOR XML PATH('EXTRA'), TYPE),
		 */
		(SELECT COALESCE(s.PhoneFax, a.PhoneFax) AS [@V] FOR XML PATH('FAX'), TYPE),
		(SELECT COALESCE(s.FeeStructureSource, a.FeeStructureSource) AS [@N] FOR XML PATH('FEES'), TYPE),
		(SELECT
			 CASE WHEN COALESCE(s.Latitude, a.Latitude) IS NOT NULL AND COALESCE(s.Longitude, a.Longitude) IS NOT NULL THEN 3 ELSE 0 END AS [@TYPE],
			 COALESCE(s.Latitude, a.Latitude) AS [@LAT],
			 COALESCE(s.Longitude, a.Longitude) AS [@LONG]
		  FOR XML PATH('GEOCODE'), TYPE),
		(SELECT COALESCE(s.HoursOfOperation, s.Hours, a.HoursOfOperation, a.Hours) AS [@V] FOR XML PATH('HOURS'), TYPE),
		(SELECT
			s.InternalMemoGUID AS [@GID],
			REPLACE(COALESCE(s.UpdatedOn, cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(GETDATE())), ' ', 'T') AS [@CREATED],
			'E' AS [@LANG],
			REPLACE(COALESCE(a.UpdatedOn, cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(GETDATE())), ' ', 'T') AS [@MOD],
			COALESCE(s.InternalNotesForEditorsAndViewers, a.InternalNotesForEditorsAndViewers) AS [@V]
			WHERE a.InternalNotesForEditorsAndViewers IS NOT NULL AND s.InternalNotesForEditorsAndViewers IS NOT NULL
		 FOR XML PATH('N'), ROOT('INTERNAL_MEMO'), TYPE),
		(SELECT COALESCE(s.LanguagesOffered, s.LanguagesOfferedList, a.LanguagesOffered, a.LanguagesOfferedList) AS [@N] FOR XML PATH('LANGUAGES'), TYPE),
		(SELECT COALESCE(s.[Custom_Legal Name], a.[Custom_Legal Name]) AS [@V] FOR XML PATH('LEGAL_ORG'), TYPE),
		(SELECT s.AgencyDescription AS [@V] FOR XML PATH('LOCATION_DESCRIPTION'), TYPE),
		(SELECT s.PublicName AS [@V] FOR XML PATH('LOCATION_NAME'), TYPE),
		(SELECT 
				COALESCE(s.MailingAttentionName, a.MailingAttentionName) AS [@CO],
				COALESCE(s.MailingAddress1, a.MailingAddress1) AS [@LN1],
				COALESCE(s.MailingAddress2, a.MailingAddress2) AS [@LN2],
				COALESCE(s.MailingCity, a.MailingCity) AS [@CTY],
				COALESCE(s.MailingStateProvince, a.MailingStateProvince) AS [@PRV],
				COALESCE(s.MailingPostalCode, a.MailingPostalCode) AS [@PC],
				COALESCE(s.MailingCountry, a.MailingCountry) AS [@CTRY]
			FOR XML PATH('MAIL_ADDRESS'), TYPE
		),
		(SELECT CASE WHEN COALESCE(s.ExcludeFromWebsite, a.ExcludeFromWebsite, 'No') = 'Yes' THEN 1 ELSE 0 END AS [@V] FOR XML PATH('NON_PUBLIC'), TYPE),
		(SELECT
			 (SELECT STUFF((SELECT '; ' + NumberValue FROM (

			SELECT CASE WHEN COALESCE(s.PhoneNumberBusinessLine, a.PhoneNumberBusinessLine)  IS NOT NULL AND COALESCE(s.PhoneNumberBusinessLineDescription, a.PhoneNumberBusinessLineDescription)  IS NOT NULL THEN COALESCE(s.PhoneNumberBusinessLineDescription, a.PhoneNumberBusinessLineDescription) + ': ' ELSE '' END + COALESCE(s.PhoneNumberBusinessLine, a.PhoneNumberBusinessLine) AS NumberValue
			UNION ALL SELECT 
				CASE WHEN PhoneNumber IS NOT NULL AND PhoneName IS NOT NULL THEN PhoneName + ': ' ELSE '' END + PhoneNumber AS NumberValue
				FROM (
					VALUES 
						(COALESCE(s.Phone1Number, a.Phone1Number), COALESCE(s.Phone1Name, a.Phone1Name)),
						(COALESCE(s.Phone2Number, a.Phone2Number), COALESCE(s.Phone2Name, a.Phone2Name)),
						(COALESCE(s.Phone3Number, a.Phone3Number), COALESCE(s.Phone3Name, a.Phone3Name)),
						(COALESCE(s.Phone4Number, a.Phone4Number), COALESCE(s.Phone4Name, a.Phone4Name)),
						(COALESCE(s.Phone5Number, a.Phone5Number), COALESCE(s.Phone5Name, a.Phone5Name)),
						(COALESCE(s.PhoneNumberOutOfArea,a.PhoneNumberOutOfArea), COALESCE(s.PhoneNumberOutOfAreaDescription, a.PhoneNumberOutOfAreaDescription))
					) AS cte (PhoneNumber, PhoneName)
					WHERE cte.PhoneNumber IS NOT NULL
				) AS i FOR XML PATH('')), 1, 2, '')
			
		 ) AS [@V] FOR XML PATH('OFFICE_PHONE'), TYPE),
		(SELECT a.AgencyDescription AS [@V] FOR XML PATH('ORG_DESCRIPTION'), TYPE),
		(SELECT  a.PublicName AS [@V] FOR XML PATH('ORG_LEVEL_1'), TYPE),
		(SELECT 'SITE' AS [@V] FOR XML PATH('CD'), ROOT('ORG_LOCATION_SERVICE'), TYPE),
		(SELECT COALESCE(s.[Custom_Public Comments], a.[Custom_Public Comments]) AS [@V] FOR XML PATH('PUBLIC_COMMENTS'), TYPE),
		(SELECT 
				COALESCE(s.PhysicalAddress1, a.PhysicalAddress1) AS [@LN1],
				COALESCE(s.PhysicalAddress2, a.PhysicalAddress2) AS [@LN2],
				COALESCE(s.PhysicalCity, a.PhysicalCity) AS [@CTY],
				COALESCE(s.PhysicalStateProvince, a.PhysicalStateProvince) AS [@PRV],
				COALESCE(s.PhysicalPostalCode, a.PhysicalPostalCode) AS [@PC],
				COALESCE(s.PhysicalCountry, a.PhysicalCountry) AS [@CTRY]
			FOR XML PATH('SITE_ADDRESS'), TYPE
		),
		(SELECT
			(SELECT 'Twitter' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(COALESCE(s.Custom_Twitter, a.Custom_Twitter), 'https://', ''), 'http://', '') AS [@URL]
				WHERE COALESCE(s.Custom_Twitter, a.Custom_Twitter) IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Instagram' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(COALESCE(s.Custom_Instagram, a.Custom_Instagram), 'https://', ''), 'http://', '') AS [@URL]
				WHERE COALESCE(s.Custom_Instagram, a.Custom_Instagram) IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'YouTube' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(COALESCE(s.Custom_YouTube, a.Custom_YouTube), 'https://', ''), 'http://', '') AS [@URL]
				WHERE COALESCE(s.Custom_YouTube, a.Custom_YouTube) IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'LinkedIn' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(COALESCE(s.Custom_LinkedIn, a.Custom_LinkedIn), 'https://', ''), 'http://', '') AS [@URL]
				WHERE COALESCE(s.Custom_LinkedIn, a.Custom_LinkedIn) IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Facebook' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(COALESCE(s.Custom_Facebook, a.Custom_Facebook), 'https://', ''), 'http://', '') AS [@URL]
				WHERE COALESCE(s.Custom_Facebook, a.Custom_Facebook) IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			)
		FOR XML PATH('SOCIAL_MEDIA'), TYPE),
		(SELECT 
			s.LastVerifiedByName [@NM],
			s.LastVerifiedByTitle [@TTL],
			s.LastVerifiedByPhoneNumber [@PHN],
			s.LastVerifiedByEmailAddress [@EML]
		FOR XML PATH('SOURCE'), TYPE),
		(SELECT 
			(SELECT
				(SELECT i.ItemID AS [@V]
				FROM dbo.fn_GBL_ParseVarCharIDList(l.ItemId, '*') i
				FOR XML PATH('TM'), TYPE)
			FROM dbo.fn_GBL_ParseVarCharIDList(COALESCE(s.TaxonomyCodes, a.TaxonomyCodes), ';') l
			FOR XML PATH('LNK'), TYPE)
		FOR XML PATH('TAXONOMY'), TYPE),
		(SELECT CASE WHEN COALESCE(s.PhoneTTY, a.PhoneTTY)  IS NOT NULL AND COALESCE(s.PhoneTTYDescription, a.PhoneTTYDescription)  IS NOT NULL THEN COALESCE(s.PhoneTTYDescription, a.PhoneTTYDescription) + ': ' ELSE '' END + COALESCE(s.PhoneTTY, a.PhoneTTY) AS [@V] FOR XML PATH('TDD_PHONE'), TYPE),
		(SELECT CASE WHEN COALESCE(s.PhoneTollFree, a.PhoneTollFree)  IS NOT NULL AND COALESCE(s.PhoneTollFreeDescription, a.PhoneTollFreeDescription)  IS NOT NULL THEN COALESCE(s.PhoneTollFreeDescription, a.PhoneTollFreeDescription) + ': ' ELSE '' END + COALESCE(s.PhoneTollFree, a.PhoneTollFree) AS [@V] FOR XML PATH('TOLL_FREE_PHONE'), TYPE),
		(SELECT REPLACE(s.LastVerifiedOn, ' ', 'T') AS [@V] FOR XML PATH('UPDATE_DATE'), TYPE),
		(SELECT s.LastVerificationApprovedBy AS [@V] FOR XML PATH('UPDATED_BY'), TYPE),
		(SELECT REPLACE(REPLACE(COALESCE(s.WebsiteAddress, a.WebsiteAddress), 'https://', ''), 'http://', '') AS [@V] FOR XML PATH('WWW_ADDRESS'), TYPE)

	FROM dbo.CIC_iCarolImport s
	INNER JOIN @updated AS u
		ON u.ResourceAgencyNum = s.ResourceAgencyNum AND u.TaxonomyLevelName=s.TaxonomyLevelName
	INNER JOIN dbo.GBL_BaseTable bt ON
		bt.EXTERNAL_ID=s.ResourceAgencyNum
	LEFT JOIN dbo.CIC_iCarolImport a
		ON s.ParentAgencyNum=a.ResourceAgencyNum AND a.TaxonomyLevelName='Agency' AND a.LangID=@@LANGID
	WHERE s.langid=@@LANGID AND s.TaxonomyLevelName='Site' AND bt.MemberID=m.MemberID
	FOR XML PATH('RECORD'), TYPE
), 
(
	-- ProgramAtSite
	SELECT 
		pas.ResourceAgencyNum AS [@NUM], bt.RECORD_OWNER AS [@RECORD_OWNER],
		1 AS [@HAS_ENGLISH],
		(SELECT COALESCE(pas.DisabilitiesAccess, p.DisabilitiesAccess, s.DisabilitiesAccess, a.DisabilitiesAccess) AS [@N] FOR XML PATH('ACCESSIBILITY'), TYPE),
		(SELECT COALESCE(pas.LicenseAccreditation, p.LicenseAccreditation, s.LicenseAccreditation, a.LicenseAccreditation) AS [@V] FOR XML PATH('ACCREDITED'), TYPE),
		(SELECT CASE WHEN COALESCE(pas.PhoneNumberAfterHours, p.PhoneNumberAfterHours, s.PhoneNumberAfterHours, a.PhoneNumberAfterHours)  IS NOT NULL AND COALESCE(pas.PhoneNumberAfterHoursDescription, p.PhoneNumberAfterHoursDescription, s.PhoneNumberAfterHoursDescription, a.PhoneNumberAfterHoursDescription)  IS NOT NULL THEN COALESCE(pas.PhoneNumberAfterHoursDescription, p.PhoneNumberAfterHoursDescription, s.PhoneNumberAfterHoursDescription, a.PhoneNumberAfterHoursDescription) + ': ' ELSE '' END + COALESCE(pas.PhoneNumberAfterHours, p.PhoneNumberAfterHours, s.PhoneNumberAfterHours, a.PhoneNumberAfterHours) AS [@V] FOR XML PATH('AFTER_HRS_PHONE'), TYPE), 
		(SELECT 
				(SELECT 
					'E' AS [@LANG],
					COALESCE(pas.AlternateName, p.AlternateName, s.AlternateName, a.AlternateName) AS [@V]
				 WHERE a.AlternateName IS NOT NULL OR s.AlternateName IS NOT NULL OR pas.AlternateName IS NOT NULL OR p.AlternateName IS NOT NULL
				 FOR XML PATH('NM'), TYPE
				)
			FOR XML PATH('ALT_ORG'), TYPE),
		(SELECT COALESCE(pas.ApplicationProcess, pas.ApplicationProcess, s.ApplicationProcess, a.ApplicationProcess) AS [@V] FOR XML PATH('APPLICATION'), TYPE),
		(SELECT COALESCE(pas.BusServiceAccess, p.BusServiceAccess, s.BusServiceAccess, a.BusServiceAccess) AS [@N] FOR XML PATH('BUS_ROUTES'),TYPE),
		(SELECT COALESCE(pas.InternalNotes, p.InternalNotes, s.InternalNotes, a.InternalNotes) AS [@V] FOR XML PATH('COMMENTS'), TYPE),
		(SELECT 'E' AS [@LANG], COALESCE(pas.MainContactName, p.MainContactName, s.MainContactName, a.MainContactName) AS [@NMLAST], COALESCE(pas.MainContactTitle, p.MainContactTitle, s.MainContactTitle, a.MainContactTitle) AS [@TTL], COALESCE(pas.MainContactPhoneNumber, p.MainContactPhoneNumber, s.MainContactPhoneNumber, a.MainContactPhoneNumber) AS [@PH1N], COALESCE(pas.MainContactEmailAddress, p.MainContactEmailAddress, s.MainContactEmailAddress, a.MainContactEmailAddress) AS [@EML]
		-- NOTE COALESCE(pas.MainContactType, p.MainContactType, s.MainContactType, a.MainContactType) didn't have any data in it so it was not mapped
		FOR XML PATH('CONTACT'), ROOT('CONTACT_1'),TYPE),
		(SELECT CASE WHEN COALESCE(pas.PhoneNumberHotline, p.PhoneNumberHotline, s.PhoneNumberHotline, a.PhoneNumberHotline)  IS NOT NULL AND COALESCE(pas.PhoneNumberHotlineDescription, p.PhoneNumberHotlineDescription, s.PhoneNumberHotlineDescription, a.PhoneNumberHotlineDescription)  IS NOT NULL THEN COALESCE(pas.PhoneNumberHotlineDescription, p.PhoneNumberHotlineDescription, s.PhoneNumberHotlineDescription, a.PhoneNumberHotlineDescription) + ': ' ELSE '' END + COALESCE(pas.PhoneNumberHotline, p.PhoneNumberHotline, s.PhoneNumberHotline, a.PhoneNumberHotline) AS [@V] FOR XML PATH('CRISIS_PHONE'), TYPE), 
		(SELECT COALESCE(pas.AgencyDescription, p.AgencyDescription) AS [@V] FOR XML PATH('DESCRIPTION'), TYPE),
		(SELECT COALESCE(pas.DocumentsRequired, p.DocumentsRequired, s.DocumentsRequired, a.DocumentsRequired) AS [@V] FOR XML PATH('DOCUMENTS_REQUIRED'), TYPE),
		(SELECT COALESCE(pas.EmailAddressMain, p.EmailAddressMain, s.EmailAddressMain, a.EmailAddressMain) AS [@V] FOR XML PATH('E_MAIL'), TYPE),
		(SELECT COALESCE(pas.YearIncorporated, p.YearIncorporated, s.YearIncorporated, a.YearIncorporated) AS [@V] FOR XML PATH('ESTABLISHED'), TYPE),
		(SELECT 'E' AS [@LANG], COALESCE(pas.SeniorWorkerName, p.SeniorWorkerName, s.SeniorWorkerName, a.SeniorWorkerName) AS [@NMLAST], COALESCE(pas.SeniorWorkerTitle, p.SeniorWorkerTitle, s.SeniorWorkerTitle, a.SeniorWorkerTitle) AS [@TTL], COALESCE(pas.SeniorWorkerPhoneNumber, p.SeniorWorkerPhoneNumber, s.SeniorWorkerPhoneNumber, a.SeniorWorkerPhoneNumber) AS [@PH1N], COALESCE(pas.SeniorWorkerEmailAddress, p.SeniorWorkerEmailAddress, s.SeniorWorkerEmailAddress, a.SeniorWorkerEmailAddress) AS [@EML]
		FOR XML PATH('CONTACT'), ROOT('EXEC_1'),TYPE),
		  /* This doesn't seem to have useful data in it
		(SELECT
			'SEARCHHINTS' AS [@FLD],
			SearchHints AS [@V]
		 FOR XML PATH('EXTRA'), TYPE),
		 */
		(SELECT COALESCE(pas.PhoneFax, p.PhoneFax, s.PhoneFax, a.PhoneFax) AS [@V] FOR XML PATH('FAX'), TYPE),
		(SELECT COALESCE(pas.FeeStructureSource, p.FeeStructureSource, s.FeeStructureSource, a.FeeStructureSource) AS [@N] FOR XML PATH('FEES'), TYPE),
		(SELECT
			 CASE WHEN COALESCE(pas.Latitude, p.Latitude, s.Latitude, a.Latitude) IS NOT NULL AND COALESCE(pas.Longitude, p.Longitude, s.Longitude, a.Longitude) IS NOT NULL THEN 3 ELSE 0 END AS [@TYPE],
			 COALESCE(pas.Latitude, p.Latitude, s.Latitude, a.Latitude) AS [@LAT],
			 COALESCE(pas.Longitude, p.Longitude, s.Longitude, a.Longitude) AS [@LONG]
		  FOR XML PATH('GEOCODE'), TYPE),
		(SELECT COALESCE(pas.HoursOfOperation, pas.Hours, p.HoursOfOperation, p.Hours, s.HoursOfOperation, s.Hours, a.HoursOfOperation, a.Hours) AS [@V] FOR XML PATH('HOURS'), TYPE),
		(SELECT
			pas.InternalMemoGUID AS [@GID],
			REPLACE(COALESCE(pas.UpdatedOn, p.UpdatedOn, cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(GETDATE())), ' ', 'T') AS [@CREATED],
			'E' AS [@LANG],
			REPLACE(COALESCE(a.UpdatedOn, cioc_shared.dbo.fn_SHR_GBL_XML_DateFormat(GETDATE())), ' ', 'T') AS [@MOD],
			COALESCE(pas.InternalNotesForEditorsAndViewers, p.InternalNotesForEditorsAndViewers, s.InternalNotesForEditorsAndViewers, a.InternalNotesForEditorsAndViewers) AS [@V]
			WHERE a.InternalNotesForEditorsAndViewers IS NOT NULL AND s.InternalNotesForEditorsAndViewers IS NOT NULL AND pas.InternalNotesForEditorsAndViewers IS NOT NULL AND p.InternalNotesForEditorsAndViewers IS NOT NULL
		 FOR XML PATH('N'), ROOT('INTERNAL_MEMO'), TYPE),
		(SELECT COALESCE(pas.LanguagesOffered, pas.LanguagesOfferedList, p.LanguagesOffered, p.LanguagesOfferedList, s.LanguagesOffered, s.LanguagesOfferedList, a.LanguagesOffered, a.LanguagesOfferedList) AS [@N] FOR XML PATH('LANGUAGES'), TYPE),
		(SELECT COALESCE(pas.[Custom_Legal Name], p.[Custom_Legal Name], s.[Custom_Legal Name], a.[Custom_Legal Name]) AS [@V] FOR XML PATH('LEGAL_ORG'), TYPE),
		(SELECT s.AgencyDescription AS [@V] FOR XML PATH('LOCATION_DESCRIPTION'), TYPE),
		(SELECT COALESCE(pas.PublicName, p.PublicName, s.PublicName) AS [@V] FOR XML PATH('LOCATION_NAME'), TYPE),
		(SELECT 
				COALESCE(pas.MailingAttentionName, p.MailingAttentionName, s.MailingAttentionName, a.MailingAttentionName) AS [@CO],
				COALESCE(pas.MailingAddress1, p.MailingAddress1, s.MailingAddress1, a.MailingAddress1) AS [@LN1],
				COALESCE(pas.MailingAddress2, p.MailingAddress2, s.MailingAddress2, a.MailingAddress2) AS [@LN2],
				COALESCE(pas.MailingCity, p.MailingCity, s.MailingCity, a.MailingCity) AS [@CTY],
				COALESCE(pas.MailingStateProvince, p.MailingStateProvince, s.MailingStateProvince, a.MailingStateProvince) AS [@PRV],
				COALESCE(pas.MailingPostalCode, p.MailingPostalCode, s.MailingPostalCode, a.MailingPostalCode) AS [@PC],
				COALESCE(pas.MailingCountry, p.MailingCountry, s.MailingCountry, a.MailingCountry) AS [@CTRY]
			FOR XML PATH('MAIL_ADDRESS'), TYPE
		),
		(SELECT CASE WHEN COALESCE(pas.ExcludeFromWebsite, p.ExcludeFromWebsite, s.ExcludeFromWebsite, a.ExcludeFromWebsite, 'No') = 'Yes' THEN 1 ELSE 0 END AS [@V] FOR XML PATH('NON_PUBLIC'), TYPE),
		(SELECT
			 (SELECT STUFF((SELECT '; ' + NumberValue FROM (

			SELECT CASE WHEN COALESCE(pas.PhoneNumberBusinessLine, p.PhoneNumberBusinessLine, s.PhoneNumberBusinessLine, a.PhoneNumberBusinessLine)  IS NOT NULL AND COALESCE(pas.PhoneNumberBusinessLineDescription, p.PhoneNumberBusinessLineDescription, s.PhoneNumberBusinessLineDescription, a.PhoneNumberBusinessLineDescription)  IS NOT NULL THEN COALESCE(pas.PhoneNumberBusinessLineDescription, p.PhoneNumberBusinessLineDescription, s.PhoneNumberBusinessLineDescription, a.PhoneNumberBusinessLineDescription) + ': ' ELSE '' END + COALESCE(pas.PhoneNumberBusinessLine, p.PhoneNumberBusinessLine, s.PhoneNumberBusinessLine, a.PhoneNumberBusinessLine) AS NumberValue
			UNION ALL SELECT 
				CASE WHEN PhoneNumber IS NOT NULL AND PhoneName IS NOT NULL THEN PhoneName + ': ' ELSE '' END + PhoneNumber AS NumberValue
				FROM (
					VALUES 
						(COALESCE(pas.Phone1Number, p.Phone1Number, s.Phone1Number, a.Phone1Number), COALESCE(pas.Phone1Name, p.Phone1Name, s.Phone1Name, a.Phone1Name)),
						(COALESCE(pas.Phone2Number, p.Phone2Number, s.Phone2Number, a.Phone2Number), COALESCE(pas.Phone2Name, p.Phone2Name, s.Phone2Name, a.Phone2Name)),
						(COALESCE(pas.Phone3Number, p.Phone3Number, s.Phone3Number, a.Phone3Number), COALESCE(pas.Phone3Name, p.Phone3Name, s.Phone3Name, a.Phone3Name)),
						(COALESCE(pas.Phone4Number, p.Phone4Number, s.Phone4Number, a.Phone4Number), COALESCE(pas.Phone4Name, p.Phone4Name, s.Phone4Name, a.Phone4Name)),
						(COALESCE(pas.Phone5Number, p.Phone5Number, s.Phone5Number, a.Phone5Number), COALESCE(pas.Phone5Name, p.Phone5Name, s.Phone5Name, a.Phone5Name)),
						-- Maybe instead of description it should be a string constant out of area
						(COALESCE(pas.PhoneNumberOutOfArea, p.PhoneNumberOutOfArea, s.PhoneNumberOutOfArea,a.PhoneNumberOutOfArea), COALESCE(pas.PhoneNumberOutOfAreaDescription, p.PhoneNumberOutOfAreaDescription, s.PhoneNumberOutOfAreaDescription, a.PhoneNumberOutOfAreaDescription))
					) AS cte (PhoneNumber, PhoneName)
					WHERE cte.PhoneNumber IS NOT NULL
				) AS i FOR XML PATH('')), 1, 2, '')
			
		 ) AS [@V] FOR XML PATH('OFFICE_PHONE'), TYPE),
		(SELECT a.AgencyDescription AS [@V] FOR XML PATH('ORG_DESCRIPTION'), TYPE),
		(SELECT  a.PublicName AS [@V] FOR XML PATH('ORG_LEVEL_1'), TYPE),
		(SELECT 'SERVICE' AS [@V] FOR XML PATH('CD'), ROOT('ORG_LOCATION_SERVICE'), TYPE),
		(SELECT COALESCE(pas.[Custom_Public Comments], p.[Custom_Public Comments], s.[Custom_Public Comments], a.[Custom_Public Comments]) AS [@V] FOR XML PATH('PUBLIC_COMMENTS'), TYPE),
		(SELECT s.PublicName AS [@V] FOR XML PATH('SERVICE_NAME_LEVEL_1'), TYPE),
		(SELECT COALESCE(pas.PublicName, p.PublicName) AS [@V] FOR XML PATH('SERVICE_NAME_LEVEL_2'), TYPE),
		(SELECT 
				COALESCE(pas.PhysicalAddress1, p.PhysicalAddress1, s.PhysicalAddress1, a.PhysicalAddress1) AS [@LN1],
				COALESCE(pas.PhysicalAddress2, p.PhysicalAddress2, s.PhysicalAddress2, a.PhysicalAddress2) AS [@LN2],
				COALESCE(pas.PhysicalCity, p.PhysicalCity, s.PhysicalCity, a.PhysicalCity) AS [@CTY],
				COALESCE(pas.PhysicalStateProvince, p.PhysicalStateProvince, s.PhysicalStateProvince, a.PhysicalStateProvince) AS [@PRV],
				COALESCE(pas.PhysicalPostalCode, p.PhysicalPostalCode, s.PhysicalPostalCode, a.PhysicalPostalCode) AS [@PC],
				COALESCE(pas.PhysicalCountry, p.PhysicalCountry, s.PhysicalCountry, a.PhysicalCountry) AS [@CTRY]
			FOR XML PATH('SITE_ADDRESS'), TYPE
		),
		(SELECT
			(SELECT 'Twitter' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(COALESCE(pas.Custom_Twitter, p.Custom_Twitter, s.Custom_Twitter, a.Custom_Twitter), 'https://', ''), 'http://', '') AS [@URL]
				WHERE COALESCE(pas.Custom_Twitter, p.Custom_Twitter, s.Custom_Twitter, a.Custom_Twitter) IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Instagram' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(COALESCE(pas.Custom_Instagram, p.Custom_Instagram, s.Custom_Instagram, a.Custom_Instagram), 'https://', ''), 'http://', '') AS [@URL]
				WHERE COALESCE(pas.Custom_Instagram, p.Custom_Instagram, s.Custom_Instagram, a.Custom_Instagram) IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'YouTube' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(COALESCE(pas.Custom_YouTube, p.Custom_YouTube, s.Custom_YouTube, a.Custom_YouTube), 'https://', ''), 'http://', '') AS [@URL]
				WHERE COALESCE(pas.Custom_YouTube, p.Custom_YouTube, s.Custom_YouTube, a.Custom_YouTube) IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'LinkedIn' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(COALESCE(pas.Custom_LinkedIn, p.Custom_LinkedIn, s.Custom_LinkedIn, a.Custom_LinkedIn), 'https://', ''), 'http://', '') AS [@URL]
				WHERE COALESCE(pas.Custom_LinkedIn, p.Custom_LinkedIn, s.Custom_LinkedIn, a.Custom_LinkedIn) IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Facebook' AS [@NM],
				'https://' AS [@PROTOCOL],
				'E' AS [@LANG],
				REPLACE(REPLACE(COALESCE(pas.Custom_Facebook, p.Custom_Facebook, s.Custom_Facebook, a.Custom_Facebook), 'https://', ''), 'http://', '') AS [@URL]
				WHERE COALESCE(pas.Custom_Facebook, p.Custom_Facebook, s.Custom_Facebook, a.Custom_Facebook) IS NOT NULL
			FOR XML PATH('TYPE'), TYPE
			)
		FOR XML PATH('SOCIAL_MEDIA'), TYPE),
		(SELECT TOP(1)
			i.LastVerifiedByName [@NM],
			i.LastVerifiedByTitle [@TTL],
			i.LastVerifiedByPhoneNumber [@PHN],
			i.LastVerifiedByEmailAddress [@EML]
		FROM (
			VALUES 
				(0, pas.LastVerifiedByName, pas.LastVerifiedByTitle, pas.LastVerifiedByPhoneNumber, pas.LastVerifiedByEmailAddress),
				(1, p.LastVerifiedByName, p.LastVerifiedByTitle, p.LastVerifiedByPhoneNumber, p.LastVerifiedByEmailAddress)
		) AS i(o, LastVerifiedByName, LastVerifiedByTitle, LastVerifiedByPhoneNumber, LastVerifiedbyEmailAddress)
		WHERE i.LastVerifiedByName IS NOT NULL OR i.LastVerifiedByTitle IS NOT NULL OR i.LastVerifiedByPhoneNumber IS NOT NULL OR i.LastVerifiedByEmailAddress IS NOT NULL
		ORDER BY i.o
		FOR XML PATH('SOURCE'), TYPE),
		(SELECT 
			(SELECT
				(SELECT i.ItemID AS [@V]
				FROM dbo.fn_GBL_ParseVarCharIDList(l.ItemId, '*') i
				FOR XML PATH('TM'), TYPE)
			FROM dbo.fn_GBL_ParseVarCharIDList(COALESCE(pas.TaxonomyCodes, p.TaxonomyCodes, s.TaxonomyCodes, a.TaxonomyCodes), ';') l
			FOR XML PATH('LNK'), TYPE)
		FOR XML PATH('TAXONOMY'), TYPE),
		(SELECT CASE WHEN COALESCE(pas.PhoneTTY, p.PhoneTTY, s.PhoneTTY, a.PhoneTTY)  IS NOT NULL AND COALESCE(pas.PhoneTTYDescription, p.PhoneTTYDescription, s.PhoneTTYDescription, a.PhoneTTYDescription)  IS NOT NULL THEN COALESCE(pas.PhoneTTYDescription, p.PhoneTTYDescription, s.PhoneTTYDescription, a.PhoneTTYDescription) + ': ' ELSE '' END + COALESCE(pas.PhoneTTY, p.PhoneTTY, s.PhoneTTY, a.PhoneTTY) AS [@V] FOR XML PATH('TDD_PHONE'), TYPE),
		(SELECT CASE WHEN COALESCE(pas.PhoneTollFree, p.PhoneTollFree, s.PhoneTollFree, a.PhoneTollFree)  IS NOT NULL AND COALESCE(pas.PhoneTollFreeDescription, p.PhoneTollFreeDescription, s.PhoneTollFreeDescription, a.PhoneTollFreeDescription)  IS NOT NULL THEN COALESCE(pas.PhoneTollFreeDescription, p.PhoneTollFreeDescription, s.PhoneTollFreeDescription, a.PhoneTollFreeDescription) + ': ' ELSE '' END + COALESCE(pas.PhoneTollFree, p.PhoneTollFree, s.PhoneTollFree, a.PhoneTollFree) AS [@V] FOR XML PATH('TOLL_FREE_PHONE'), TYPE),
		(SELECT REPLACE(COALESCE(pas.LastVerifiedOn, p.LastVerifiedOn), ' ', 'T') AS [@V] FOR XML PATH('UPDATE_DATE'), TYPE),
		(SELECT COALESCE(pas.LastVerificationApprovedBy, p.LastVerificationApprovedBy) AS [@V] FOR XML PATH('UPDATED_BY'), TYPE),
		(SELECT REPLACE(REPLACE(COALESCE(pas.WebsiteAddress, p.WebsiteAddress, s.WebsiteAddress, a.WebsiteAddress), 'https://', ''), 'http://', '') AS [@V] FOR XML PATH('WWW_ADDRESS'), TYPE)

	FROM dbo.CIC_iCarolImport pas
	INNER JOIN @updated AS u
		ON u.ResourceAgencyNum = pas.ResourceAgencyNum AND u.TaxonomyLevelName=pas.TaxonomyLevelName
	INNER JOIN dbo.GBL_BaseTable bt ON
		bt.EXTERNAL_ID=pas.ResourceAgencyNum
	LEFT JOIN dbo.CIC_iCarolImport p
		ON p.ResourceAgencyNum=pas.ConnectsToProgramNum AND p.TaxonomyLevelName='Program' AND p.LangID=@@LANGID
	LEFT JOIN dbo.CIC_iCarolImport s
		ON s.ResourceAgencyNum=pas.ConnectsToSiteNum AND s.TaxonomyLevelName='Site' AND s.langid=@@LANGID
	LEFT JOIN dbo.CIC_iCarolImport a
		ON pas.ParentAgencyNum=a.ResourceAgencyNum AND a.TaxonomyLevelName='Agency' AND a.LangID=@@LANGID
	WHERE pas.langid=@@LANGID AND pas.TaxonomyLevelName='ProgramAtSite' AND bt.MemberID=m.MemberID
	FOR XML PATH('RECORD'), TYPE
)
	FOR XML PATH('')
) AS records
FROM dbo.STP_Member m

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_iCarolImport_CreateSharing] TO [cioc_login_role]
GO
