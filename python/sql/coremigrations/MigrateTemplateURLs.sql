
DECLARE @ShouldRunMigrationScript bit
SET @ShouldRunMigrationScript = 1
IF NOT EXISTS (SELECT 1 FROM [information_schema].[Tables] WHERE table_schema = 'dbo' AND TABLE_NAME IN ('GBL_Template', 'GBL_Template_Description', 'GBL_Template_Menu'))
BEGIN
     SET @ShouldRunMigrationScript = 0;
     PRINT 'Target tables could not be found - skipping migration.';
END

IF @ShouldRunMigrationScript=1 
BEGIN

UPDATE GBL_Template SET 
	ShortCutIcon=CASE WHEN ShortCutIcon IS NULL OR ShortCutIcon LIKE 'http://%' THEN ShortCutIcon ELSE 'http://' + ShortCutIcon END,
	AppleTouchIcon=CASE WHEN AppleTouchIcon IS NULL OR AppleTouchIcon LIKE 'http://%' THEN AppleTouchIcon ELSE 'http://' + AppleTouchIcon END,
	StylesheetUrl=CASE WHEN StylesheetUrl IS NULL OR StylesheetUrl LIKE 'http://%' THEN StylesheetUrl ELSE 'http://' + StylesheetUrl END,
	JavascriptTopUrl=CASE WHEN JavascriptTopUrl IS NULL OR JavascriptTopUrl LIKE 'http://%' THEN JavascriptTopUrl ELSE 'http://' + JavascriptTopUrl END,
	JavaScriptBottomUrl=CASE WHEN JavaScriptBottomUrl IS NULL OR JavaScriptBottomUrl LIKE 'http://%' THEN JavaScriptBottomUrl ELSE 'http://' + JavaScriptBottomUrl END,
	Background=CASE WHEN Background IS NULL OR Background LIKE 'http://%' THEN Background ELSE 'http://' + Background END

UPDATE GBL_Template_Description SET
	Logo=CASE WHEN Logo IS NULL OR Logo LIKE 'http://%' THEN Logo ELSE 'http://' + Logo END,
	LogoLink=CASE WHEN LogoLink IS NULL OR LogoLink LIKE 'http://%' THEN LogoLink ELSE 'http://' + LogoLink END
	--SELECT Template_ID, Logo, LogoLink FROM GBL_Template_Description
	/*
UPDATE GBL_Template_Menu SET
	Link=CASE WHEN Link IS NULL OR Link LIKE 'http://%' THEN Link ELSE 'http://' + Link END
	*/
END

UPDATE dbo.GBL_PrintProfile SET
	StyleSheet=CASE WHEN StyleSheet IS NULL OR StyleSheet LIKE 'http://%' THEN StyleSheet ELSE 'http://' + StyleSheet END
WHERE StyleSheet IS NOT NULL

UPDATE dbo.VOL_CommunityGroup SET
	ImageURL=CASE WHEN ImageURL IS NULL OR ImageURL LIKE 'http://%' THEN ImageURL ELSE 'http://' + ImageURL END
WHERE ImageURL IS NOT NULL

UPDATE dbo.GBL_DownloadURL SET
	ResourceURL=CASE WHEN ResourceURL IS NULL OR ResourceURL LIKE 'http://%' THEN ResourceURL ELSE 'http://' + ResourceURL END
WHERE ResourceURL IS NOT NULL

UPDATE dbo.CIC_View_Description SET
	TermsOfUseURL=CASE WHEN TermsOfUseURL IS NULL OR TermsOfUseURL LIKE 'http://%' THEN TermsOfUseURL ELSE 'http://' + TermsOfUseURL END
WHERE TermsOfUseURL IS NOT NULL

UPDATE dbo.VOL_View_Description SET
	TermsOfUseURL=CASE WHEN TermsOfUseURL IS NULL OR TermsOfUseURL LIKE 'http://%' THEN TermsOfUseURL ELSE 'http://' + TermsOfUseURL END
WHERE TermsOfUseURL IS NOT NULL

UPDATE dbo.TAX_Term SET
	IconURL=CASE WHEN IconURL IS NULL OR IconURL LIKE 'http://%' THEN IconURL ELSE 'http://' + IconURL END
WHERE IconURL IS NOT NULL

UPDATE CIC_ExportProfile SET 
	SubmitChangesToAccessURL=
		CASE WHEN LEN(SubmitChangesToAccessURL) - LEN(REPLACE(SubmitChangesToAccessURL,N' ',N'')) = 1 THEN 
			CASE WHEN cioc_shared.dbo.RegexMatch(SubmitChangesToAccessURL, N'\d+ [^ ]+') = 1 THEN
				cioc_shared.dbo.RegexReplace(SubmitChangesToAccessURL, N'(\d+)? ([^ ]+)', N'$1 $1 $2') 
			ELSE
				N' ' + CAST(ISNULL((SELECT CICViewType
					FROM GBL_View_DomainMap mp
					WHERE mp.DomainName=REPLACE(SubmitChangesToAccessURL, N' ', N'')),
					(SELECT DefaultViewCIC FROM STP_Member m WHERE m.MemberID=CIC_ExportProfile.MemberID)) AS nvarchar(30)) + N' ' + REPLACE(SubmitChangesToAccessURL, N' ', N'')
					
			END
		ELSE 
			SubmitChangesToAccessURL
		END
WHERE SubmitChangesToAccessURL IS NOT NULL


UPDATE dbo.GBL_MappingSystem_Name SET
	String=CASE WHEN String IS NULL OR String LIKE 'http://%' THEN String ELSE 'http://' + String END
WHERE String IS NOT NULL

UPDATE dbo.CIC_ExportProfile_Description SET
	SourceDbURL=CASE WHEN SourceDbURL IS NULL OR SourceDbURL LIKE 'http://%' THEN SourceDbURL ELSE 'http://' + SourceDbURL END
WHERE SourceDbURL IS NOT NULL

UPDATE CIC_ImportEntry_Description SET
	SourceDbURL=CASE WHEN SourceDbURL IS NULL OR SourceDbURL LIKE 'http://%' THEN SourceDbURL ELSE 'http://' + SourceDbURL END
WHERE SourceDbURL IS NOT NULL

INSERT INTO VOL_View_UpdateField (ViewType, FieldID)
SELECT ViewType, (SELECT FieldID FROM VOL_FieldOption WHERE FieldName='VNUM') AS FieldID
FROM VOL_View
WHERE NOT EXISTS(SELECT * FROM VOL_View_UpdateField WHERE ViewType=VOL_View.ViewType AND FieldID=(SELECT FieldID FROM VOL_FieldOption WHERE FieldName='VNUM'))