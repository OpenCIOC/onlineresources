
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_AIRS_Export_3_0] (
	@ViewType [int],
	@LangID [smallint],
	@DistCode [varchar](20),
	@PubCodeSynch [bit],
	@PartialDate [datetime],
	@IncludeDeleted [bit],
	@AutoIncludeSiteAgency [bit],
	@AgencyNUM [varchar](8) = NULL,
	@LabelLangOverride smallint = 0
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 15-Apr-2015
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@CanSeeDeleted bit,
		@HidePastDueBy int,
		@PB_ID int
		
SELECT	@MemberID = MemberID,
		@CanSeeNonPublic = CanSeeNonPublic,
		@CanSeeDeleted = CASE WHEN CanSeeDeleted=0 OR @IncludeDeleted=0 THEN 0 ELSE 1 END,
		@HidePastDueBy = HidePastDueBy,
		@PB_ID=PB_ID
FROM CIC_View
WHERE ViewType=@ViewType

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
		WHERE excm.SystemCode='ONTARIO211'
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

DECLARE @DST_ID int
IF @DistCode IS NOT NULL BEGIN
	SELECT @DST_ID=DST_ID FROM CIC_Distribution WHERE DistCode=@DistCode
	SET @DST_ID=ISNULL(@DST_ID,-1)
END

IF @PubCodeSynch=1 BEGIN
	IF LEN(REPLACE((SELECT DistCode FROM CIC_Distribution WHERE DST_ID=@DST_ID),'AIRSEXPORT-','')) > 2 BEGIN
		MERGE INTO CIC_BT_DST dst
		USING (SELECT DISTINCT NUM
			FROM CIC_BT_PB pr
			INNER JOIN CIC_Publication pb
				ON pr.PB_ID=pb.PB_ID
			INNER JOIN CIC_Distribution d
				ON pb.PubCode LIKE REPLACE(d.DistCode,'AIRSEXPORT-','') + '%' AND d.DST_ID=@DST_ID) src
			ON dst.NUM=src.NUM AND dst.DST_ID=@DST_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (NUM, DST_ID) VALUES (src.NUM, @DST_ID)
		WHEN NOT MATCHED BY SOURCE AND dst.DST_ID=@DST_ID THEN
			DELETE
		;
	END
END

DECLARE @ADD_TO_BT_LOCATION_SERVICE table ( NUM varchar(8) PRIMARY KEY )
INSERT INTO @ADD_TO_BT_LOCATION_SERVICE
		(NUM)
SELECT bt.NUM
FROM GBL_BaseTable bt
WHERE ORG_NUM='ZZZ00001'
	AND EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code='TOPIC' WHERE pr.NUM=bt.NUM)
	AND NOT EXISTS(SELECT * FROM GBL_BT_LOCATION_SERVICE WHERE SERVICE_NUM=bt.NUM)

UPDATE dbo.GBL_BaseTable SET DISPLAY_LOCATION_NAME=0 WHERE DISPLAY_LOCATION_NAME=1 AND EXISTS(SELECT * FROM @ADD_TO_BT_LOCATION_SERVICE WHERE NUM=GBL_BaseTable.NUM)

INSERT INTO GBL_BT_LOCATION_SERVICE (LOCATION_NUM, SERVICE_NUM)
SELECT 'ZZZ00002', bt.NUM
FROM @ADD_TO_BT_LOCATION_SERVICE bt

DECLARE @nLine nvarchar(2),
		@nLine10 char(1)

SET @nLine = CHAR(13) + CHAR(10)
SET @nLine10 = CHAR(10)

SELECT
	(SELECT TOP 1 MemberNameCIC FROM STP_Member_Description WHERE MemberID=@MemberID ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID) AS "SourceEntity",
	CONVERT(varchar,GETDATE(),126) AS "OriginTimestamp",
	'CIOC' AS "SoftwareVendor",
	'3.6.2' AS "SoftwareVersion",
	(SELECT CONVERT(varchar,ReleaseDate,126) FROM tax_updater.dbo.MetaData WHERE Language='eng') AS "TaxonomyVersion",
	'3.0' AS "SchemaVersion"

SELECT (
SELECT
	-- RECORD OWNER
	bt.RECORD_OWNER + 'CIOC' AS "@RecordOwner",
	
	-- YEAR INC
	CASE WHEN btd.ESTABLISHED LIKE '[0-9][0-9][0-9][0-9]' THEN btd.ESTABLISHED ELSE NULL END AS "@YearInc",
	
	-- LEGAL STATUS
	dbo.fn_CIC_NUMToServiceLevel(bt.NUM,btd.LangID) AS "@LegalStatus",
	
	-- EXCLUDE FROM WEB / DIRECTORY
	CASE WHEN (btd.DELETION_DATE IS NOT NULL AND btd.DELETION_DATE <= GETDATE()) OR btd.NON_PUBLIC=1 THEN 'true' ELSE 'false' END AS "@ExcludeFromWebsite",
	CASE WHEN (btd.DELETION_DATE IS NOT NULL AND btd.DELETION_DATE <= GETDATE()) OR btd.NON_PUBLIC=1 THEN 'true' ELSE 'false' END AS "@ExcludeFromDirectory",
	
	-- KEY
	btd.NUM AS [Key],
	
	-- NAME
	STUFF(
			COALESCE(', ' + btd.ORG_LEVEL_1,'') +
			COALESCE(', ' + btd.ORG_LEVEL_2,'') +
			COALESCE(', ' + btd.ORG_LEVEL_3,'') +
			COALESCE(', ' + btd.ORG_LEVEL_4,'') +
			COALESCE(', ' + btd.ORG_LEVEL_5,''),
			1, 2, ''
		) AS Name,
	
	-- AGENCY DESCRIPTION
	ISNULL(ISNULL(
		CASE WHEN btd.ORG_DESCRIPTION LIKE '%<br>%' OR btd.DESCRIPTION LIKE '%<p>%' THEN btd.ORG_DESCRIPTION ELSE REPLACE(btd.ORG_DESCRIPTION,@nLine10,@nLine10 + '<br>') END,
		CASE WHEN btd.DESCRIPTION LIKE '%<br>%' OR btd.DESCRIPTION LIKE '%<p>%' THEN btd.DESCRIPTION ELSE REPLACE(btd.DESCRIPTION,@nLine10,@nLine10 + '<br>') END),
		'Agency') AS AgencyDescription,
	
	-- AKA NAMES
	(SELECT aka.Name, aka.Confidential, aka.Description FROM
		(SELECT
				ao.ALT_ORG AS Name,
				'false' AS Confidential,
				NULL AS Description
			FROM GBL_BT_ALTORG ao
			WHERE ao.NUM=bt.NUM AND ao.LangID=btd.LangID
		UNION SELECT
				fo.FORMER_ORG AS Name,
				'false' AS Confidential,
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Former Name',@LabelLangOverride) + ISNULL(cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',@LabelLangOverride) + fo.DATE_OF_CHANGE,'') AS Description
			FROM GBL_BT_FORMERORG fo
			WHERE fo.NUM=bt.NUM AND fo.LangID=btd.LangID
		UNION SELECT
				btd.LEGAL_ORG COLLATE Latin1_General_100_CS_AS AS Name,
				'false' AS Confidential,
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Legal Name',@LabelLangOverride) AS Description
			WHERE btd.LEGAL_ORG IS NOT NULL
		) aka
	FOR XML PATH('AKA'), TYPE),
	
	-- AGENCY LOCATION
	(SELECT
		
	-- AGENCY LOCATION > EXCLUDE FROM WEB / DIRECTORY
		CASE WHEN (btd.DELETION_DATE IS NOT NULL AND btd.DELETION_DATE <= GETDATE()) OR btd.NON_PUBLIC=1 THEN 'true' ELSE 'false' END AS "@ExcludeFromWebsite",
		CASE WHEN (btd.DELETION_DATE IS NOT NULL AND btd.DELETION_DATE <= GETDATE()) OR btd.NON_PUBLIC=1 THEN 'true' ELSE 'false' END AS "@ExcludeFromDirectory",
	
	-- AGENCY LOCATION > KEY
		btd.NUM AS [Key],
		STUFF(
			COALESCE(', ' + btd.ORG_LEVEL_1,'') +
			COALESCE(', ' + btd.ORG_LEVEL_2,'') +
			COALESCE(', ' + btd.ORG_LEVEL_3,'') +
			COALESCE(', ' + btd.ORG_LEVEL_4,'') +
			COALESCE(', ' + btd.ORG_LEVEL_5,''),
			1, 2, ''
		) AS Name,
	
	-- AGENCY LOCATION > SITE DESCRIPTION
		ISNULL(btd.LOCATION_DESCRIPTION,cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Agency Location',@LangID)) AS SiteDescription,
		
	-- AGENCY LOCATION > PHYSICAL ADDRESS
		(SELECT
				CASE WHEN EXISTS(SELECT *
					FROM GBL_PrivacyProfile_Fld pvf
					INNER JOIN GBL_FieldOption fo
						ON pvf.FieldID=fo.FieldID AND fo.FieldName='SITE_ADDRESS'
					WHERE pvf.ProfileID=bt.PRIVACY_PROFILE)
					THEN 'true' ELSE 'false' END AS "@Confidential",
				btd.SITE_BUILDING AS PreAddressLine,
				dbo.fn_GBL_FullAddress(NULL,NULL,NULL,btd.SITE_STREET_NUMBER,btd.SITE_STREET,btd.SITE_STREET_TYPE,btd.SITE_STREET_TYPE_AFTER,btd.SITE_STREET_DIR,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,btd.LangID,0) AS Line1,
				btd.SITE_SUFFIX AS Line2,
				COALESCE(
					(SELECT EXPORT_CITY FROM @SiteCityTable WHERE SITE_CITY=btd.SITE_CITY),
					btd.SITE_CITY,
					(SELECT AreaName
						FROM dbo.GBL_Community_External_Map cmap
						INNER JOIN dbo.GBL_Community_External_Community excm
							ON excm.EXT_ID = cmap.MapOneEXTID AND excm.SystemCode='ONTARIO211'
						WHERE cmap.CM_ID=bt.LOCATED_IN_CM),
					btd.MAIL_CITY,
					cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown')
					) AS City,
				ISNULL(btd.SITE_PROVINCE,(SELECT mem.DefaultProvince FROM STP_Member mem WHERE MemberID=@MemberID)) AS [State],
				bt.SITE_POSTAL_CODE AS ZipCode,
				ISNULL(btd.SITE_COUNTRY,ISNULL((SELECT mem.DefaultCountry FROM STP_Member mem WHERE MemberID=@MemberID),'Canada')) AS Country
			WHERE (btd.CMP_SiteAddress IS NOT NULL OR bt.LOCATED_IN_CM IS NOT NULL)
			FOR XML PATH('PhysicalAddress'),TYPE),
	
	-- AGENCY LOCATION > MAILING ADDRESS
		(SELECT
				CASE WHEN EXISTS(SELECT *
					FROM GBL_PrivacyProfile_Fld pvf
					INNER JOIN GBL_FieldOption fo
						ON pvf.FieldID=fo.FieldID AND fo.FieldName='MAIL_ADDRESS'
					WHERE pvf.ProfileID=bt.PRIVACY_PROFILE)
					THEN 'true' ELSE 'false' END AS "@Confidential",
				REPLACE(dbo.fn_GBL_FullAddress(NULL,NULL,btd.MAIL_BUILDING,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,btd.MAIL_CARE_OF,NULL,NULL,NULL,NULL,@LangID,0),@nLine,', ') AS PreAddressLine,
				REPLACE(dbo.fn_GBL_FullAddress(NULL,NULL,NULL,btd.MAIL_STREET_NUMBER,btd.MAIL_STREET,btd.MAIL_STREET_TYPE,btd.MAIL_STREET_TYPE_AFTER,btd.MAIL_STREET_DIR,NULL,NULL,NULL,NULL,NULL,NULL,btd.MAIL_BOX_TYPE,btd.MAIL_PO_BOX,NULL,NULL,@LangID,0),@nLine,', ') AS Line1,
				btd.MAIL_SUFFIX AS Line2,
				COALESCE(btd.MAIL_CITY,btd.SITE_CITY,cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Unknown',@LangID)) AS City,
				ISNULL(btd.MAIL_PROVINCE,(SELECT mem.DefaultProvince FROM STP_Member mem WHERE MemberID=@MemberID)) AS [State],
				bt.MAIL_POSTAL_CODE AS ZipCode,
				ISNULL(btd.MAIL_COUNTRY,ISNULL((SELECT mem.DefaultCountry FROM STP_Member mem WHERE MemberID=@MemberID),'Canada')) AS Country
			WHERE btd.CMP_MailAddress IS NOT NULL
			FOR XML PATH('MailingAddress'),TYPE),
	
	-- AGENCY LOCATION > NO ADDRESS
		(SELECT
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('None given',@LangID) AS Explanation
			WHERE btd.CMP_SiteAddress IS NULL AND btd.CMP_MailAddress IS NULL AND bt.LOCATED_IN_CM IS NULL
			FOR XML PATH('NoPhysicalAddress'),TYPE),

		cbtd.INTERSECTION AS CrossStreet,

	-- AGENCY LOCATION > LOCATED IN COMMUNITY
		(SELECT
			excm.AIRSExportType AS 'LocatedInCommunity/@Type',
			AreaName AS LocatedInCommunity
			FROM dbo.GBL_Community_External_Map cmap
			INNER JOIN dbo.GBL_Community_External_Community excm
				ON excm.EXT_ID = cmap.MapOneEXTID AND excm.SystemCode='ONTARIO211'
			WHERE cmap.CM_ID=bt.LOCATED_IN_CM
			FOR XML PATH(''),TYPE)
		
	FOR XML PATH('AgencyLocation'), TYPE
	),
	
	-- PHONE
	(SELECT phone.*
		FROM (
		SELECT 'false' AS "@TollFree",
				'false' AS "@Confidential",
				btd.OFFICE_PHONE AS PhoneNumber,
				NULL AS ReasonWithheld,
				'Office' AS [Description],
				'Voice' AS [Type]
			WHERE btd.OFFICE_PHONE IS NOT NULL
		UNION SELECT 'false' AS "@TollFree",
				'false' AS "@Confidential",
				cbtd.AFTER_HRS_PHONE AS PhoneNumber,
				NULL AS ReasonWithheld,
				'After Hours' AS [Description],
				'Voice' AS [Type]
			WHERE cbtd.AFTER_HRS_PHONE IS NOT NULL
		UNION SELECT 'false' AS "@TollFree",
				'false' AS "@Confidential",
				cbtd.CRISIS_PHONE AS PhoneNumber,
				NULL AS ReasonWithheld,
				'Crisis' AS [Description],
				'Voice' AS [Type]
			WHERE cbtd.CRISIS_PHONE IS NOT NULL
		UNION SELECT 'false' AS "@TollFree",
				'false' AS "@Confidential",
				btd.FAX AS PhoneNumber,
				NULL AS ReasonWithheld,
				'Fax' AS [Description],
				'Fax' AS [Type]
			WHERE btd.FAX IS NOT NULL
		UNION SELECT 'false' AS "@TollFree",
				'false' AS "@Confidential",
				cbtd.TDD_PHONE AS PhoneNumber,
				NULL AS ReasonWithheld,
				'TTY/TDD' AS [Description],
				'TTY/TDD' AS [Type]
			WHERE cbtd.TDD_PHONE IS NOT NULL
		UNION SELECT
				'true' AS "@TollFree",
				'false' AS "@Confidential",
				btd.TOLL_FREE_PHONE AS PhoneNumber,
				NULL AS ReasonWithheld,
				'Toll Free' AS [Description],
				'Voice' AS [Type]
			WHERE btd.TOLL_FREE_PHONE IS NOT NULL
		UNION SELECT
				'false' AS "@TollFree",
				'false' AS "@Confidential",
				NULL AS PhoneNumber,
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('None given',@LangID) AS ReasonWithheld,
				NULL AS [Description],
				NULL AS [Type]
			WHERE COALESCE(btd.OFFICE_PHONE,cbtd.AFTER_HRS_PHONE,cbtd.CRISIS_PHONE,btd.FAX,cbtd.TDD_PHONE,btd.TOLL_FREE_PHONE) IS NULL
		) phone
	FOR XML PATH('Phone'), TYPE),
	
	-- URL
	(SELECT btd.WWW_ADDRESS AS Address WHERE btd.WWW_ADDRESS IS NOT NULL FOR XML PATH('URL'), TYPE),
	
	-- EMAIL
	(SELECT LTRIM(ItemID) AS Address FROM dbo.fn_GBL_ParseVarCharIDList(btd.E_MAIL,',') FOR XML PATH('Email'), TYPE),
	
	-- CONTACT
	(SELECT
	-- CONTACT > TYPE
		(SELECT ISNULL(FieldDisplay,FieldName)
			FROM GBL_FieldOption fo
			LEFT JOIN GBL_FieldOption_Description fod
				ON fo.FieldID=fod.FieldID AND fod.LangID=@LabelLangOverride
			WHERE fo.FieldName=c.GblContactType) AS "@Type",
	
	-- CONTACT > TITLE
		c.TITLE AS Title,
		
	-- CONTACT > NAME
		c.CMP_Name AS Name,
		
	-- CONTACT > EMAIL
		(SELECT LTRIM(ItemID) AS Address FROM dbo.fn_GBL_ParseVarCharIDList(c.EMAIL,',') FOR XML PATH('Email'), TYPE),

	-- CONTACT > PHONE
		(SELECT 
				'false' AS "@TollFree",
				'false' AS "@Confidential",
				CASE WHEN c.PHONE_1_NOTE IS NULL AND c.PHONE_1_NO IS NULL AND c.PHONE_1_EXT IS NULL AND c.PHONE_1_OPTION IS NULL
					THEN NULL
					ELSE ISNULL(c.PHONE_1_NOTE,'')
						+ CASE WHEN c.PHONE_1_NO IS NULL THEN '' ELSE CASE WHEN c.PHONE_1_NOTE IS NULL THEN '' ELSE ' ' END + c.PHONE_1_NO END
						+ CASE WHEN c.PHONE_1_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_1_NOTE,c.PHONE_1_NO) IS NULL THEN '' ELSE ' ' END 
							+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_1_OPTION END
						+ CASE WHEN c.PHONE_1_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_1_NOTE,c.PHONE_1_NO,c.PHONE_1_OPTION) IS NULL THEN '' ELSE ' ' END 
							+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_1_EXT END
					END AS PhoneNumber,
				c.PHONE_1_TYPE AS Type
			WHERE c.CMP_Phone1 IS NOT NULL
			FOR XML PATH('Phone'), TYPE),
		(SELECT 
				'false' AS "@TollFree",
				'false' AS "@Confidential",
				CASE WHEN c.PHONE_2_NOTE IS NULL AND c.PHONE_2_NO IS NULL AND c.PHONE_2_EXT IS NULL AND c.PHONE_2_OPTION IS NULL
					THEN NULL
					ELSE ISNULL(c.PHONE_2_NOTE,'')
						+ CASE WHEN c.PHONE_2_NO IS NULL THEN '' ELSE CASE WHEN c.PHONE_2_NOTE IS NULL THEN '' ELSE ' ' END + c.PHONE_2_NO END
						+ CASE WHEN c.PHONE_2_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_2_NOTE,c.PHONE_2_NO) IS NULL THEN '' ELSE ' ' END 
							+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_2_OPTION END
						+ CASE WHEN c.PHONE_2_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_2_NOTE,c.PHONE_2_NO,c.PHONE_2_OPTION) IS NULL THEN '' ELSE ' ' END 
							+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_2_EXT END
					END AS PhoneNumber,
				c.PHONE_2_TYPE AS Type
			WHERE c.CMP_Phone2 IS NOT NULL
			FOR XML PATH('Phone'), TYPE),
			(SELECT 
				'false' AS "@TollFree",
				'false' AS "@Confidential",
				CASE WHEN c.PHONE_3_NOTE IS NULL AND c.PHONE_3_NO IS NULL AND c.PHONE_3_EXT IS NULL AND c.PHONE_3_OPTION IS NULL
					THEN NULL
					ELSE ISNULL(c.PHONE_3_NOTE,'')
						+ CASE WHEN c.PHONE_3_NO IS NULL THEN '' ELSE CASE WHEN c.PHONE_3_NOTE IS NULL THEN '' ELSE ' ' END + c.PHONE_3_NO END
						+ CASE WHEN c.PHONE_3_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_3_NOTE,c.PHONE_3_NO) IS NULL THEN '' ELSE ' ' END 
							+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_3_OPTION END
						+ CASE WHEN c.PHONE_3_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_3_NOTE,c.PHONE_3_NO,c.PHONE_3_OPTION) IS NULL THEN '' ELSE ' ' END 
							+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_3_EXT END
					END AS PhoneNumber,
				c.PHONE_3_TYPE AS Type
			WHERE c.CMP_Phone3 IS NOT NULL
			FOR XML PATH('Phone'), TYPE),
		(SELECT 
				'false' AS "@TollFree",
				'false' AS "@Confidential",
				c.CMP_Fax AS PhoneNumber,
				'Fax' AS Type
			WHERE c.CMP_Fax IS NOT NULL
			FOR XML PATH('Phone'), TYPE)
			
		FROM GBL_Contact c
		WHERE c.GblNUM=bt.NUM AND c.LangID=btd.LangID
			AND c.CMP_Name IS NOT NULL
			AND c.GblContactType IN ('EXEC_1','EXEC_2')
		ORDER BY c.GblContactType DESC
		FOR XML PATH('Contact'), TYPE
	),
	
	-- IRS STATUS
	cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('N/A',@LangID) AS IRSStatus,
	
	-- SOURCE OF FUNDS
	dbo.fn_CIC_NUMToFunding(bt.NUM, cbtd.FUNDING_NOTES, btd.LangID) AS SourceOfFunds,		

	-- SITE
	(SELECT

	-- SITE > EXCLUDE FROM WEB / DIRECTORY
		CASE WHEN (slbtd.DELETION_DATE IS NOT NULL AND slbtd.DELETION_DATE <= GETDATE()) OR slbtd.NON_PUBLIC=1 THEN 'true' ELSE 'false' END AS "@ExcludeFromWebsite",
		CASE WHEN (slbtd.DELETION_DATE IS NOT NULL AND slbtd.DELETION_DATE <= GETDATE()) OR slbtd.NON_PUBLIC=1 THEN 'true' ELSE 'false' END AS "@ExcludeFromDirectory",

	-- SITE > KEY
		CASE WHEN bt.NUM='ZZZ00001' THEN slbtd.NUM ELSE slbt.NUM END AS [Key],

	-- SITE > NAME
		ISNULL(slbtd.LOCATION_NAME,
			ISNULL(STUFF(
					COALESCE(', ' + CASE WHEN slbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 THEN NULL ELSE slbtd.ORG_LEVEL_1 END,'')
					+ COALESCE(', ' + CASE WHEN slbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 AND slbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 THEN NULL ELSE slbtd.ORG_LEVEL_2 END,'')
					+ COALESCE(', ' + CASE WHEN slbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 AND slbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 AND slbtd.ORG_LEVEL_3=btd.ORG_LEVEL_3 THEN NULL ELSE slbtd.ORG_LEVEL_3 END,'')
					+ COALESCE(', ' + CASE WHEN slbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 AND slbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 AND slbtd.ORG_LEVEL_3=btd.ORG_LEVEL_3 AND slbtd.ORG_LEVEL_4=btd.ORG_LEVEL_4 THEN NULL ELSE slbtd.ORG_LEVEL_4 END,'')
					+ COALESCE(', ' + slbtd.ORG_LEVEL_5,''),
					1, 2, ''
				),
				ISNULL(slbtd.ORG_LEVEL_1,'') + ISNULL(', ' + slbtd.ORG_LEVEL_2,'') + ISNULL(', ' + slbtd.ORG_LEVEL_3,'') + ISNULL(', ' + slbtd.ORG_LEVEL_4,'') + ISNULL(', ' + slbtd.ORG_LEVEL_5,'')
			)
		) AS Name,
				
	-- SITE > SITE DESCRIPTION
		ISNULL(CASE WHEN slbtd.LOCATION_DESCRIPTION LIKE '%<br>%' OR slbtd.LOCATION_DESCRIPTION LIKE '%<p>%' THEN slbtd.LOCATION_DESCRIPTION ELSE REPLACE(slbtd.LOCATION_DESCRIPTION,@nLine10,@nLine10 + '<br>') END,
			btd.ORG_LEVEL_1 + ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Site Location',@LangID) + CASE WHEN slbtd.LOCATION_NAME IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + slbtd.LOCATION_NAME ELSE '' END) AS SiteDescription,
			
	-- SITE > AKA NAMES
		(SELECT aka.Name, aka.Confidential, aka.Description FROM
			(SELECT
					ao.ALT_ORG AS Name,
					'false' AS Confidential,
					NULL AS Description
				FROM GBL_BT_ALTORG ao
				WHERE ao.NUM=slbtd.NUM AND ao.LangID=slbtd.LangID
					AND NOT EXISTS(SELECT * FROM GBL_BT_ALTORG oao WHERE oao.NUM=slbt.ORG_NUM AND oao.LangID=ao.LangID AND oao.ALT_ORG=ao.ALT_ORG)
			UNION SELECT
					fo.FORMER_ORG AS Name,
					'false' AS Confidential,
					cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Former Name',@LabelLangOverride) + ISNULL(cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',@LabelLangOverride) + fo.DATE_OF_CHANGE,'') AS Description
				FROM GBL_BT_FORMERORG fo
				WHERE fo.NUM=slbtd.NUM AND fo.LangID=slbtd.LangID
					AND NOT EXISTS(SELECT * FROM GBL_BT_FORMERORG ofo WHERE ofo.NUM=slbt.ORG_NUM AND ofo.LangID=fo.LangID AND ofo.FORMER_ORG=fo.FORMER_ORG)
			UNION SELECT
					slbtd.LEGAL_ORG COLLATE Latin1_General_100_CS_AS AS Name,
					'false' AS Confidential,
					cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Legal Name',@LabelLangOverride) AS Description
				WHERE slbtd.LEGAL_ORG IS NOT NULL
			UNION SELECT
						slbtd.ORG_LEVEL_1
						+ ISNULL(', ' + CASE
							WHEN slbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2
							THEN slbtd.ORG_LEVEL_2
								+ ISNULL(', ' + CASE
									WHEN slbtd.ORG_LEVEL_3=btd.ORG_LEVEL_3
									THEN slbtd.ORG_LEVEL_3 + ISNULL(', ' + CASE WHEN slbtd.ORG_LEVEL_4=btd.ORG_LEVEL_4 THEN slbtd.ORG_LEVEL_4 ELSE NULL END,'')
									ELSE NULL END,'')
							ELSE NULL END,'')
						AS Name,
					'false' AS Confidential,
					cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Agency Name',@LangID) AS Description
				WHERE slbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1
					AND NOT (
						(slbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 OR (slbtd.ORG_LEVEL_2 IS NULL AND btd.ORG_LEVEL_2 IS NULL))
						AND (slbtd.ORG_LEVEL_3=btd.ORG_LEVEL_3 OR (slbtd.ORG_LEVEL_3 IS NULL AND btd.ORG_LEVEL_3 IS NULL))
						AND (slbtd.ORG_LEVEL_4=btd.ORG_LEVEL_4 OR (slbtd.ORG_LEVEL_4 IS NULL AND btd.ORG_LEVEL_4 IS NULL))
						AND (slbtd.ORG_LEVEL_5=btd.ORG_LEVEL_5 OR (slbtd.ORG_LEVEL_5 IS NULL AND btd.ORG_LEVEL_5 IS NULL))
					)
			) aka
			FOR XML PATH('AKA'), TYPE
		),

	-- SITE > PHYSICAL ADDRESS
		(SELECT
				CASE WHEN EXISTS(SELECT *
					FROM GBL_PrivacyProfile_Fld pvf
					INNER JOIN GBL_FieldOption fo
						ON pvf.FieldID=fo.FieldID AND fo.FieldName='SITE_ADDRESS'
					WHERE pvf.ProfileID=slbt.PRIVACY_PROFILE)
					THEN 'true' ELSE 'false' END AS "@Confidential",
				slbtd.SITE_BUILDING AS PreAddressLine,
				dbo.fn_GBL_FullAddress(NULL,NULL,NULL,slbtd.SITE_STREET_NUMBER,slbtd.SITE_STREET,slbtd.SITE_STREET_TYPE,slbtd.SITE_STREET_TYPE_AFTER,slbtd.SITE_STREET_DIR,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,@LangID,0) AS Line1,
				slbtd.SITE_SUFFIX AS Line2,
				COALESCE(
					(SELECT EXPORT_CITY FROM @SiteCityTable WHERE SITE_CITY=slbtd.SITE_CITY),
					slbtd.SITE_CITY,
					(SELECT AreaName
						FROM dbo.GBL_Community_External_Map cmap
						INNER JOIN dbo.GBL_Community_External_Community excm
							ON excm.EXT_ID = cmap.MapOneEXTID AND excm.SystemCode='ONTARIO211'
						WHERE cmap.CM_ID=slbt.LOCATED_IN_CM),
					slbtd.MAIL_CITY,
					cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Unknown',@LangID)
					) AS City,
				ISNULL(slbtd.SITE_PROVINCE,(SELECT mem.DefaultProvince FROM STP_Member mem WHERE MemberID=@MemberID)) AS [State],
				CASE WHEN slbt.NUM=slbtd.NUM THEN slbt.SITE_POSTAL_CODE ELSE NULL END AS ZipCode,
				ISNULL(slbtd.SITE_COUNTRY,ISNULL((SELECT mem.DefaultCountry FROM STP_Member mem WHERE MemberID=@MemberID),'Canada')) AS Country
			WHERE slbtd.CMP_SiteAddress IS NOT NULL OR slbt.LOCATED_IN_CM IS NOT NULL
			FOR XML PATH('PhysicalAddress'),TYPE
		),
			
	-- SITE > MAIL ADDRESS
		(SELECT
				CASE WHEN EXISTS(SELECT *
					FROM GBL_PrivacyProfile_Fld pvf
					INNER JOIN GBL_FieldOption fo
						ON pvf.FieldID=fo.FieldID AND fo.FieldName='MAIL_ADDRESS'
					WHERE pvf.ProfileID=slbt.PRIVACY_PROFILE)
					THEN 'true' ELSE 'false' END AS "@Confidential",
				REPLACE(dbo.fn_GBL_FullAddress(NULL,NULL,slbtd.MAIL_BUILDING,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,slbtd.MAIL_CARE_OF,NULL,NULL,NULL,NULL,slbtd.LangID,0),@nLine,', ') AS PreAddressLine,
				REPLACE(dbo.fn_GBL_FullAddress(NULL,NULL,NULL,slbtd.MAIL_STREET_NUMBER,slbtd.MAIL_STREET,slbtd.MAIL_STREET_TYPE,slbtd.MAIL_STREET_TYPE_AFTER,slbtd.MAIL_STREET_DIR,NULL,NULL,NULL,NULL,NULL,NULL,slbtd.MAIL_BOX_TYPE,slbtd.MAIL_PO_BOX,NULL,NULL,slbtd.LangID,0),@nLine,', ') AS Line1,
				slbtd.MAIL_SUFFIX AS Line2,
				COALESCE(slbtd.MAIL_CITY,slbtd.SITE_CITY,cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Unknown',@LangID)) AS City,
				ISNULL(slbtd.MAIL_PROVINCE,(SELECT mem.DefaultProvince FROM STP_Member mem WHERE MemberID=@MemberID)) AS [State],
				CASE WHEN slbt.NUM=slbtd.NUM THEN slbt.MAIL_POSTAL_CODE ELSE NULL END AS ZipCode,
				ISNULL(slbtd.MAIL_COUNTRY,ISNULL((SELECT mem.DefaultCountry FROM STP_Member mem WHERE MemberID=@MemberID),'Canada')) AS Country
			WHERE slbtd.CMP_MailAddress IS NOT NULL
			FOR XML PATH('MailingAddress'),TYPE
		),
			
	-- SITE > NO ADDRESS
		(SELECT
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('None given',@LangID) AS Explanation
			WHERE slbtd.CMP_SiteAddress IS NULL AND slbtd.CMP_MailAddress IS NULL AND slbt.LOCATED_IN_CM IS NULL
			FOR XML PATH('NoPhysicalAddress'),TYPE
		),
			
	-- SITE > CROSS STREET
		slcbtd.INTERSECTION AS CrossStreet,
		
	-- SITE > PHONE
		(SELECT phone.*
			FROM (
			SELECT 'false' AS "@TollFree",
					'false' AS "@Confidential",
					slbtd.OFFICE_PHONE AS PhoneNumber,
					'Office' AS [Description],
					'Voice' AS [Type]
				WHERE slbtd.OFFICE_PHONE IS NOT NULL
			UNION SELECT 'false' AS "@TollFree",
					'false' AS "@Confidential",
					slcbtd.AFTER_HRS_PHONE AS PhoneNumber,
					'After Hours' AS [Description],
					'Voice' AS [Type]
				WHERE slcbtd.AFTER_HRS_PHONE IS NOT NULL
			UNION SELECT 'false' AS "@TollFree",
					'false' AS "@Confidential",
					slcbtd.CRISIS_PHONE AS PhoneNumber,
					'Crisis' AS [Description],
					'Voice' AS [Type]
				WHERE slcbtd.CRISIS_PHONE IS NOT NULL
			UNION SELECT 'false' AS "@TollFree",
					'false' AS "@Confidential",
					slbtd.FAX AS PhoneNumber,
					'Fax' AS [Description],
					'Fax' AS [Type]
				WHERE slbtd.FAX IS NOT NULL
			UNION SELECT 'false' AS "@TollFree",
					'false' AS "@Confidential",
					slcbtd.TDD_PHONE AS PhoneNumber,
					'TTY/TDD' AS [Description],
					'TTY/TDD' AS [Type]
				WHERE slcbtd.TDD_PHONE IS NOT NULL
			UNION SELECT
					'true' AS "@TollFree",
					'false' AS "@Confidential",
					slbtd.TOLL_FREE_PHONE AS PhoneNumber,
					'Toll Free' AS [Description],
					'Voice' AS [Type]
				WHERE slbtd.TOLL_FREE_PHONE IS NOT NULL
			) phone
		FOR XML PATH('Phone'), TYPE
		),
		
	-- SITE > URL
		(SELECT slbtd.WWW_ADDRESS AS Address
			WHERE slbtd.WWW_ADDRESS IS NOT NULL
			FOR XML PATH('URL'), TYPE),
		
	-- SITE > EMAIL
		(SELECT LTRIM(ItemID) AS Address
			FROM dbo.fn_GBL_ParseVarCharIDList(slbtd.E_MAIL,',')
			WHERE slbtd.E_MAIL IS NOT NULL
			FOR XML PATH('Email'), TYPE),
		
	-- SITE > CONTACT
		(SELECT 

	-- SITE > CONTACT > TYPE
			(SELECT ISNULL(FieldDisplay,FieldName)
				FROM GBL_FieldOption fo
				LEFT JOIN GBL_FieldOption_Description fod
					ON fo.FieldID=fod.FieldID AND fod.LangID=@LabelLangOverride
				WHERE fo.FieldName=c.GblContactType) AS "@Type",

	-- SITE > CONTACT > TITLE
			c.TITLE AS Title,

	-- SITE > CONTACT > NAME
			c.CMP_Name AS Name,

	-- SITE > CONTACT > EMAIL
			(SELECT LTRIM(ItemID) AS Address FROM dbo.fn_GBL_ParseVarCharIDList(c.EMAIL,',') FOR XML PATH('Email'), TYPE),

	-- SITE > CONTACT > PHONE
			(SELECT 
					'false' AS "@TollFree",
					'false' AS "@Confidential",
					CASE WHEN c.PHONE_1_NOTE IS NULL AND c.PHONE_1_NO IS NULL AND c.PHONE_1_EXT IS NULL AND c.PHONE_1_OPTION IS NULL
						THEN NULL
						ELSE ISNULL(c.PHONE_1_NOTE,'')
							+ CASE WHEN c.PHONE_1_NO IS NULL THEN '' ELSE CASE WHEN c.PHONE_1_NOTE IS NULL THEN '' ELSE ' ' END + c.PHONE_1_NO END
							+ CASE WHEN c.PHONE_1_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_1_NOTE,c.PHONE_1_NO) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_1_OPTION END
							+ CASE WHEN c.PHONE_1_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_1_NOTE,c.PHONE_1_NO,c.PHONE_1_OPTION) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_1_EXT END
						END AS PhoneNumber,
					c.PHONE_1_TYPE AS Type
				WHERE c.CMP_Phone1 IS NOT NULL
				FOR XML PATH('Phone'), TYPE),
			(SELECT 
					'false' AS "@TollFree",
					'false' AS "@Confidential",
					CASE WHEN c.PHONE_2_NOTE IS NULL AND c.PHONE_2_NO IS NULL AND c.PHONE_2_EXT IS NULL AND c.PHONE_2_OPTION IS NULL
						THEN NULL
						ELSE ISNULL(c.PHONE_2_NOTE,'')
							+ CASE WHEN c.PHONE_2_NO IS NULL THEN '' ELSE CASE WHEN c.PHONE_2_NOTE IS NULL THEN '' ELSE ' ' END + c.PHONE_2_NO END
							+ CASE WHEN c.PHONE_2_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_2_NOTE,c.PHONE_2_NO) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_2_OPTION END
							+ CASE WHEN c.PHONE_2_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_2_NOTE,c.PHONE_2_NO,c.PHONE_2_OPTION) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_2_EXT END
						END AS PhoneNumber,
					c.PHONE_2_TYPE AS Type
				WHERE c.CMP_Phone2 IS NOT NULL
				FOR XML PATH('Phone'), TYPE),
				(SELECT 
					'false' AS "@TollFree",
					'false' AS "@Confidential",
					CASE WHEN c.PHONE_3_NOTE IS NULL AND c.PHONE_3_NO IS NULL AND c.PHONE_3_EXT IS NULL AND c.PHONE_3_OPTION IS NULL
						THEN NULL
						ELSE ISNULL(c.PHONE_3_NOTE,'')
							+ CASE WHEN c.PHONE_3_NO IS NULL THEN '' ELSE CASE WHEN c.PHONE_3_NOTE IS NULL THEN '' ELSE ' ' END + c.PHONE_3_NO END
							+ CASE WHEN c.PHONE_3_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_3_NOTE,c.PHONE_3_NO) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_3_OPTION END
							+ CASE WHEN c.PHONE_3_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_3_NOTE,c.PHONE_3_NO,c.PHONE_3_OPTION) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_3_EXT END
						END AS PhoneNumber,
					c.PHONE_3_TYPE AS Type
				WHERE c.CMP_Phone3 IS NOT NULL
				FOR XML PATH('Phone'), TYPE),
			(SELECT 
					'false' AS "@TollFree",
					'false' AS "@Confidential",
					c.CMP_Fax AS PhoneNumber,
					'Fax' AS Type
				WHERE c.CMP_Fax IS NOT NULL
				FOR XML PATH('Phone'), TYPE)

			FROM GBL_Contact c
			WHERE c.GblNUM=slbtd.NUM AND c.LangID=slbtd.LangID
				AND c.CMP_Name IS NOT NULL
				AND c.GblContactType IN ('CONTACT_1','CONTACT_2')
			FOR XML PATH('Contact'), TYPE
		),
		
	-- SITE > TIME OPEN
		(SELECT CASE
				WHEN slcbtd.HOURS IS NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Dates') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + slcbtd.DATES
				ELSE slcbtd.HOURS + ISNULL(@nLine + cioc_shared.dbo.fn_SHR_STP_ObjectName('Dates') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + slcbtd.DATES,'')
				END AS Notes
			WHERE slcbtd.HOURS IS NOT NULL OR slcbtd.DATES IS NOT NULL FOR XML PATH(''), TYPE) AS TimeOpen,
		
	-- SITE > LANGUAGES
		(SELECT Name, Notes
			FROM (SELECT
						lnn.Name,
						CASE WHEN lprn.Notes IS NULL AND NOT EXISTS(SELECT * FROM CIC_BT_LN_LND WHERE BT_LN_ID=lpr.BT_LN_ID) THEN NULL ELSE
							ISNULL((SELECT STUFF((SELECT ', ' + ISNULL(lndn.Name,lnd.Code)
								FROM dbo.CIC_BT_LN_LND prlnd
								INNER JOIN dbo.GBL_Language_Details lnd
									ON lnd.LND_ID = prlnd.LND_ID
								LEFT JOIN dbo.GBL_Language_Details_Name lndn
									ON lndn.LND_ID = lnd.LND_ID AND lndn.LangID=slbtd.LangID
								WHERE prlnd.BT_LN_ID=lpr.BT_LN_ID
								FOR XML PATH('')) ,1,2,'')),'')
							+ CASE WHEN lprn.Notes IS NULL THEN ''
								ELSE CASE WHEN EXISTS(SELECT * FROM dbo.CIC_BT_LN_LND prlnd WHERE prlnd.BT_LN_ID=lpr.BT_LN_ID)
								THEN ', ' ELSE '' END + lprn.Notes END
						END AS Notes
					FROM CIC_BT_LN lpr
					LEFT JOIN CIC_BT_LN_Notes lprn
						ON lpr.BT_LN_ID=lprn.BT_LN_ID AND lprn.LangID=slbtd.LangID
					INNER JOIN GBL_Language ln
						ON lpr.LN_ID=ln.LN_ID
					INNER JOIN GBL_Language_Name lnn
						ON ln.LN_ID=lnn.LN_ID AND lnn.LangID=(SELECT TOP 1 LangID FROM GBL_Language_Name WHERE LN_ID=lnn.LN_ID ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
					WHERE lpr.NUM=slbtd.NUM
				UNION SELECT
					cioc_shared.dbo.fn_SHR_STP_ObjectName('Other') AS Name,
					slcbtd.LANGUAGE_NOTES
					WHERE slcbtd.LANGUAGE_NOTES IS NOT NULL
				) lang
			WHERE slcbtd.CMP_Languages IS NOT NULL
			FOR XML PATH('Languages'), TYPE
		),
			
	-- SITE > DISABILITIES ACCESS
		dbo.fn_GBL_NUMToAccessibility(slbtd.NUM,slbtd.ACCESSIBILITY_NOTES,slbtd.LangID) AS DisabilitiesAccess,
		
	-- SITE > PHYSICAL LOCATION DESCRIPTION
		slcbtd.SITE_LOCATION AS PhysicalLocationDescription,

	-- SITE > BUS SERVICE ACCESS
		dbo.fn_CIC_NUMToBusRoutes(slbt.NUM) AS BusServiceAccess,
		
		
	-- SITE > SERVICE
		(SELECT

	-- EXCLUDE FROM WEB / DIRECTORY
		CASE WHEN (svbtd.DELETION_DATE IS NOT NULL AND svbtd.DELETION_DATE <= GETDATE()) OR svbtd.NON_PUBLIC=1 THEN 'true' ELSE 'false' END AS "@ExcludeFromWebsite",
		CASE WHEN (svbtd.DELETION_DATE IS NOT NULL AND svbtd.DELETION_DATE <= GETDATE()) OR svbtd.NON_PUBLIC=1 THEN 'true' ELSE 'false' END AS "@ExcludeFromDirectory",

	-- SITE > SERVICE > NAME
		/*
		ISNULL(svbtd.ORG_LEVEL_1,'') + ISNULL(', ' + svbtd.ORG_LEVEL_2,'') + ISNULL(', ' + svbtd.ORG_LEVEL_3,'') + ISNULL(', ' + svbtd.ORG_LEVEL_4,'') + ISNULL(', ' + svbtd.ORG_LEVEL_5,'') AS Name,
		*/

		ISNULL(STUFF(
			COALESCE(', ' + svbtd.SERVICE_NAME_LEVEL_1,'') +
			COALESCE(', ' + svbtd.SERVICE_NAME_LEVEL_2,''),
			1, 2, ''
			),
			ISNULL(STUFF(
					COALESCE(', ' + CASE WHEN svbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 THEN NULL ELSE svbtd.ORG_LEVEL_1 END,'')
					+ COALESCE(', ' + CASE WHEN svbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 AND svbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 THEN NULL ELSE svbtd.ORG_LEVEL_2 END,'')
					+ COALESCE(', ' + CASE WHEN svbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 AND svbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 AND svbtd.ORG_LEVEL_3=btd.ORG_LEVEL_3 THEN NULL ELSE svbtd.ORG_LEVEL_3 END,'')
					+ COALESCE(', ' + CASE WHEN svbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 AND svbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 AND svbtd.ORG_LEVEL_3=btd.ORG_LEVEL_3 AND svbtd.ORG_LEVEL_4=btd.ORG_LEVEL_4 THEN NULL ELSE svbtd.ORG_LEVEL_4 END,'')
					+ COALESCE(', ' + svbtd.ORG_LEVEL_5,''),
					1, 2, ''
				),
				ISNULL(svbtd.ORG_LEVEL_1,'') + ISNULL(', ' + svbtd.ORG_LEVEL_2,'') + ISNULL(', ' + svbtd.ORG_LEVEL_3,'') + ISNULL(', ' + svbtd.ORG_LEVEL_4,'') + ISNULL(', ' + svbtd.ORG_LEVEL_5,'')
			)
		) AS Name,
				
	-- SITE > SERVICE > KEY
			svbtd.NUM AS [Key],
			
	-- SITE > SERVICE > DESCRIPTION
			CASE WHEN svbtd.DESCRIPTION LIKE '%<br>%' OR svbtd.DESCRIPTION LIKE '%<p>%' THEN svbtd.DESCRIPTION ELSE REPLACE(svbtd.DESCRIPTION,@nLine10,@nLine10 + '<br>') END AS Description,
			
	-- SITE > SERVICE > AKA NAMES
	(SELECT aka.Name, aka.Confidential, aka.Description FROM
		(SELECT
				ao.ALT_ORG AS Name,
				'false' AS Confidential,
				NULL AS Description
			FROM GBL_BT_ALTORG ao
			WHERE ao.NUM=svbt.NUM AND ao.LangID=svbtd.LangID
		UNION SELECT
				fo.FORMER_ORG AS Name,
				'false' AS Confidential,
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Former Name',@LabelLangOverride) + ISNULL(cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',@LabelLangOverride) + fo.DATE_OF_CHANGE,'') AS Description
			FROM GBL_BT_FORMERORG fo
			WHERE fo.NUM=svbt.NUM AND fo.LangID=svbtd.LangID
		UNION SELECT
				svbtd.LEGAL_ORG COLLATE Latin1_General_100_CS_AS AS Name,
				'false' AS Confidential,
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Legal Name',@LabelLangOverride) AS Description
			WHERE svbtd.LEGAL_ORG IS NOT NULL
		UNION SELECT
					svbtd.ORG_LEVEL_1
					+ ISNULL(', ' + CASE
						WHEN svbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2
						THEN svbtd.ORG_LEVEL_2
							+ ISNULL(', ' + CASE
								WHEN svbtd.ORG_LEVEL_3=btd.ORG_LEVEL_3
								THEN svbtd.ORG_LEVEL_3 + ISNULL(', ' + CASE WHEN svbtd.ORG_LEVEL_4=btd.ORG_LEVEL_4 THEN svbtd.ORG_LEVEL_4 ELSE NULL END,'')
								ELSE NULL END,'')
						ELSE NULL END,'')
					AS Name,
				'false' AS Confidential,
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Agency Name',@LangID) AS Description
			WHERE svbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1
				AND NOT (
					(svbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 OR (svbtd.ORG_LEVEL_2 IS NULL AND btd.ORG_LEVEL_2 IS NULL))
					AND (svbtd.ORG_LEVEL_3=btd.ORG_LEVEL_3 OR (svbtd.ORG_LEVEL_3 IS NULL AND btd.ORG_LEVEL_3 IS NULL))
					AND (svbtd.ORG_LEVEL_4=btd.ORG_LEVEL_4 OR (svbtd.ORG_LEVEL_4 IS NULL AND btd.ORG_LEVEL_4 IS NULL))
					AND (svbtd.ORG_LEVEL_5=btd.ORG_LEVEL_5 OR (svbtd.ORG_LEVEL_5 IS NULL AND btd.ORG_LEVEL_5 IS NULL))
				)
		) aka
	FOR XML PATH('AKA'), TYPE),

	-- SITE > SERVICE > PHONE
			(SELECT phone.*
				FROM (
				SELECT 'false' AS "@TollFree",
						'false' AS "@Confidential",
						svbtd.OFFICE_PHONE AS PhoneNumber,
						'Office' AS [Description],
						'Voice' AS [Type]
					WHERE svbtd.OFFICE_PHONE IS NOT NULL
				UNION SELECT 'false' AS "@TollFree",
						'false' AS "@Confidential",
						svcbtd.AFTER_HRS_PHONE AS PhoneNumber,
						'After Hours' AS [Description],
						'Voice' AS [Type]
					WHERE svcbtd.AFTER_HRS_PHONE IS NOT NULL
				UNION SELECT 'false' AS "@TollFree",
						'false' AS "@Confidential",
						svcbtd.CRISIS_PHONE AS PhoneNumber,
						'Crisis' AS [Description],
						'Voice' AS [Type]
					WHERE svcbtd.CRISIS_PHONE IS NOT NULL
				UNION SELECT 'false' AS "@TollFree",
						'false' AS "@Confidential",
						svbtd.FAX AS PhoneNumber,
						'Fax' AS [Description],
						'Fax' AS [Type]
					WHERE svbtd.FAX IS NOT NULL
				UNION SELECT 'false' AS "@TollFree",
						'false' AS "@Confidential",
						svcbtd.TDD_PHONE AS PhoneNumber,
						'TTY/TDD' AS [Description],
						'TTY/TDD' AS [Type]
					WHERE svcbtd.TDD_PHONE IS NOT NULL
				UNION SELECT
						'true' AS "@TollFree",
						'false' AS "@Confidential",
						svbtd.TOLL_FREE_PHONE AS PhoneNumber,
						'Toll Free' AS [Description],
						'Voice' AS [Type]
					WHERE svbtd.TOLL_FREE_PHONE IS NOT NULL
				) phone
			FOR XML PATH('Phone'), TYPE),
			
	-- SITE > SERVICE > URL
		(SELECT svbtd.WWW_ADDRESS AS Address
			WHERE svbtd.WWW_ADDRESS IS NOT NULL
			FOR XML PATH('URL'), TYPE),
		
	-- SITE > SERVICE > EMAIL
		(SELECT LTRIM(ItemID) AS Address
			FROM dbo.fn_GBL_ParseVarCharIDList(svbtd.E_MAIL,',')
			WHERE svbtd.E_MAIL IS NOT NULL
			FOR XML PATH('Email'), TYPE),
		
	-- SITE > SERVICE > CONTACT
		(SELECT 

	-- SITE > SERVICE > CONTACT > TYPE
			(SELECT ISNULL(FieldDisplay,FieldName)
				FROM GBL_FieldOption fo
				LEFT JOIN GBL_FieldOption_Description fod
					ON fo.FieldID=fod.FieldID AND fod.LangID=@LabelLangOverride	 
				WHERE fo.FieldName=c.GblContactType) AS "@Type",

	-- SITE > SERVICE > CONTACT > TITLE
			c.TITLE AS Title,

	-- SITE > SERVICE > CONTACT > NAME
			c.CMP_Name AS Name,

	-- SITE > SERVICE > CONTACT > EMAIL
			(SELECT LTRIM(ItemID) AS Address FROM dbo.fn_GBL_ParseVarCharIDList(c.EMAIL,',') FOR XML PATH('Email'), TYPE),

	-- SITE > SERVICE > CONTACT > PHONE
			(SELECT 
					'false' AS "@TollFree",
					'false' AS "@Confidential",
					CASE WHEN c.PHONE_1_NOTE IS NULL AND c.PHONE_1_NO IS NULL AND c.PHONE_1_EXT IS NULL AND c.PHONE_1_OPTION IS NULL
						THEN NULL
						ELSE ISNULL(c.PHONE_1_NOTE,'')
							+ CASE WHEN c.PHONE_1_NO IS NULL THEN '' ELSE CASE WHEN c.PHONE_1_NOTE IS NULL THEN '' ELSE ' ' END + c.PHONE_1_NO END
							+ CASE WHEN c.PHONE_1_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_1_NOTE,c.PHONE_1_NO) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_1_OPTION END
							+ CASE WHEN c.PHONE_1_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_1_NOTE,c.PHONE_1_NO,c.PHONE_1_OPTION) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_1_EXT END
						END AS PhoneNumber,
					c.PHONE_1_TYPE AS Type
				WHERE c.CMP_Phone1 IS NOT NULL
				FOR XML PATH('Phone'), TYPE),
			(SELECT 
					'false' AS "@TollFree",
					'false' AS "@Confidential",
					CASE WHEN c.PHONE_2_NOTE IS NULL AND c.PHONE_2_NO IS NULL AND c.PHONE_2_EXT IS NULL AND c.PHONE_2_OPTION IS NULL
						THEN NULL
						ELSE ISNULL(c.PHONE_2_NOTE,'')
							+ CASE WHEN c.PHONE_2_NO IS NULL THEN '' ELSE CASE WHEN c.PHONE_2_NOTE IS NULL THEN '' ELSE ' ' END + c.PHONE_2_NO END
							+ CASE WHEN c.PHONE_2_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_2_NOTE,c.PHONE_2_NO) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_2_OPTION END
							+ CASE WHEN c.PHONE_2_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_2_NOTE,c.PHONE_2_NO,c.PHONE_2_OPTION) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_2_EXT END
						END AS PhoneNumber,
					c.PHONE_2_TYPE AS Type
				WHERE c.CMP_Phone2 IS NOT NULL
				FOR XML PATH('Phone'), TYPE),
				(SELECT 
					'false' AS "@TollFree",
					'false' AS "@Confidential",
					CASE WHEN c.PHONE_3_NOTE IS NULL AND c.PHONE_3_NO IS NULL AND c.PHONE_3_EXT IS NULL AND c.PHONE_3_OPTION IS NULL
						THEN NULL
						ELSE ISNULL(c.PHONE_3_NOTE,'')
							+ CASE WHEN c.PHONE_3_NO IS NULL THEN '' ELSE CASE WHEN c.PHONE_3_NOTE IS NULL THEN '' ELSE ' ' END + c.PHONE_3_NO END
							+ CASE WHEN c.PHONE_3_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_3_NOTE,c.PHONE_3_NO) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_3_OPTION END
							+ CASE WHEN c.PHONE_3_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_3_NOTE,c.PHONE_3_NO,c.PHONE_3_OPTION) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_3_EXT END
						END AS PhoneNumber,
					c.PHONE_3_TYPE AS Type
				WHERE c.CMP_Phone3 IS NOT NULL
				FOR XML PATH('Phone'), TYPE),
			(SELECT 
					'false' AS "@TollFree",
					'false' AS "@Confidential",
					c.CMP_Fax AS PhoneNumber,
					'Fax' AS Type
				WHERE c.CMP_Fax IS NOT NULL
				FOR XML PATH('Phone'), TYPE)

			FROM GBL_Contact c
			WHERE c.GblNUM=svbtd.NUM AND c.LangID=svbtd.LangID
				AND c.CMP_Name IS NOT NULL
				AND c.GblContactType IN ('CONTACT_1','CONTACT_2')
			FOR XML PATH('Contact'), TYPE
		),			
			
	-- SITE > SERVICE > TIME OPEN
			(SELECT CASE
					WHEN svcbtd.HOURS IS NULL THEN CASE WHEN svcbtd.DATES IS NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Meetings') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + svcbtd.MEETINGS ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Dates') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + svcbtd.DATES + ISNULL(@nLine + cioc_shared.dbo.fn_SHR_STP_ObjectName('Meetings') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + svcbtd.MEETINGS,'') END
					ELSE svcbtd.HOURS + ISNULL(@nLine + cioc_shared.dbo.fn_SHR_STP_ObjectName('Dates') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + svcbtd.DATES,'') + ISNULL(@nLine + cioc_shared.dbo.fn_SHR_STP_ObjectName('Meetings') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + svcbtd.MEETINGS,'')
					END AS Notes
				WHERE svcbtd.HOURS IS NOT NULL OR svcbtd.DATES IS NOT NULL FOR XML PATH(''), TYPE) AS TimeOpen,
			
	-- SITE > SERVICE > TAXONOMY
			(SELECT (SELECT Code FROM CIC_BT_TAX_TM WHERE BT_TAX_ID=tax.BT_TAX_ID FOR XML PATH(''), TYPE)
				FROM CIC_BT_TAX tax
				WHERE tax.NUM=svbt.NUM
				FOR XML PATH('Taxonomy'), TYPE),
			(SELECT
				'Z' AS Code
				WHERE NOT EXISTS(SELECT * FROM CIC_BT_TAX tax WHERE tax.NUM=svbt.NUM)
				FOR XML PATH('Taxonomy'), TYPE),
				
	-- SITE > SERVICE > LANGUAGES
			(SELECT Name, Notes
				FROM (SELECT
							lnn.Name,
							CASE WHEN lprn.Notes IS NULL AND NOT EXISTS(SELECT * FROM CIC_BT_LN_LND WHERE BT_LN_ID=lpr.BT_LN_ID) THEN NULL ELSE
								ISNULL((SELECT STUFF((SELECT ', ' + ISNULL(lndn.Name,lnd.Code)
									FROM dbo.CIC_BT_LN_LND prlnd
									INNER JOIN dbo.GBL_Language_Details lnd
										ON lnd.LND_ID = prlnd.LND_ID
									LEFT JOIN dbo.GBL_Language_Details_Name lndn
										ON lndn.LND_ID = lnd.LND_ID AND lndn.LangID=svbtd.LangID
									WHERE prlnd.BT_LN_ID=lpr.BT_LN_ID
									FOR XML PATH('')) ,1,2,'')),'')
								+ CASE WHEN lprn.Notes IS NULL THEN ''
									ELSE CASE WHEN EXISTS(SELECT * FROM dbo.CIC_BT_LN_LND prlnd WHERE prlnd.BT_LN_ID=lpr.BT_LN_ID)
									THEN ', ' ELSE '' END + lprn.Notes END
							END AS Notes
						FROM CIC_BT_LN lpr
						LEFT JOIN CIC_BT_LN_Notes lprn
							ON lpr.BT_LN_ID=lprn.BT_LN_ID AND lprn.LangID=svbtd.LangID
						INNER JOIN GBL_Language ln
							ON lpr.LN_ID=ln.LN_ID
						INNER JOIN GBL_Language_Name lnn
							ON ln.LN_ID=lnn.LN_ID AND lnn.LangID=(SELECT TOP 1 LangID FROM GBL_Language_Name WHERE LN_ID=lnn.LN_ID ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
						WHERE lpr.NUM=svbt.NUM
					UNION SELECT
						cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Other',@LangID) AS Name,
						svcbtd.LANGUAGE_NOTES
						WHERE svcbtd.LANGUAGE_NOTES IS NOT NULL
					) lang
				WHERE svcbtd.CMP_Languages IS NOT NULL
				FOR XML PATH('Languages'), TYPE
			),
	
	-- SITE > SERVICE > GEOGRAPHIC AREA SERVED
			(SELECT 
					(SELECT
						CAST(N'<' + excm.AIRSExportType + N'>' + (SELECT excm.AreaName AS [text()] FOR XML PATH('')) + N'</' + excm.AIRSExportType + N'>' AS xml) AS [node()]
						FROM (SELECT DISTINCT excm.AIRSExportType, excm.AreaName, cmat.[Order]
							FROM CIC_BT_CM cpr
							INNER JOIN GBL_Community cm
								ON cpr.CM_ID=cm.CM_ID
							INNER JOIN GBL_Community_External_Map_All map
								ON cm.CM_ID=map.CM_ID AND map.SystemCode = 'ONTARIO211'
							INNER JOIN GBL_Community_External_Community excm
								ON excm.EXT_ID=map.EXT_ID
							LEFT JOIN dbo.GBL_Community_AIRSType cmat
								ON cmat.AIRSExportType = excm.AIRSExportType
							WHERE cpr.NUM=svbt.NUM
						) AS excm
						ORDER BY excm.[Order]
						FOR XML PATH(''), TYPE
					),
					REPLACE(REPLACE(svcbtd.CMP_AreasServed,CHAR(13),''),CHAR(10),' ; ') AS [Description]
				WHERE svcbtd.CMP_AreasServed IS NOT NULL
				FOR XML PATH('GeographicAreaServed'), TYPE
			),
	
	-- SITE > SERVICE > RESOURCE INFO
			(SELECT 
					CASE WHEN (svbtd.DELETION_DATE IS NOT NULL AND svbtd.DELETION_DATE <= GETDATE()) OR svbtd.NON_PUBLIC=1 THEN 'false' ELSE 'true' END AS "@AvailableForDirectory",
					CASE WHEN (svbtd.DELETION_DATE IS NOT NULL AND svbtd.DELETION_DATE <= GETDATE()) THEN 'false' ELSE 'true' END AS "@AvailableForReferral",
					CASE WHEN (svbtd.DELETION_DATE IS NOT NULL AND svbtd.DELETION_DATE <= GETDATE()) THEN 'false' ELSE 'true' END AS "@AvailableForResearch",
					CAST(svbtd.CREATED_DATE AS date) AS "@DateAdded",
					CAST(svbtd.UPDATE_DATE AS date) AS "@DateLastVerified",
					CAST(svbtd.MODIFIED_DATE AS date) AS "@DateOfLastAction",
					(SELECT
						'Source' AS "@Type",
						svbtd.SOURCE_TITLE AS Title,
						svbtd.SOURCE_NAME AS Name,
						(SELECT LTRIM(ItemID) AS Address FROM dbo.fn_GBL_ParseVarCharIDList(svbtd.SOURCE_EMAIL,',') FOR XML PATH('Email'), TYPE),
						(SELECT 
								'false' AS "@TollFree",
								'false' AS "@Confidential",
								svbtd.SOURCE_PHONE AS PhoneNumber,
								'Voice' AS Type
							WHERE svbtd.SOURCE_PHONE IS NOT NULL
							FOR XML PATH('Phone'), TYPE),
						(SELECT 
								'false' AS "@TollFree",
								'false' AS "@Confidential",
								svbtd.SOURCE_FAX AS PhoneNumber,
								'Fax' AS Type
							WHERE svbtd.SOURCE_FAX IS NOT NULL
							FOR XML PATH('Phone'), TYPE)
						WHERE svbtd.SOURCE_NAME IS NOT NULL
						FOR XML PATH('Contact'), TYPE),
					svbtd.UPDATED_BY AS ResourceSpecialist
				FOR XML PATH('ResourceInfo'), TYPE
			),
	-- SITE > SERVICE > APPLICATION PROCESS
				(SELECT '1' AS Step,
						svcbtd.APPLICATION AS Description
					WHERE svcbtd.APPLICATION IS NOT NULL FOR XML PATH(''), TYPE) AS ApplicationProcess,
				
	-- SITE > SERVICE > FEE STRUCTURE
				svcbtd.CMP_Fees AS FeeStructure,
				
	-- SITE > SERVICE > OTHER REQUIREMENTS
				svcbtd.ELIGIBILITY_NOTES AS OtherRequirements,
				
	-- SITE > SERVICE > AGE REQUIREMENTS
				cioc_shared.dbo.fn_SHR_CIC_FullEligibility(MIN_AGE, MAX_AGE, NULL) AS AgeRequirements,
				
	-- SITE > SERVICE > RESIDENCY REQUIREMENTS
				svcbtd.BOUNDARIES AS ResidencyRequirements,

	-- SITE > SERVICE > COMMENTS
	(SELECT svcbtd.COMMENTS AS Notes
		WHERE svcbtd.COMMENTS IS NOT NULL) AS InternalNote,
	(SELECT svcbtd.CMP_InternalMemo AS Notes
		WHERE svcbtd.CMP_InternalMemo IS NOT NULL) AS EditorsNote,
	(SELECT svcbtd.PUBLIC_COMMENTS AS Notes
		WHERE svcbtd.PUBLIC_COMMENTS IS NOT NULL) AS PublicNote
			FROM GBL_BaseTable svbt
			INNER JOIN GBL_BaseTable_Description svbtd
				ON svbt.NUM=svbtd.NUM AND svbtd.LangID=@LangID
					AND (@CanSeeNonPublic=1 OR svbtd.NON_PUBLIC=0)
					AND (svbtd.DELETION_DATE IS NULL OR svbtd.DELETION_DATE > GETDATE())
					AND (@HidePastDueBy IS NULL OR (svbtd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,svbtd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
			LEFT JOIN CIC_BaseTable svcbt
				ON svbt.NUM = svcbt.NUM
			LEFT JOIN CIC_BaseTable_Description svcbtd
				ON svcbt.NUM=svcbtd.NUM AND svcbtd.LangID=svbtd.LangID
			WHERE (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=slbt.NUM AND PB_ID=@PB_ID))
				AND (svbt.MemberID=@MemberID
						OR EXISTS(SELECT *
							FROM GBL_BT_SharingProfile pr
							INNER JOIN GBL_SharingProfile shp
								ON pr.ProfileID=shp.ProfileID
									AND shp.Active=1
									AND (
										shp.CanUseAnyView=1
										OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
									)
							WHERE NUM=svbt.NUM AND ShareMemberID_Cache=@MemberID)
					)
				AND (EXISTS(SELECT * FROM GBL_BT_LOCATION_SERVICE WHERE LOCATION_NUM=slbt.NUM AND SERVICE_NUM=svbt.NUM))
				AND EXISTS(SELECT * FROM GBL_BT_OLS spr INNER JOIN GBL_OrgLocationService sols ON spr.OLS_ID=sols.OLS_ID AND sols.Code IN ('SERVICE','TOPIC') WHERE spr.NUM=svbt.NUM)
				AND (
					@DST_ID IS NULL
					OR EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=svbt.NUM)
				)
		FOR XML PATH('SiteService'), TYPE
		),
		
	-- SITE > SERVICE
		(SELECT

	-- EXCLUDE FROM WEB / DIRECTORY
		CASE WHEN (svbtd.DELETION_DATE IS NOT NULL AND svbtd.DELETION_DATE <= GETDATE()) OR svbtd.NON_PUBLIC=1 THEN 'true' ELSE 'false' END AS "@ExcludeFromWebsite",
		CASE WHEN (svbtd.DELETION_DATE IS NOT NULL AND svbtd.DELETION_DATE <= GETDATE()) OR svbtd.NON_PUBLIC=1 THEN 'true' ELSE 'false' END AS "@ExcludeFromDirectory",

	-- SITE > SERVICE > NAME
		/*
		ISNULL(svbtd.ORG_LEVEL_1,'') + ISNULL(', ' + svbtd.ORG_LEVEL_2,'') + ISNULL(', ' + svbtd.ORG_LEVEL_3,'') + ISNULL(', ' + svbtd.ORG_LEVEL_4,'') + ISNULL(', ' + svbtd.ORG_LEVEL_5,'') AS Name,
		*/

		ISNULL(STUFF(
			COALESCE(', ' + svbtd.SERVICE_NAME_LEVEL_1,'') +
			COALESCE(', ' + svbtd.SERVICE_NAME_LEVEL_2,''),
			1, 2, ''
			),
			ISNULL(STUFF(
					COALESCE(', ' + CASE WHEN svbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 THEN NULL ELSE svbtd.ORG_LEVEL_1 END,'')
					+ COALESCE(', ' + CASE WHEN svbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 AND svbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 THEN NULL ELSE svbtd.ORG_LEVEL_2 END,'')
					+ COALESCE(', ' + CASE WHEN svbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 AND svbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 AND svbtd.ORG_LEVEL_3=btd.ORG_LEVEL_3 THEN NULL ELSE svbtd.ORG_LEVEL_3 END,'')
					+ COALESCE(', ' + CASE WHEN svbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 AND svbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 AND svbtd.ORG_LEVEL_3=btd.ORG_LEVEL_3 AND svbtd.ORG_LEVEL_4=btd.ORG_LEVEL_4 THEN NULL ELSE svbtd.ORG_LEVEL_4 END,'')
					+ COALESCE(', ' + svbtd.ORG_LEVEL_5,''),
					1, 2, ''
				),
				ISNULL(svbtd.ORG_LEVEL_1,'') + ISNULL(', ' + svbtd.ORG_LEVEL_2,'') + ISNULL(', ' + svbtd.ORG_LEVEL_3,'') + ISNULL(', ' + svbtd.ORG_LEVEL_4,'') + ISNULL(', ' + svbtd.ORG_LEVEL_5,'')
			)
		) AS Name,
				
	-- SITE > SERVICE > KEY
			svbtd.NUM AS [Key],
			
	-- SITE > SERVICE > DESCRIPTION
			CASE WHEN svbtd.DESCRIPTION LIKE '%<br>%' OR svbtd.DESCRIPTION LIKE '%<p>%' THEN svbtd.DESCRIPTION ELSE REPLACE(svbtd.DESCRIPTION,@nLine10,@nLine10 + '<br>') END AS Description,
			
	-- SITE > SERVICE > AKA NAMES
	(SELECT aka.Name, aka.Confidential, aka.Description FROM
		(SELECT
				ao.ALT_ORG AS Name,
				'false' AS Confidential,
				NULL AS Description
			FROM GBL_BT_ALTORG ao
			WHERE ao.NUM=svbt.NUM AND ao.LangID=svbtd.LangID
		UNION SELECT
				fo.FORMER_ORG AS Name,
				'false' AS Confidential,
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Former Name',@LabelLangOverride) + ISNULL(cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',@LabelLangOverride) + fo.DATE_OF_CHANGE,'') AS Description
			FROM GBL_BT_FORMERORG fo
			WHERE fo.NUM=svbt.NUM AND fo.LangID=svbtd.LangID
		UNION SELECT
				svbtd.LEGAL_ORG COLLATE Latin1_General_100_CS_AS AS Name,
				'false' AS Confidential,
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Legal Name',@LabelLangOverride) AS Description
			WHERE svbtd.LEGAL_ORG IS NOT NULL
		UNION SELECT
					svbtd.ORG_LEVEL_1
					+ ISNULL(', ' + CASE
						WHEN svbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2
						THEN svbtd.ORG_LEVEL_2
							+ ISNULL(', ' + CASE
								WHEN svbtd.ORG_LEVEL_3=btd.ORG_LEVEL_3
								THEN svbtd.ORG_LEVEL_3 + ISNULL(', ' + CASE WHEN svbtd.ORG_LEVEL_4=btd.ORG_LEVEL_4 THEN svbtd.ORG_LEVEL_4 ELSE NULL END,'')
								ELSE NULL END,'')
						ELSE NULL END,'')
					AS Name,
				'false' AS Confidential,
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Agency Name',@LangID) AS Description
			WHERE svbtd.ORG_LEVEL_1=btd.ORG_LEVEL_1
				AND NOT (
					(svbtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 OR (svbtd.ORG_LEVEL_2 IS NULL AND btd.ORG_LEVEL_2 IS NULL))
					AND (svbtd.ORG_LEVEL_3=btd.ORG_LEVEL_3 OR (svbtd.ORG_LEVEL_3 IS NULL AND btd.ORG_LEVEL_3 IS NULL))
					AND (svbtd.ORG_LEVEL_4=btd.ORG_LEVEL_4 OR (svbtd.ORG_LEVEL_4 IS NULL AND btd.ORG_LEVEL_4 IS NULL))
					AND (svbtd.ORG_LEVEL_5=btd.ORG_LEVEL_5 OR (svbtd.ORG_LEVEL_5 IS NULL AND btd.ORG_LEVEL_5 IS NULL))
				)
		) aka
	FOR XML PATH('AKA'), TYPE),

	-- SITE > SERVICE > PHONE
			(SELECT phone.*
				FROM (
				SELECT 'false' AS "@TollFree",
						'false' AS "@Confidential",
						svbtd.OFFICE_PHONE AS PhoneNumber,
						'Office' AS [Description],
						'Voice' AS [Type]
					WHERE svbtd.OFFICE_PHONE IS NOT NULL
				UNION SELECT 'false' AS "@TollFree",
						'false' AS "@Confidential",
						svcbtd.AFTER_HRS_PHONE AS PhoneNumber,
						'After Hours' AS [Description],
						'Voice' AS [Type]
					WHERE svcbtd.AFTER_HRS_PHONE IS NOT NULL
				UNION SELECT 'false' AS "@TollFree",
						'false' AS "@Confidential",
						svcbtd.CRISIS_PHONE AS PhoneNumber,
						'Crisis' AS [Description],
						'Voice' AS [Type]
					WHERE svcbtd.CRISIS_PHONE IS NOT NULL
				UNION SELECT 'false' AS "@TollFree",
						'false' AS "@Confidential",
						svbtd.FAX AS PhoneNumber,
						'Fax' AS [Description],
						'Fax' AS [Type]
					WHERE svbtd.FAX IS NOT NULL
				UNION SELECT 'false' AS "@TollFree",
						'false' AS "@Confidential",
						svcbtd.TDD_PHONE AS PhoneNumber,
						'TTY/TDD' AS [Description],
						'TTY/TDD' AS [Type]
					WHERE svcbtd.TDD_PHONE IS NOT NULL
				UNION SELECT
						'true' AS "@TollFree",
						'false' AS "@Confidential",
						svbtd.TOLL_FREE_PHONE AS PhoneNumber,
						'Toll Free' AS [Description],
						'Voice' AS [Type]
					WHERE svbtd.TOLL_FREE_PHONE IS NOT NULL
				) phone
			FOR XML PATH('Phone'), TYPE),
			
	-- SITE > SERVICE > URL
		(SELECT svbtd.WWW_ADDRESS AS Address
			WHERE svbtd.WWW_ADDRESS IS NOT NULL
			FOR XML PATH('URL'), TYPE),
		
	-- SITE > SERVICE > EMAIL
		(SELECT LTRIM(ItemID) AS Address
			FROM dbo.fn_GBL_ParseVarCharIDList(svbtd.E_MAIL,',')
			WHERE svbtd.E_MAIL IS NOT NULL
			FOR XML PATH('Email'), TYPE),
		
	-- SITE > SERVICE > CONTACT
		(SELECT 

	-- SITE > SERVICE > CONTACT > TYPE
			(SELECT ISNULL(FieldDisplay,FieldName)
				FROM GBL_FieldOption fo
				LEFT JOIN GBL_FieldOption_Description fod
					ON fo.FieldID=fod.FieldID AND fod.LangID=@LabelLangOverride
				WHERE fo.FieldName=c.GblContactType) AS "@Type",

	-- SITE > SERVICE > CONTACT > TITLE
			c.TITLE AS Title,

	-- SITE > SERVICE > CONTACT > NAME
			c.CMP_Name AS Name,

	-- SITE > SERVICE > CONTACT > EMAIL
			(SELECT LTRIM(ItemID) AS Address FROM dbo.fn_GBL_ParseVarCharIDList(c.EMAIL,',') FOR XML PATH('Email'), TYPE),

	-- SITE > SERVICE > CONTACT > PHONE
			(SELECT 
					'false' AS "@TollFree",
					'false' AS "@Confidential",
					CASE WHEN c.PHONE_1_NOTE IS NULL AND c.PHONE_1_NO IS NULL AND c.PHONE_1_EXT IS NULL AND c.PHONE_1_OPTION IS NULL
						THEN NULL
						ELSE ISNULL(c.PHONE_1_NOTE,'')
							+ CASE WHEN c.PHONE_1_NO IS NULL THEN '' ELSE CASE WHEN c.PHONE_1_NOTE IS NULL THEN '' ELSE ' ' END + c.PHONE_1_NO END
							+ CASE WHEN c.PHONE_1_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_1_NOTE,c.PHONE_1_NO) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_1_OPTION END
							+ CASE WHEN c.PHONE_1_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_1_NOTE,c.PHONE_1_NO,c.PHONE_1_OPTION) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_1_EXT END
						END AS PhoneNumber,
					c.PHONE_1_TYPE AS Type
				WHERE c.CMP_Phone1 IS NOT NULL
				FOR XML PATH('Phone'), TYPE),
			(SELECT 
					'false' AS "@TollFree",
					'false' AS "@Confidential",
					CASE WHEN c.PHONE_2_NOTE IS NULL AND c.PHONE_2_NO IS NULL AND c.PHONE_2_EXT IS NULL AND c.PHONE_2_OPTION IS NULL
						THEN NULL
						ELSE ISNULL(c.PHONE_2_NOTE,'')
							+ CASE WHEN c.PHONE_2_NO IS NULL THEN '' ELSE CASE WHEN c.PHONE_2_NOTE IS NULL THEN '' ELSE ' ' END + c.PHONE_2_NO END
							+ CASE WHEN c.PHONE_2_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_2_NOTE,c.PHONE_2_NO) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_2_OPTION END
							+ CASE WHEN c.PHONE_2_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_2_NOTE,c.PHONE_2_NO,c.PHONE_2_OPTION) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_2_EXT END
						END AS PhoneNumber,
					c.PHONE_2_TYPE AS Type
				WHERE c.CMP_Phone2 IS NOT NULL
				FOR XML PATH('Phone'), TYPE),
				(SELECT 
					'false' AS "@TollFree",
					'false' AS "@Confidential",
					CASE WHEN c.PHONE_3_NOTE IS NULL AND c.PHONE_3_NO IS NULL AND c.PHONE_3_EXT IS NULL AND c.PHONE_3_OPTION IS NULL
						THEN NULL
						ELSE ISNULL(c.PHONE_3_NOTE,'')
							+ CASE WHEN c.PHONE_3_NO IS NULL THEN '' ELSE CASE WHEN c.PHONE_3_NOTE IS NULL THEN '' ELSE ' ' END + c.PHONE_3_NO END
							+ CASE WHEN c.PHONE_3_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_3_NOTE,c.PHONE_3_NO) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_3_OPTION END
							+ CASE WHEN c.PHONE_3_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_3_NOTE,c.PHONE_3_NO,c.PHONE_3_OPTION) IS NULL THEN '' ELSE ' ' END 
								+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_3_EXT END
						END AS PhoneNumber,
					c.PHONE_3_TYPE AS Type
				WHERE c.CMP_Phone3 IS NOT NULL
				FOR XML PATH('Phone'), TYPE),
			(SELECT 
					'false' AS "@TollFree",
					'false' AS "@Confidential",
					c.CMP_Fax AS PhoneNumber,
					'Fax' AS Type
				WHERE c.CMP_Fax IS NOT NULL
				FOR XML PATH('Phone'), TYPE)

			FROM GBL_Contact c
			WHERE c.GblNUM=svbtd.NUM AND c.LangID=svbtd.LangID
				AND c.CMP_Name IS NOT NULL
				AND c.GblContactType IN ('CONTACT_1','CONTACT_2')
			FOR XML PATH('Contact'), TYPE
		),			
			
	-- SITE > SERVICE > TIME OPEN
			(SELECT CASE
					WHEN svcbtd.HOURS IS NULL THEN CASE WHEN svcbtd.DATES IS NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Meetings',@LangID) + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',@LangID) + svcbtd.MEETINGS ELSE + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Dates',@LangID) +  + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',@LangID) + svcbtd.DATES + ISNULL(@nLine + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Meetings',@LangID) + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',@LangID) + svcbtd.MEETINGS,'') END
					ELSE svcbtd.HOURS + ISNULL(@nLine + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Dates',@LangID) + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',@LangID) + svcbtd.DATES,'') + ISNULL(@nLine + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Meetings',@LangID) + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(': ',@LangID) + svcbtd.MEETINGS,'')
					END AS Notes
				WHERE svcbtd.HOURS IS NOT NULL OR svcbtd.DATES IS NOT NULL FOR XML PATH(''), TYPE) AS TimeOpen,
			
	-- SITE > SERVICE > TAXONOMY
			(SELECT (SELECT Code FROM CIC_BT_TAX_TM WHERE BT_TAX_ID=tax.BT_TAX_ID FOR XML PATH(''), TYPE)
				FROM CIC_BT_TAX tax
				WHERE tax.NUM=svbt.NUM
				FOR XML PATH('Taxonomy'), TYPE),
			(SELECT
				'Z' AS Code
				WHERE NOT EXISTS(SELECT * FROM CIC_BT_TAX tax WHERE tax.NUM=svbt.NUM)
				FOR XML PATH('Taxonomy'), TYPE),
				
	-- SITE > SERVICE > LANGUAGES
			(SELECT Name, Notes
				FROM (SELECT
							lnn.Name,
							CASE WHEN lprn.Notes IS NULL AND NOT EXISTS(SELECT * FROM CIC_BT_LN_LND WHERE BT_LN_ID=lpr.BT_LN_ID) THEN NULL ELSE
								ISNULL((SELECT STUFF((SELECT ', ' + ISNULL(lndn.Name,lnd.Code)
									FROM dbo.CIC_BT_LN_LND prlnd
									INNER JOIN dbo.GBL_Language_Details lnd
										ON lnd.LND_ID = prlnd.LND_ID
									LEFT JOIN dbo.GBL_Language_Details_Name lndn
										ON lndn.LND_ID = lnd.LND_ID AND lndn.LangID=svbtd.LangID
									WHERE prlnd.BT_LN_ID=lpr.BT_LN_ID
									FOR XML PATH('')) ,1,2,'')),'')
								+ CASE WHEN lprn.Notes IS NULL THEN ''
									ELSE CASE WHEN EXISTS(SELECT * FROM dbo.CIC_BT_LN_LND prlnd WHERE prlnd.BT_LN_ID=lpr.BT_LN_ID)
									THEN ', ' ELSE '' END + lprn.Notes END
							END AS Notes
						FROM CIC_BT_LN lpr
						LEFT JOIN CIC_BT_LN_Notes lprn
							ON lpr.BT_LN_ID=lprn.BT_LN_ID AND lprn.LangID=svbtd.LangID
						INNER JOIN GBL_Language ln
							ON lpr.LN_ID=ln.LN_ID
						INNER JOIN GBL_Language_Name lnn
							ON ln.LN_ID=lnn.LN_ID AND lnn.LangID=(SELECT TOP 1 LangID FROM GBL_Language_Name WHERE LN_ID=lnn.LN_ID ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
						WHERE lpr.NUM=svbt.NUM
					UNION SELECT
						cioc_shared.dbo.fn_SHR_STP_ObjectName('Other') AS Name,
						svcbtd.LANGUAGE_NOTES
						WHERE svcbtd.LANGUAGE_NOTES IS NOT NULL
					) lang
				WHERE svcbtd.CMP_Languages IS NOT NULL
				FOR XML PATH('Languages'), TYPE
			),
	
	-- SITE > SERVICE > GEOGRAPHIC AREA SERVED
			(SELECT 
					(SELECT
						CAST(N'<' + excm.AIRSExportType + N'>' + (SELECT excm.AreaName AS [text()] FOR XML PATH('')) + N'</' + excm.AIRSExportType + N'>' AS xml) AS [node()]
						FROM (SELECT DISTINCT excm.AIRSExportType, excm.AreaName, cmat.[Order]
							FROM CIC_BT_CM cpr
							INNER JOIN GBL_Community cm
								ON cpr.CM_ID=cm.CM_ID
							INNER JOIN GBL_Community_External_Map_All map
								ON cm.CM_ID=map.CM_ID AND map.SystemCode = 'ONTARIO211'
							INNER JOIN GBL_Community_External_Community excm
								ON excm.EXT_ID=map.EXT_ID
							LEFT JOIN dbo.GBL_Community_AIRSType cmat
								ON cmat.AIRSExportType = excm.AIRSExportType
							WHERE cpr.NUM=svbt.NUM
						) AS excm
						ORDER BY excm.[Order]
						FOR XML PATH(''), TYPE
					),
					REPLACE(REPLACE(svcbtd.CMP_AreasServed,CHAR(13),''),CHAR(10),' ; ') AS [Description]
				WHERE svcbtd.CMP_AreasServed IS NOT NULL
				FOR XML PATH('GeographicAreaServed'), TYPE
			),
	
	-- SITE > SERVICE > RESOURCE INFO
			(SELECT 
					CASE WHEN (svbtd.DELETION_DATE IS NOT NULL AND svbtd.DELETION_DATE <= GETDATE()) OR svbtd.NON_PUBLIC=1 THEN 'false' ELSE 'true' END AS "@AvailableForDirectory",
					CASE WHEN (svbtd.DELETION_DATE IS NOT NULL AND svbtd.DELETION_DATE <= GETDATE()) THEN 'false' ELSE 'true' END AS "@AvailableForReferral",
					CASE WHEN (svbtd.DELETION_DATE IS NOT NULL AND svbtd.DELETION_DATE <= GETDATE()) THEN 'false' ELSE 'true' END AS "@AvailableForResearch",
					CAST(svbtd.CREATED_DATE AS date) AS "@DateAdded",
					CAST(svbtd.UPDATE_DATE AS date) AS "@DateLastVerified",
					CAST(svbtd.MODIFIED_DATE AS date) AS "@DateOfLastAction",
					(SELECT
						'Source' AS "@Type",
						svbtd.SOURCE_TITLE AS Title,
						svbtd.SOURCE_NAME AS Name,
						(SELECT LTRIM(ItemID) AS Address FROM dbo.fn_GBL_ParseVarCharIDList(svbtd.SOURCE_EMAIL,',') FOR XML PATH('Email'), TYPE),
						(SELECT 
								'false' AS "@TollFree",
								'false' AS "@Confidential",
								svbtd.SOURCE_PHONE AS PhoneNumber,
								'Voice' AS Type
							WHERE svbtd.SOURCE_PHONE IS NOT NULL
							FOR XML PATH('Phone'), TYPE),
						(SELECT 
								'false' AS "@TollFree",
								'false' AS "@Confidential",
								svbtd.SOURCE_FAX AS PhoneNumber,
								'Fax' AS Type
							WHERE svbtd.SOURCE_FAX IS NOT NULL
							FOR XML PATH('Phone'), TYPE)
						WHERE svbtd.SOURCE_NAME IS NOT NULL
						FOR XML PATH('Contact'), TYPE),
					svbtd.UPDATED_BY AS ResourceSpecialist
				FOR XML PATH('ResourceInfo'), TYPE
			),
	-- SITE > SERVICE > APPLICATION PROCESS
				(SELECT '1' AS Step,
						svcbtd.APPLICATION AS Description
					WHERE svcbtd.APPLICATION IS NOT NULL FOR XML PATH(''), TYPE) AS ApplicationProcess,
				
	-- SITE > SERVICE > FEE STRUCTURE
				svcbtd.CMP_Fees AS FeeStructure,
				
	-- SITE > SERVICE > OTHER REQUIREMENTS
				svcbtd.ELIGIBILITY_NOTES AS OtherRequirements,
				
	-- SITE > SERVICE > AGE REQUIREMENTS
				cioc_shared.dbo.fn_SHR_CIC_FullEligibility(MIN_AGE, MAX_AGE, NULL) AS AgeRequirements,
				
	-- SITE > SERVICE > RESIDENCY REQUIREMENTS
				svcbtd.BOUNDARIES AS ResidencyRequirements,

	-- SITE > SERVICE > COMMENTS
	(SELECT svcbtd.COMMENTS AS Notes
		WHERE svcbtd.COMMENTS IS NOT NULL) AS InternalNote,
	(SELECT svcbtd.CMP_InternalMemo AS Notes
		WHERE svcbtd.CMP_InternalMemo IS NOT NULL) AS EditorsNote,
	(SELECT svcbtd.PUBLIC_COMMENTS AS Notes
		WHERE svcbtd.PUBLIC_COMMENTS IS NOT NULL) AS PublicNote
				
			FROM GBL_BaseTable svbt
			INNER JOIN GBL_BaseTable_Description svbtd
				ON svbt.NUM=svbtd.NUM AND svbtd.LangID=@LangID
					AND (@CanSeeNonPublic=1 OR svbtd.NON_PUBLIC=0)
					AND (svbtd.DELETION_DATE IS NULL OR svbtd.DELETION_DATE > GETDATE())
					AND (@HidePastDueBy IS NULL OR (svbtd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,svbtd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
			LEFT JOIN CIC_BaseTable svcbt
				ON svbt.NUM = svcbt.NUM
			LEFT JOIN CIC_BaseTable_Description svcbtd
				ON svcbt.NUM=svcbtd.NUM AND svcbtd.LangID=svbtd.LangID
			WHERE (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=slbt.NUM AND PB_ID=@PB_ID))
				AND (svbt.MemberID=@MemberID
						OR EXISTS(SELECT *
							FROM GBL_BT_SharingProfile pr
							INNER JOIN GBL_SharingProfile shp
								ON pr.ProfileID=shp.ProfileID
									AND shp.Active=1
									AND (
										shp.CanUseAnyView=1
										OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
									)
							WHERE NUM=svbt.NUM AND ShareMemberID_Cache=@MemberID)
					)
				AND (slbt.NUM=svbt.NUM)
				AND EXISTS(SELECT * FROM GBL_BT_OLS spr INNER JOIN GBL_OrgLocationService sols ON spr.OLS_ID=sols.OLS_ID AND sols.Code IN ('SERVICE','TOPIC') WHERE spr.NUM=svbt.NUM)
				AND (
					@DST_ID IS NULL
					OR EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=svbt.NUM)
				)
		FOR XML PATH('SiteService'), TYPE
		),
		
	-- SITE > SPATIAL LOCATION
		(SELECT
			slbtd.GEOCODE_NOTES AS [Description],
			'WGS84' AS Datum,
			CASE WHEN slbt.LATITUDE > 0 THEN '+' ELSE '' END + CAST(slbt.LATITUDE AS varchar(30)) AS Latitude,
			CASE WHEN slbt.LONGITUDE > 0 THEN '+' ELSE '' END + CAST(slbt.LONGITUDE AS varchar(30)) AS Longitude
			WHERE slbt.LATITUDE IS NOT NULL
				AND slbt.NUM=slbtd.NUM
			FOR XML PATH('SpatialLocation'),TYPE
		),
		
	-- SITE > COMMENTS
		(SELECT slcbtd.COMMENTS AS Notes
		WHERE slcbtd.COMMENTS IS NOT NULL) AS InternalNote,
		(SELECT slcbtd.CMP_InternalMemo AS Notes
			WHERE slcbtd.CMP_InternalMemo IS NOT NULL) AS EditorsNote,
		(SELECT slcbtd.PUBLIC_COMMENTS AS Notes
			WHERE slcbtd.PUBLIC_COMMENTS IS NOT NULL) AS PublicNote,
			
	-- SITE > LOCATED IN COMMUNITY
		(SELECT
				excm.AIRSExportType AS 'LocatedInCommunity/@Type',
				AreaName AS LocatedInCommunity
				FROM dbo.GBL_Community_External_Map cmap
				INNER JOIN dbo.GBL_Community_External_Community excm
					ON excm.EXT_ID = cmap.MapOneEXTID AND excm.SystemCode='ONTARIO211'
				WHERE cmap.CM_ID=slbt.LOCATED_IN_CM
				FOR XML PATH(''),TYPE)

		FROM GBL_BaseTable slbt
		LEFT JOIN GBL_BaseTable_Description slbtd
			ON slbtd.LangID=@LangID
				AND slbtd.NUM = CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS lpr INNER JOIN GBL_OrgLocationService lols ON lpr.OLS_ID=lols.OLS_ID AND lols.Code='SITE' WHERE lpr.NUM=slbt.NUM) THEN slbt.NUM ELSE 'ZZZ00002' END
				AND (
						(
							(@CanSeeNonPublic=1 OR slbtd.NON_PUBLIC=0)
							AND (slbtd.DELETION_DATE IS NULL OR slbtd.DELETION_DATE > GETDATE())
							AND (@HidePastDueBy IS NULL OR (slbtd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,slbtd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
						) OR (
							slbtd.NUM='ZZZ00002'
						)
					)
		LEFT JOIN CIC_BaseTable cslbt
			ON slbtd.NUM=cslbt.NUM
		LEFT JOIN CIC_BaseTable_Description slcbtd
			ON cslbt.NUM=slcbtd.NUM AND slcbtd.LangID=slbtd.LangID
		WHERE slbtd.NUM IS NOT NULL
			AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=slbt.NUM AND PB_ID=@PB_ID))
			AND (slbt.MemberID=@MemberID
					OR EXISTS(SELECT *
						FROM GBL_BT_SharingProfile pr
						INNER JOIN GBL_SharingProfile shp
							ON pr.ProfileID=shp.ProfileID
								AND shp.Active=1
								AND (
									shp.CanUseAnyView=1
									OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
								)
						WHERE NUM=slbt.NUM AND ShareMemberID_Cache=@MemberID)
				)
			AND (slbt.NUM=bt.NUM OR slbt.ORG_NUM=bt.NUM)
			AND (
				EXISTS(SELECT * FROM GBL_BT_OLS lpr INNER JOIN GBL_OrgLocationService lols ON lpr.OLS_ID=lols.OLS_ID AND lols.Code='SITE' WHERE lpr.NUM=slbt.NUM)
				OR (
					NOT EXISTS(SELECT * FROM GBL_BT_OLS lpr INNER JOIN GBL_OrgLocationService lols ON lpr.OLS_ID=lols.OLS_ID AND lols.Code='SITE' WHERE lpr.NUM=slbt.NUM)
					AND NOT EXISTS(SELECT * FROM GBL_BT_LOCATION_SERVICE WHERE SERVICE_NUM=slbt.NUM)
					AND EXISTS(SELECT * FROM GBL_BT_OLS lpr INNER JOIN GBL_OrgLocationService lols ON lpr.OLS_ID=lols.OLS_ID AND lols.Code IN ('SERVICE','TOPIC') WHERE lpr.NUM=slbt.NUM)
				)
			)
			AND (
				@DST_ID IS NULL
				OR EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=slbt.NUM)
				OR (@AutoIncludeSiteAgency=1 AND EXISTS(SELECT * FROM GBL_BT_LOCATION_SERVICE ls WHERE ls.LOCATION_NUM=slbt.NUM AND EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=ls.SERVICE_NUM)))
			)
	FOR XML PATH('Site'), TYPE
	),

	-- RESOURCE INFO
	(SELECT 
			CASE WHEN (btd.DELETION_DATE IS NOT NULL AND btd.DELETION_DATE <= GETDATE()) OR btd.NON_PUBLIC=1 THEN 'false' ELSE 'true' END AS "@AvailableForDirectory",
			CASE WHEN (btd.DELETION_DATE IS NOT NULL AND btd.DELETION_DATE <= GETDATE()) THEN 'false' ELSE 'true' END AS "@AvailableForReferral",
			CASE WHEN (btd.DELETION_DATE IS NOT NULL AND btd.DELETION_DATE <= GETDATE()) THEN 'false' ELSE 'true' END AS "@AvailableForResearch",
			CAST(btd.CREATED_DATE AS date) AS "@DateAdded",
			CAST(btd.UPDATE_DATE AS date) AS "@DateLastVerified",
			CAST(btd.MODIFIED_DATE AS date) AS "@DateOfLastAction",
			(SELECT
				'Source' AS "@Type",
				btd.SOURCE_TITLE AS Title,
				btd.SOURCE_NAME AS Name,
				(SELECT LTRIM(ItemID) AS Address FROM dbo.fn_GBL_ParseVarCharIDList(btd.SOURCE_EMAIL,',') FOR XML PATH('Email'), TYPE),
				(SELECT 
						'false' AS "@TollFree",
						'false' AS "@Confidential",
						btd.SOURCE_PHONE AS PhoneNumber,
						'Voice' AS Type
					WHERE btd.SOURCE_PHONE IS NOT NULL
					FOR XML PATH('Phone'), TYPE),
				(SELECT 
						'false' AS "@TollFree",
						'false' AS "@Confidential",
						btd.SOURCE_FAX AS PhoneNumber,
						'Fax' AS Type
					WHERE btd.SOURCE_FAX IS NOT NULL
					FOR XML PATH('Phone'), TYPE)
				WHERE btd.SOURCE_NAME IS NOT NULL
				FOR XML PATH('Contact'), TYPE),
			btd.UPDATED_BY AS ResourceSpecialist
		FOR XML PATH('ResourceInfo'), TYPE
	),
	
	-- COMMENTS
	(SELECT cbtd.COMMENTS AS Notes
		WHERE cbtd.COMMENTS IS NOT NULL) AS InternalNote,
	(SELECT cbtd.CMP_InternalMemo AS Notes
		WHERE cbtd.CMP_InternalMemo IS NOT NULL) AS EditorsNote,
	(SELECT cbtd.PUBLIC_COMMENTS AS Notes
		WHERE cbtd.PUBLIC_COMMENTS IS NOT NULL) AS PublicNote
	FOR XML PATH('Agency')
)
				
FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=@LangID
			AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
			AND (
				btd.DELETION_DATE IS NULL
				OR btd.DELETION_DATE > GETDATE()
				OR (
					@CanSeeDeleted=1
					AND @AutoIncludeSiteAgency=1
					AND (
						@DST_ID IS NULL
						OR EXISTS(SELECT * FROM GBL_BaseTable slbt INNER JOIN GBL_BaseTable_Description slbtd ON slbt.NUM=slbtd.NUM AND slbtd.LangID=@LangID AND slbtd.DELETION_DATE IS NULL WHERE ORG_NUM=bt.NUM
							AND EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=slbt.NUM)
						)
					)
				)
			)
			AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
	LEFT JOIN CIC_BaseTable cbt
		ON bt.NUM = cbt.NUM
	LEFT JOIN CIC_BaseTable_Description cbtd
		ON cbt.NUM=cbtd.NUM AND cbtd.LangID=btd.LangID
WHERE (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
	AND (bt.MemberID=@MemberID
			OR EXISTS(SELECT *
				FROM GBL_BT_SharingProfile pr
				INNER JOIN GBL_SharingProfile shp
					ON pr.ProfileID=shp.ProfileID
						AND shp.Active=1
						AND (
							shp.CanUseAnyView=1
							OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
						)
				WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
		)
	AND EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code='AGENCY' WHERE pr.NUM=bt.NUM)
	AND (
		@DST_ID IS NULL
		OR EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=bt.NUM)
		OR (@AutoIncludeSiteAgency=1 AND EXISTS(SELECT * FROM GBL_BaseTable slbt WHERE ORG_NUM=bt.NUM AND EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=slbt.NUM)))
	)
	AND (
		@PartialDate IS NULL
		OR EXISTS(
		SELECT *
			FROM GBL_BaseTable btx
			INNER JOIN dbo.CIC_BaseTable cbtx ON cbtx.NUM = btx.NUM
			INNER JOIN dbo.GBL_BaseTable_Description btdx ON btdx.NUM = btx.NUM AND btdx.LangID=@LangID
			LEFT JOIN dbo.CIC_BT_DST dst ON dst.NUM=btx.NUM AND dst.DST_ID=@DST_ID
			LEFT JOIN dbo.GBL_BT_SharingProfile shp ON shp.NUM=btx.NUM AND shp.ShareMemberID_Cache=@MemberID
			WHERE (btx.NUM=bt.NUM OR btx.ORG_NUM=bt.NUM)
				AND (SELECT MAX(ModDate) FROM (VALUES (btdx.MODIFIED_DATE),(dst.CREATED_DATE),(shp.CREATED_DATE),(cbtx.TAX_MODIFIED_DATE),(btdx.DELETION_DATE)) AS DateTb(ModDate)) >= @PartialDate
		)
	)
	AND (
		@AgencyNUM IS NULL OR bt.NUM=@AgencyNUM
	)
ORDER BY bt.NUM

RETURN @Error

SET NOCOUNT OFF

--DELETE FROM GBL_BT_LOCATION_SERVICE where LOCATION_NUM='ZZZ00002'






GO













GRANT EXECUTE ON  [dbo].[sp_GBL_AIRS_Export_3_0] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_AIRS_Export_3_0] TO [cioc_login_role]
GO
