SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CIC_iCarolImport_CreateSharing]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON


/*
	Checked for Release: 3.7.4
	Checked by: CL
	Checked on: 18-Jan-2020
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		INT
SET @Error = 0


SELECT (
	SELECT
	 'iCarol' AS [@NM],
	'iCarol' AS [@NMF],
	'https://yada.com' AS [@URL]
	FOR XML PATH('SOURCE_DB'), TYPE
),
(
	-- Agency
	SELECT TOP 1
	 COALESCE(a.ResourceAgencyNum, '') AS [@NUM],
		1 AS [@HAS_ENGLISH],
		(SELECT CASE WHEN a.PhoneNumberAfterHours IS NOT NULL AND a.PhoneNumberAfterHoursDescription  IS NOT NULL THEN a.PhoneNumberAfterHoursDescription + ': ' ELSE '' END + COALESCE(a.PhoneNumberAfterHours, '') AS [@V] FOR XML PATH('AFTER_HRS_PHONE'), TYPE), 
		(SELECT COALESCE(a.InternalNotes, '') AS [@V] FOR XML PATH('COMMENTS'), TYPE),
		(SELECT 'E' AS [@LANG], COALESCE(a.MainContactName, '') AS [@NM], COALESCE(a.MainContactTitle, '') AS [@TTL], COALESCE(a.MainContactPhoneNumber, '') AS [@PH1NO], COALESCE(a.MainContactEmailAddress, '') AS [@EML]
		-- NOTE a.MainContactType didn't have any data in it so it was not mapped
		FOR XML PATH('EXEC_1'),TYPE),
		(SELECT COALESCE(a.EmailAddressMain, '') AS [@V] FOR XML PATH('E_MAIL'), TYPE),
		(SELECT 'E' AS [@LANG], COALESCE(a.SeniorWorkerName, '') AS [@NM], COALESCE(a.SeniorWorkerTitle, '') AS [@TTL], COALESCE(a.SeniorWorkerPhoneNumber, '') AS [@PH1NO], COALESCE(a.SeniorWorkerEmailAddress, '') AS [@EML]
		FOR XML PATH('EXEC_1'),TYPE),
		  /* This doesn't seem to have useful data in it
		(SELECT
			'SEARCHHINTS' AS [@FLD],
			SearchHints AS [@V]
		 FOR XML PATH('EXTRA'), TYPE),
		 */
		(SELECT COALESCE(a.PhoneFax, '') AS [@V] FOR XML PATH('FAX'), TYPE),
		(SELECT
			 CASE WHEN a.Latitude IS NOT NULL AND a.Longitude IS NOT NULL THEN 3 ELSE 0 END AS [@TYPE],
			 COALESCE(a.Latitude, '') AS [@LAT],
			 COALESCE(a.Longitude, '') AS [@LONG]
		  FOR XML PATH('GEOCODE'), TYPE),
		(SELECT a.Hours + (CASE WHEN a.Hours  IS NOT NULL AND a.HoursOfOperation  IS NOT NULL THEN '; ' ELSE '' END) + COALESCE(a.HoursOfOperation, '') AS [@V] FOR XML PATH('HOURS'), TYPE),
		(SELECT 
			 COALESCE(a.MailingAttentionName, '') AS [@CO],
			 COALESCE(a.MailingAddress1, '') AS [@LN1],
			 COALESCE(a.MailingAddress2, '') AS [@LN2],
			 COALESCE(a.MailingCity, '') AS [@CTY],
			 COALESCE(a.MailingStateProvince, '') AS [@PRV],
			 COALESCE(a.MailingPostalCode, '') AS [@PC],
			 COALESCE(a.MailingCountry, '') AS [@CTRY]
			FOR XML PATH('MAIL_ADDRESS'), TYPE
		),
		(SELECT COALESCE(a.[Custom_Legal Name], a.[OfficialName], '') AS [@V] FOR XML PATH('LEGAL_ORG'), TYPE),
		(SELECT CASE WHEN a.PhoneNumberBusinessLine  IS NOT NULL AND a.PhoneNumberBusinessLineDescription  IS NOT NULL THEN a.PhoneNumberBusinessLineDescription + ': ' ELSE '' END + COALESCE(a.PhoneNumberBusinessLine, '') AS [@V] FOR XML PATH('OFFICE_PHONE'), TYPE),
		(SELECT COALESCE(a.AgencyDescription, '') AS [@V] FOR XML PATH('ORG_DESCRIPTION'), TYPE),
		(SELECT COALESCE(a.PublicName, '') AS [@V] FOR XML PATH('ORG_LEVEL_1'), TYPE),
		(SELECT 'AGENCY' AS [@V] FOR XML PATH('CD'), ROOT('ORG_LOCATION_SERVICE'), TYPE),
		(SELECT a.[Custom_Public Comments] AS [@V] FOR XML PATH('PUBLIC_COMMENTS'), TYPE),
		(SELECT 
			 COALESCE(a.PhysicalAddress1, '') AS [@LN1],
			 COALESCE(a.PhysicalAddress2, '') AS [@LN2],
			 COALESCE(a.PhysicalCity, '') AS [@CTY],
			 COALESCE(a.PhysicalStateProvince, '') AS [@PRV],
			 COALESCE(a.PhysicalPostalCode, '') AS [@PC],
			 COALESCE(a.PhysicalCountry, '') AS [@CTRY]
			FOR XML PATH('SITE_ADDRESS'), TYPE
		),
		(SELECT
			(SELECT 'Twitter' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(a.Custom_Twitter, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Instagram' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(a.Custom_Instagram, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'YouTube' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(a.Custom_YouTube, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'LinkedIn' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(a.Custom_LinkedIn, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Facebook' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(a.Custom_Facebook, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			)
		FOR XML PATH('SOCIAL_MEDIA'), TYPE),
		(SELECT CASE WHEN a.PhoneTTY  IS NOT NULL AND a.PhoneTTYDescription  IS NOT NULL THEN a.PhoneTTYDescription + ': ' ELSE '' END + COALESCE(a.PhoneTTY, '') AS [@V] FOR XML PATH('TDD_PHONE'), TYPE),
		(SELECT CASE WHEN a.PhoneTollFree  IS NOT NULL AND a.PhoneTollFreeDescription  IS NOT NULL THEN a.PhoneTollFreeDescription + ': ' ELSE '' END + COALESCE(a.PhoneTollFree, '') AS [@V] FOR XML PATH('TOLL_FREE_PHONE'), TYPE),
		(SELECT COALESCE(a.WebsiteAddress, '') AS [@V] FOR XML PATH('WWW_ADDRESS'), TYPE)

	FROM dbo.CIC_iCarolImport AS a
	WHERE a.service=0 AND a.langid=0 AND TaxonomyLevelName='Agency'
	FOR XML PATH('RECORD'), TYPE
), 
(
	-- Site
	SELECT TOP 10
		s.ResourceAgencyNum AS [@NUM],
		1 AS [@HAS_ENGLISH],
		(SELECT CASE WHEN COALESCE(s.PhoneNumberAfterHours, a.PhoneNumberAfterHours)  IS NOT NULL AND COALESCE(s.PhoneNumberAfterHoursDescription, a.PhoneNumberAfterHoursDescription)  IS NOT NULL THEN COALESCE(s.PhoneNumberAfterHoursDescription, a.PhoneNumberAfterHoursDescription) + ': ' ELSE '' END + COALESCE(s.PhoneNumberAfterHours, a.PhoneNumberAfterHours, '') AS [@V] FOR XML PATH('AFTER_HRS_PHONE'), TYPE), 
		(SELECT COALESCE(s.InternalNotes, a.InternalNotes, '') AS [@V] FOR XML PATH('COMMENTS'), TYPE),
		(SELECT 'E' AS [@LANG], COALESCE(s.MainContactName, a.MainContactName, '') AS [@NM], COALESCE(s.MainContactTitle, a.MainContactTitle, '') AS [@TTL], COALESCE(s.MainContactPhoneNumber, a.MainContactPhoneNumber, '') AS [@PH1NO], COALESCE(s.MainContactEmailAddress, a.MainContactEmailAddress, '') AS [@EML]
		-- NOTE COALESCE(s.MainContactType, a.MainContactType) didn't have any data in it so it was not mapped
		FOR XML PATH('EXEC_1'),TYPE),
		(SELECT COALESCE(s.EmailAddressMain, a.EmailAddressMain, '') AS [@V] FOR XML PATH('E_MAIL'), TYPE),
		(SELECT 'E' AS [@LANG], COALESCE(s.SeniorWorkerName, a.SeniorWorkerName, '') AS [@NM], COALESCE(s.SeniorWorkerTitle, a.SeniorWorkerTitle, '') AS [@TTL], COALESCE(s.SeniorWorkerPhoneNumber, a.SeniorWorkerPhoneNumber, '') AS [@PH1NO], COALESCE(s.SeniorWorkerEmailAddress, a.SeniorWorkerEmailAddress, '') AS [@EML]
		FOR XML PATH('EXEC_1'),TYPE),
		  /* This doesn't seem to have useful data in it
		(SELECT
			'SEARCHHINTS' AS [@FLD],
			SearchHints AS [@V]
		 FOR XML PATH('EXTRA'), TYPE),
		 */
		(SELECT COALESCE(s.PhoneFax, a.PhoneFax, '') AS [@V] FOR XML PATH('FAX'), TYPE),
		(SELECT
			 CASE WHEN COALESCE(s.Latitude, a.Latitude) IS NOT NULL AND COALESCE(s.Longitude, a.Longitude) IS NOT NULL THEN 3 ELSE 0 END AS [@TYPE],
			 COALESCE(s.Latitude, a.Latitude, '') AS [@LAT],
			 COALESCE(s.Longitude, a.Longitude, '') AS [@LONG]
		  FOR XML PATH('GEOCODE'), TYPE),
		(SELECT COALESCE(s.Hours, a.Hours) + (CASE WHEN COALESCE(s.Hours, a.Hours)  IS NOT NULL AND COALESCE(s.HoursOfOperation, a.HoursOfOperation)  IS NOT NULL THEN '; ' ELSE '' END) + COALESCE(s.HoursOfOperation, a.HoursOfOperation, '') AS [@V] FOR XML PATH('HOURS'), TYPE),
		(SELECT 
				COALESCE(s.MailingAttentionName, a.MailingAttentionName, '') AS [@CO],
				COALESCE(s.MailingAddress1, a.MailingAddress1, '') AS [@LN1],
				COALESCE(s.MailingAddress2, a.MailingAddress2, '') AS [@LN2],
				COALESCE(s.MailingCity, a.MailingCity, '') AS [@CTY],
				COALESCE(s.MailingStateProvince, a.MailingStateProvince, '') AS [@PRV],
				COALESCE(s.MailingPostalCode, a.MailingPostalCode, '') AS [@PC],
				COALESCE(s.MailingCountry, a.MailingCountry, '') AS [@CTRY]
			FOR XML PATH('MAIL_ADDRESS'), TYPE
		),
		(SELECT COALESCE(s.HoursOfOperation, a.HoursOfOperation, '') AS [@V] FOR XML PATH('HOURS'), TYPE),
		(SELECT COALESCE(s.[Custom_Legal Name], a.[Custom_Legal Name], '') AS [@V] FOR XML PATH('LEGAL_ORG'), TYPE),
		(SELECT COALESCE(s.AgencyDescription, '') AS [@V] FOR XML PATH('LOCATION_DESCRIPTION'), TYPE),
		(SELECT COALESCE(s.PublicName, '') AS [@V] FOR XML PATH('LOCATION_NAME'), TYPE),
		(SELECT CASE WHEN COALESCE(s.PhoneNumberBusinessLine, a.PhoneNumberBusinessLine)  IS NOT NULL AND COALESCE(s.PhoneNumberBusinessLineDescription, a.PhoneNumberBusinessLineDescription)  IS NOT NULL THEN COALESCE(s.PhoneNumberBusinessLineDescription, a.PhoneNumberBusinessLineDescription) + ': ' ELSE '' END + COALESCE(s.PhoneNumberBusinessLine, a.PhoneNumberBusinessLine, '') AS [@V] FOR XML PATH('OFFICE_PHONE'), TYPE),
		(SELECT COALESCE(a.AgencyDescription, '') AS [@V] FOR XML PATH('ORG_DESCRIPTION'), TYPE),
		(SELECT  COALESCE(a.PublicName, '') AS [@V] FOR XML PATH('ORG_LEVEL_1'), TYPE),
		(SELECT 'SITE' AS [@V] FOR XML PATH('CD'), ROOT('ORG_LOCATION_SERVICE'), TYPE),
		(SELECT COALESCE(s.[Custom_Public Comments], a.[Custom_Public Comments], '') AS [@V] FOR XML PATH('PUBLIC_COMMENTS'), TYPE),
		(SELECT 
				COALESCE(s.PhysicalAddress1, a.PhysicalAddress1, '') AS [@LN1],
				COALESCE(s.PhysicalAddress2, a.PhysicalAddress2, '') AS [@LN2],
				COALESCE(s.PhysicalCity, a.PhysicalCity, '') AS [@CTY],
				COALESCE(s.PhysicalStateProvince, a.PhysicalStateProvince, '') AS [@PRV],
				COALESCE(s.PhysicalPostalCode, a.PhysicalPostalCode, '') AS [@PC],
				COALESCE(s.PhysicalCountry, a.PhysicalCountry, '') AS [@CTRY]
			FOR XML PATH('SITE_ADDRESS'), TYPE
		),
		(SELECT
			(SELECT 'Twitter' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(s.Custom_Twitter, a.Custom_Twitter, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Instagram' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(s.Custom_Instagram, a.Custom_Instagram, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'YouTube' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(s.Custom_YouTube, a.Custom_YouTube, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'LinkedIn' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(s.Custom_LinkedIn, a.Custom_LinkedIn, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Facebook' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(s.Custom_Facebook, a.Custom_Facebook, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			)
		FOR XML PATH('SOCIAL_MEDIA'), TYPE),
		(SELECT CASE WHEN COALESCE(s.PhoneTTY, a.PhoneTTY)  IS NOT NULL AND COALESCE(s.PhoneTTYDescription, a.PhoneTTYDescription)  IS NOT NULL THEN COALESCE(s.PhoneTTYDescription, a.PhoneTTYDescription) + ': ' ELSE '' END + COALESCE(s.PhoneTTY, a.PhoneTTY, '') AS [@V] FOR XML PATH('TDD_PHONE'), TYPE),
		(SELECT CASE WHEN COALESCE(s.PhoneTollFree, a.PhoneTollFree)  IS NOT NULL AND COALESCE(s.PhoneTollFreeDescription, a.PhoneTollFreeDescription)  IS NOT NULL THEN COALESCE(s.PhoneTollFreeDescription, a.PhoneTollFreeDescription) + ': ' ELSE '' END + COALESCE(s.PhoneTollFree, a.PhoneTollFree, '') AS [@V] FOR XML PATH('TOLL_FREE_PHONE'), TYPE),
		(SELECT COALESCE(s.WebsiteAddress, a.WebsiteAddress, '') AS [@V] FOR XML PATH('WWW_ADDRESS'), TYPE)

	FROM dbo.CIC_iCarolImport s
	LEFT JOIN dbo.CIC_iCarolImport a
		ON s.ParentAgencyNum=a.ResourceAgencyNum AND a.TaxonomyLevelName='Agency' AND a.LangID=0
	WHERE s.service=0 AND s.langid=0 AND s.TaxonomyLevelName='Site'
	FOR XML PATH('RECORD'), TYPE
), 
(
	-- ProgramAtSite
	SELECT TOP 100
		pas.ResourceAgencyNum AS [@NUM],
		1 AS [@HAS_ENGLISH],
		(SELECT CASE WHEN COALESCE(pas.PhoneNumberAfterHours, p.PhoneNumberAfterHours, s.PhoneNumberAfterHours, a.PhoneNumberAfterHours)  IS NOT NULL AND COALESCE(pas.PhoneNumberAfterHoursDescription, p.PhoneNumberAfterHoursDescription, s.PhoneNumberAfterHoursDescription, a.PhoneNumberAfterHoursDescription)  IS NOT NULL THEN COALESCE(pas.PhoneNumberAfterHoursDescription, p.PhoneNumberAfterHoursDescription, s.PhoneNumberAfterHoursDescription, a.PhoneNumberAfterHoursDescription) + ': ' ELSE '' END + COALESCE(pas.PhoneNumberAfterHours, p.PhoneNumberAfterHours, s.PhoneNumberAfterHours, a.PhoneNumberAfterHours, '') AS [@V] FOR XML PATH('AFTER_HRS_PHONE'), TYPE), 
		(SELECT COALESCE(pas.InternalNotes, p.InternalNotes, s.InternalNotes, a.InternalNotes, '') AS [@V] FOR XML PATH('COMMENTS'), TYPE),
		(SELECT COALESCE(pas.AgencyDescription, p.AgencyDescription, '') AS [@V] FOR XML PATH('DESCRIPTION'), TYPE),
		(SELECT 'E' AS [@LANG], COALESCE(pas.MainContactName, p.MainContactName, s.MainContactName, a.MainContactName, '') AS [@NM], COALESCE(pas.MainContactTitle, p.MainContactTitle, s.MainContactTitle, a.MainContactTitle, '') AS [@TTL], COALESCE(pas.MainContactPhoneNumber, p.MainContactPhoneNumber, s.MainContactPhoneNumber, a.MainContactPhoneNumber, '') AS [@PH1NO], COALESCE(pas.MainContactEmailAddress, p.MainContactEmailAddress, s.MainContactEmailAddress, a.MainContactEmailAddress, '') AS [@EML]
		-- NOTE COALESCE(pas.MainContactType, p.MainContactType, s.MainContactType, a.MainContactType) didn't have any data in it so it was not mapped
		FOR XML PATH('EXEC_1'),TYPE),
		(SELECT COALESCE(pas.EmailAddressMain, p.EmailAddressMain, s.EmailAddressMain, a.EmailAddressMain, '') AS [@V] FOR XML PATH('E_MAIL'), TYPE),
		(SELECT 'E' AS [@LANG], COALESCE(pas.SeniorWorkerName, p.SeniorWorkerName, s.SeniorWorkerName, a.SeniorWorkerName, '') AS [@NM], COALESCE(pas.SeniorWorkerTitle, p.SeniorWorkerTitle, s.SeniorWorkerTitle, a.SeniorWorkerTitle, '') AS [@TTL], COALESCE(pas.SeniorWorkerPhoneNumber, p.SeniorWorkerPhoneNumber, s.SeniorWorkerPhoneNumber, a.SeniorWorkerPhoneNumber, '') AS [@PH1NO], COALESCE(pas.SeniorWorkerEmailAddress, p.SeniorWorkerEmailAddress, s.SeniorWorkerEmailAddress, a.SeniorWorkerEmailAddress, '') AS [@EML]
		FOR XML PATH('EXEC_1'),TYPE),
		  /* This doesn't seem to have useful data in it
		(SELECT
			'SEARCHHINTS' AS [@FLD],
			SearchHints AS [@V]
		 FOR XML PATH('EXTRA'), TYPE),
		 */
		(SELECT COALESCE(pas.PhoneFax, p.PhoneFax, s.PhoneFax, a.PhoneFax, '') AS [@V] FOR XML PATH('FAX'), TYPE),
		(SELECT
			 CASE WHEN COALESCE(pas.Latitude, p.Latitude, s.Latitude, a.Latitude) IS NOT NULL AND COALESCE(pas.Longitude, p.Longitude, s.Longitude, a.Longitude) IS NOT NULL THEN 3 ELSE 0 END AS [@TYPE],
			 COALESCE(pas.Latitude, p.Latitude, s.Latitude, a.Latitude, '') AS [@LAT],
			 COALESCE(pas.Longitude, p.Longitude, s.Longitude, a.Longitude, '') AS [@LONG]
		  FOR XML PATH('GEOCODE'), TYPE),
		(SELECT COALESCE(pas.Hours, p.Hours, s.Hours, a.Hours) + (CASE WHEN COALESCE(pas.Hours, p.Hours, s.Hours, a.Hours)  IS NOT NULL AND COALESCE(pas.HoursOfOperation, p.HoursOfOperation, s.HoursOfOperation, a.HoursOfOperation)  IS NOT NULL THEN '; ' ELSE '' END) + COALESCE(pas.HoursOfOperation, p.HoursOfOperation, s.HoursOfOperation, a.HoursOfOperation, '') AS [@V] FOR XML PATH('HOURS'), TYPE),
		(SELECT 
				COALESCE(pas.MailingAttentionName, p.MailingAttentionName, s.MailingAttentionName, a.MailingAttentionName, '') AS [@CO],
				COALESCE(pas.MailingAddress1, p.MailingAddress1, s.MailingAddress1, a.MailingAddress1, '') AS [@LN1],
				COALESCE(pas.MailingAddress2, p.MailingAddress2, s.MailingAddress2, a.MailingAddress2, '') AS [@LN2],
				COALESCE(pas.MailingCity, p.MailingCity, s.MailingCity, a.MailingCity, '') AS [@CTY],
				COALESCE(pas.MailingStateProvince, p.MailingStateProvince, s.MailingStateProvince, a.MailingStateProvince, '') AS [@PRV],
				COALESCE(pas.MailingPostalCode, p.MailingPostalCode, s.MailingPostalCode, a.MailingPostalCode, '') AS [@PC],
				COALESCE(pas.MailingCountry, p.MailingCountry, s.MailingCountry, a.MailingCountry, '') AS [@CTRY]
			FOR XML PATH('MAIL_ADDRESS'), TYPE
		),
		(SELECT COALESCE(pas.HoursOfOperation, p.HoursOfOperation, s.HoursOfOperation, a.HoursOfOperation, '') AS [@V] FOR XML PATH('HOURS'), TYPE),
		(SELECT COALESCE(pas.[Custom_Legal Name], p.[Custom_Legal Name], s.[Custom_Legal Name], a.[Custom_Legal Name], '') AS [@V] FOR XML PATH('LEGAL_ORG'), TYPE),
		(SELECT COALESCE(s.AgencyDescription, '') AS [@V] FOR XML PATH('LOCATION_DESCRIPTION'), TYPE),
		(SELECT COALESCE(pas.PublicName, p.PublicName, s.PublicName, '') AS [@V] FOR XML PATH('LOCATION_NAME'), TYPE),
		(SELECT CASE WHEN COALESCE(pas.PhoneNumberBusinessLine, p.PhoneNumberBusinessLine, s.PhoneNumberBusinessLine, a.PhoneNumberBusinessLine)  IS NOT NULL AND COALESCE(pas.PhoneNumberBusinessLineDescription, p.PhoneNumberBusinessLineDescription, s.PhoneNumberBusinessLineDescription, a.PhoneNumberBusinessLineDescription)  IS NOT NULL THEN COALESCE(pas.PhoneNumberBusinessLineDescription, p.PhoneNumberBusinessLineDescription, s.PhoneNumberBusinessLineDescription, a.PhoneNumberBusinessLineDescription) + ': ' ELSE '' END + COALESCE(pas.PhoneNumberBusinessLine, p.PhoneNumberBusinessLine, s.PhoneNumberBusinessLine, a.PhoneNumberBusinessLine, '') AS [@V] FOR XML PATH('OFFICE_PHONE'), TYPE),
		(SELECT COALESCE(a.AgencyDescription, '') AS [@V] FOR XML PATH('ORG_DESCRIPTION'), TYPE),
		(SELECT  COALESCE(a.PublicName, '') AS [@V] FOR XML PATH('ORG_LEVEL_1'), TYPE),
		(SELECT 'SERVICE' AS [@V] FOR XML PATH('CD'), ROOT('ORG_LOCATION_SERVICE'), TYPE),
		(SELECT COALESCE(pas.[Custom_Public Comments], p.[Custom_Public Comments], s.[Custom_Public Comments], a.[Custom_Public Comments], '') AS [@V] FOR XML PATH('PUBLIC_COMMENTS'), TYPE),
		(SELECT COALESCE(s.PublicName, '') AS [@V] FOR XML PATH('SERVICE_NAME_LEVEL_1'), TYPE),
		(SELECT COALESCE(pas.PublicName, p.PublicName, '') AS [@V] FOR XML PATH('SERVICE_NAME_LEVEL_2'), TYPE),
		(SELECT 
				COALESCE(pas.PhysicalAddress1, p.PhysicalAddress1, s.PhysicalAddress1, a.PhysicalAddress1, '') AS [@LN1],
				COALESCE(pas.PhysicalAddress2, p.PhysicalAddress2, s.PhysicalAddress2, a.PhysicalAddress2, '') AS [@LN2],
				COALESCE(pas.PhysicalCity, p.PhysicalCity, s.PhysicalCity, a.PhysicalCity, '') AS [@CTY],
				COALESCE(pas.PhysicalStateProvince, p.PhysicalStateProvince, s.PhysicalStateProvince, a.PhysicalStateProvince, '') AS [@PRV],
				COALESCE(pas.PhysicalPostalCode, p.PhysicalPostalCode, s.PhysicalPostalCode, a.PhysicalPostalCode, '') AS [@PC],
				COALESCE(pas.PhysicalCountry, p.PhysicalCountry, s.PhysicalCountry, a.PhysicalCountry, '') AS [@CTRY]
			FOR XML PATH('SITE_ADDRESS'), TYPE
		),
		(SELECT
			(SELECT 'Twitter' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(pas.Custom_Twitter, p.Custom_Twitter, s.Custom_Twitter, a.Custom_Twitter, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Instagram' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(pas.Custom_Instagram, p.Custom_Instagram, s.Custom_Instagram, a.Custom_Instagram, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'YouTube' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(pas.Custom_YouTube, p.Custom_YouTube, s.Custom_YouTube, a.Custom_YouTube, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'LinkedIn' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(pas.Custom_LinkedIn, p.Custom_LinkedIn, s.Custom_LinkedIn, a.Custom_LinkedIn, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			),
			(SELECT 'Facebook' AS [@NM],
				'https://' AS [@PROTOCOL],
				REPLACE(REPLACE(COALESCE(pas.Custom_Facebook, p.Custom_Facebook, s.Custom_Facebook, a.Custom_Facebook, ''), 'https://', ''), 'http://', '') AS [@URL]
			FOR XML PATH('TYPE'), TYPE
			)
		FOR XML PATH('SOCIAL_MEDIA'), TYPE),
		(SELECT CASE WHEN COALESCE(pas.PhoneTTY, p.PhoneTTY, s.PhoneTTY, a.PhoneTTY)  IS NOT NULL AND COALESCE(pas.PhoneTTYDescription, p.PhoneTTYDescription, s.PhoneTTYDescription, a.PhoneTTYDescription)  IS NOT NULL THEN COALESCE(pas.PhoneTTYDescription, p.PhoneTTYDescription, s.PhoneTTYDescription, a.PhoneTTYDescription) + ': ' ELSE '' END + COALESCE(pas.PhoneTTY, p.PhoneTTY, s.PhoneTTY, a.PhoneTTY, '') AS [@V] FOR XML PATH('TDD_PHONE'), TYPE),
		(SELECT CASE WHEN COALESCE(pas.PhoneTollFree, p.PhoneTollFree, s.PhoneTollFree, a.PhoneTollFree)  IS NOT NULL AND COALESCE(pas.PhoneTollFreeDescription, p.PhoneTollFreeDescription, s.PhoneTollFreeDescription, a.PhoneTollFreeDescription)  IS NOT NULL THEN COALESCE(pas.PhoneTollFreeDescription, p.PhoneTollFreeDescription, s.PhoneTollFreeDescription, a.PhoneTollFreeDescription) + ': ' ELSE '' END + COALESCE(pas.PhoneTollFree, p.PhoneTollFree, s.PhoneTollFree, a.PhoneTollFree, '') AS [@V] FOR XML PATH('TOLL_FREE_PHONE'), TYPE),
		(SELECT COALESCE(pas.WebsiteAddress, p.WebsiteAddress, s.WebsiteAddress, a.WebsiteAddress, '') AS [@V] FOR XML PATH('WWW_ADDRESS'), TYPE)

	FROM dbo.CIC_iCarolImport pas
	LEFT JOIN dbo.CIC_iCarolImport p
		ON p.ResourceAgencyNum=pas.ConnectsToProgramNum AND p.TaxonomyLevelName='Program' AND p.LangID=0
	LEFT JOIN dbo.CIC_iCarolImport s
		ON s.ResourceAgencyNum=pas.ConnectsToSiteNum AND s.TaxonomyLevelName='Site' AND s.langid=0
	LEFT JOIN dbo.CIC_iCarolImport a
		ON pas.ParentAgencyNum=a.ResourceAgencyNum AND a.TaxonomyLevelName='Agency' AND a.LangID=0
	WHERE pas.service=0 AND pas.langid=0 AND pas.TaxonomyLevelName='ProgramAtSite'
	FOR XML PATH('RECORD'), TYPE
)
 FOR XML PATH(''), ROOT('ROOT')

RETURN @Error

SET NOCOUNT OFF

GO
