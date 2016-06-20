DECLARE @MemberID int, @xmlData xml
SET @MemberID=500

DECLARE @LoadCode varchar(10), @ObjectType varchar(50)
SET @LoadCode='dp092014'

-- Member 1
IF 0=1 BEGIN

SET @ObjectType='Member'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

SET IDENTITY_INSERT dbo.STP_Member ON

INSERT INTO [OntarioCioc_2012_11].[dbo].[STP_Member]
           ([MemberID]
           ,[CREATED_DATE]
           ,[CREATED_BY]
           ,[MODIFIED_DATE]
           ,[MODIFIED_BY]
           ,[Active]
           ,[DatabaseCode]
           ,[DefaultLangID]
           ,[AllowPublicAccess]
           ,[DefaultTemplate]
           ,[DefaultPrintTemplate]
           ,[PrintModePublic]
           ,[TrainingMode]
           ,[UseInitials]
           ,[DaysSinceLastEmail]
           ,[DefaultEmailTech]
           ,[ClientTrackerIP]
           ,[ClientTrackerRpcURL]
           ,[DefaultGCType]
           ,[DefaultCountry]
           ,[NoEmail]
           ,[DownloadUncompressed]
           ,[UseCIC]
           ,[DefaultViewCIC]
           ,[BaseURLCIC]
           ,[DefaultEmailCIC]
           ,[SiteCodeLength]
           ,[UseTaxonomy]
           ,[VacancyFundedCapacity]
           ,[VacancyServiceHours]
           ,[VacancyServiceDays]
           ,[VacancyServiceWeeks]
           ,[VacancyServiceFTE]
           ,[CanDeleteRecordNoteCIC]
           ,[CanUpdateRecordNoteCIC]
           ,[RecordNoteTypeOptionalCIC]
           ,[PreventDuplicateOrgNames]
           ,[UseLowestNUM]
           ,[UseOfflineTools]
           ,[UseVOL]
           ,[DefaultViewVOL]
           ,[BaseURLVOL]
           ,[DefaultEmailVOL]
           ,[UseVolunteerProfiles]
           ,[LastVolProfileEmailDate]
           ,[DefaultEmailVOLProfile]
           ,[CanDeleteRecordNoteVOL]
           ,[CanUpdateRecordNoteVOL]
           ,[RecordNoteTypeOptionalVOL]
           ,[DownloadPasswordCIC]
           ,[DownloadPasswordVOL]
           ,[OnlySpecificInterests]
           ,[LoginRetryLimit]
           ,[DefaultProvince])
SELECT
	N.value('MemberID[1]', 'int'),
	N.value('CREATED_DATE[1]', 'smalldatetime'),
	N.value('CREATED_BY[1]', 'varchar(50)'),
	N.value('MODIFIED_DATE[1]', 'smalldatetime'),
	N.value('MODIFIED_BY[1]', 'varchar(50)'),
	N.value('Active[1]', 'bit'),
	N.value('DatabaseCode[1]', 'varchar(15)'),
	N.value('DefaultLangID[1]', 'smallint'),
	N.value('AllowPublicAccess[1]', 'bit'),
	(SELECT Template_ID FROM dbo.GBL_Template WHERE SystemTemplate=1),
	(SELECT Template_ID FROM dbo.GBL_Template WHERE SystemTemplate=1),
	N.value('PrintModePublic[1]', 'bit'),
	N.value('TrainingMode[1]', 'bit'),
	N.value('UseInitials[1]', 'bit'),
	N.value('DaysSinceLastEmail[1]', 'smallint'),
	N.value('DefaultEmailTech[1]', 'varchar(60)'),
	N.value('ClientTrackerIP[1]', 'varchar(500)'),
	N.value('ClientTrackerRpcURL[1]', 'varchar(200)'),
	N.value('DefaultGCType[1]', 'tinyint'),
	N.value('DefaultCountry[1]', 'nvarchar(60)'),
	N.value('NoEmail[1]', 'bit'),
	N.value('DownloadUncompressed[1]', 'bit'),
	N.value('UseCIC[1]', 'bit'),
	NULL,
	N.value('BaseURLCIC[1]', 'varchar(100)'),
	N.value('DefaultEmailCIC[1]', 'varchar(60)'),
	N.value('SiteCodeLength[1]', 'tinyint'),
	N.value('UseTaxonomy[1]', 'bit'),
	N.value('VacancyFundedCapacity[1]', 'bit'),
	N.value('VacancyServiceHours[1]', 'bit'),
	N.value('VacancyServiceDays[1]', 'bit'),
	N.value('VacancyServiceWeeks[1]', 'bit'),
	N.value('VacancyServiceFTE[1]', 'bit'),
	N.value('CanDeleteRecordNoteCIC[1]', 'tinyint'),
	N.value('CanUpdateRecordNoteCIC[1]', 'tinyint'),
	N.value('RecordNoteTypeOptionalCIC[1]', 'bit'),
	N.value('PreventDuplicateOrgNames[1]', 'tinyint'),
	N.value('UseLowestNUM[1]', 'bit'),
	N.value('UseOfflineTools[1]', 'bit'),
	N.value('UseVOL[1]', 'bit'),
	NULL,
	N.value('BaseURLVOL[1]', 'varchar(100)'),
	N.value('DefaultEmailVOL[1]', 'varchar(60)'),
	N.value('UseVolunteerProfiles[1]', 'bit'),
	N.value('LastVolProfileEmailDate[1]', 'smalldatetime'),
	N.value('DefaultEmailVOLProfile[1]', 'varchar(60)'),
	N.value('CanDeleteRecordNoteVOL[1]', 'tinyint'),
	N.value('CanUpdateRecordNoteVOL[1]', 'tinyint'),
	N.value('RecordNoteTypeOptionalVOL[1]', 'bit'),
	N.value('DownloadPasswordCIC[1]', 'nvarchar(20)'),
	N.value('DownloadPasswordVOL[1]', 'nvarchar(20)'),
	N.value('OnlySpecificInterests[1]', 'bit'),
	N.value('LoginRetryLimit[1]', 'tinyint'),
	N.value('DefaultProvince[1]', 'varchar(2)')
FROM @xmlData.nodes('//Member') as T(N)
	WHERE NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID)

SET IDENTITY_INSERT dbo.STP_Member OFF

INSERT INTO dbo.STP_Member_Description
        ( MemberID ,
          LangID ,
          CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          DatabaseNameCIC ,
          MemberName ,
          MemberNameCIC ,
          FeedbackMsgCIC ,
          DatabaseNameVOL ,
          MemberNameVOL ,
          FeedbackMsgVOL ,
          VolProfilePrivacyPolicy ,
          VolProfilePrivacyPolicyOrgName
        )
SELECT @MemberID,
		N.value('LangID[1]', 'smallint'),
		N.value('CREATED_DATE[1]', 'smalldatetime'),
		N.value('CREATED_BY[1]', 'varchar(50)'),
		N.value('MODIFIED_DATE[1]', 'smalldatetime'),
		N.value('MODIFIED_BY[1]', 'varchar(50)'),
		N.value('DatabaseNameCIC[1]', 'nvarchar(255)'),
		N.value('MemberName[1]', 'nvarchar(255)'),
		N.value('MemberNameCIC[1]', 'nvarchar(255)'),
		N.value('FeedbackMsgCIC[1]', 'nvarchar(max)'),
		N.value('DatabaseNameVOL[1]', 'nvarchar(255)'),
		N.value('MemberNameVOL[1]', 'nvarchar(255)'),
		N.value('FeedbackMsgVOL[1]', 'nvarchar(max)'),
		N.value('VolProfilePrivacyPolicy[1]', 'nvarchar(max)'),
        N.value('VolProfilePrivacyPolicyOrgName[1]', 'nvarchar(255)')
FROM @xmlData.nodes('//Member/Descriptions/Lang') as T(N)
	WHERE NOT EXISTS(SELECT * FROM dbo.STP_Member_Description WHERE MemberID=@MemberID AND LangID=N.value('LangID[1]', 'smallint'))

END

-- Layout
IF 0=1 BEGIN

SET @ObjectType='Layout'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @LayoutID int, @NewLayoutID int

DECLARE LayoutCursor CURSOR LOCAL FOR
SELECT
	N.value('LayoutID[1]', 'int')
FROM @xmlData.nodes('//Layout') as T(N)

OPEN LayoutCursor

FETCH NEXT FROM LayoutCursor INTO @LayoutID

WHILE @@FETCH_STATUS = 0 BEGIN

	INSERT INTO dbo.GBL_Template_Layout
	        ( CREATED_DATE ,
	          CREATED_BY ,
	          MODIFIED_DATE ,
	          MODIFIED_BY ,
	          MemberID ,
	          SystemLayout ,
	          Owner ,
	          LayoutType ,
	          DefaultSearchLayout ,
	          LayoutCSS ,
	          LayoutCSSURL ,
	          LayoutCSSVersionDate ,
	          AlmostStandardsMode
	        )
	SELECT
		N.value('CREATED_DATE[1]', 'smalldatetime'),
		N.value('CREATED_BY[1]', 'varchar(50)'),
		N.value('MODIFIED_DATE[1]', 'smalldatetime'),
		N.value('MODIFIED_BY[1]', 'varchar(50)'),
		N.value('MemberID[1]', 'int'),
		0,
		N.value('Owner[1]', 'char(3)'),
		N.value('LayoutType[1]', 'varchar(10)'),
		N.value('DefaultSearchLayout[1]', 'bit'),
		N.value('LayoutCSS[1]', 'varchar(max)'),
		N.value('LayoutCSSURL[1]', 'varchar(200)'),
		N.value('LayoutCSSVersionDate[1]', 'datetime'),
		N.value('AlmostStandardsMode[1]', 'bit')
	FROM @xmlData.nodes('//Layout') AS T(N)
	WHERE N.value('LayoutID[1]', 'int')=@LayoutID
		AND NOT EXISTS(SELECT * FROM dbo.GBL_Template_Layout tl
			INNER JOIN dbo.GBL_Template_Layout_Description tld ON tld.LayoutID = tl.LayoutID
			WHERE MemberID=@MemberID AND tld.LayoutName=N.value('LayoutName[1]', 'nvarchar(255)'))
	
	IF @@ROWCOUNT > 0 BEGIN
		SET @NewLayoutID=SCOPE_IDENTITY()
	END ELSE BEGIN
		SELECT @NewLayoutID=NULL
	END
	
	IF @NewLayoutID IS NOT NULL BEGIN
		INSERT INTO dbo.GBL_Template_Layout_Description
		        ( LayoutID ,
		          LangID ,
		          CREATED_DATE ,
		          CREATED_BY ,
		          MODIFIED_DATE ,
		          MODIFIED_BY ,
		          LayoutName ,
		          LayoutHTML ,
		          LayoutHTMLURL
		        )
		SELECT
				@NewLayoutID,
				N.value('LangID[1]', 'smallint'),
				N.value('CREATED_DATE[1]', 'smalldatetime'),
				N.value('CREATED_BY[1]', 'varchar(50)'),
				N.value('MODIFIED_DATE[1]', 'smalldatetime'),
				N.value('MODIFIED_BY[1]', 'varchar(50)'),
				N.value('LayoutName[1]', 'nvarchar(150)'),
				N.value('LayoutHTML[1]', 'nvarchar(max)'),
				N.value('LayoutHTMLURL[1]', 'varchar(200)')
		FROM @xmlData.nodes('//Layout/Descriptions/Lang') AS T(N)
			WHERE N.value('LayoutID[1]', 'int')=@LayoutID
	
	END

	FETCH NEXT FROM LayoutCursor INTO @LayoutID
END

DEALLOCATE LayoutCursor

END

-- Template

IF 0=1 BEGIN

SET @ObjectType='Template'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @TemplateID int, @NewTemplateID int

DECLARE TemplateCursor CURSOR LOCAL FOR
SELECT
	N.value('Template_ID[1]', 'int')
FROM @xmlData.nodes('//Template') as T(N)

OPEN TemplateCursor

FETCH NEXT FROM TemplateCursor INTO @TemplateID

WHILE @@FETCH_STATUS = 0 BEGIN

INSERT INTO dbo.GBL_Template
        ( CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          MemberID ,
          SystemTemplate ,
          Owner ,
          StyleSheetUrl ,
          JavaScriptTopUrl ,
          JavaScriptBottomUrl ,
          ShortCutIcon ,
          AppleTouchIcon ,
          BodyTagExtras ,
          Background ,
          BackgroundColour ,
          FontFamily ,
          FontColour ,
          FieldLabelColour ,
          MenuFontColour ,
          MenuBgColour ,
          TitleFontColour ,
          TitleBgColour ,
          LinkColour ,
          ALinkColour ,
          VLinkColour ,
          AlertColour ,
          HeaderLayout ,
          FooterLayout ,
          SearchLayoutCIC ,
          SearchLayoutVOL ,
          fcContent ,
          bgColorContent ,
          borderColorContent ,
          iconColorContent ,
          fcHeader ,
          bgColorHeader ,
          borderColorHeader ,
          iconColorHeader ,
          fcDefault ,
          bgColorDefault ,
          borderColorDefault ,
          iconColorDefault ,
          fcHover ,
          bgColorHover ,
          borderColorHover ,
          iconColorHover ,
          fcActive ,
          bgColorActive ,
          borderColorActive ,
          iconColorActive ,
          fcHighlight ,
          bgColorHighlight ,
          borderColorHighlight ,
          iconColorHighlight ,
          fcError ,
          bgColorError ,
          borderColorError ,
          iconColorError ,
          cornerRadius ,
          fsDefault ,
          TemplateCSSVersionDate ,
          TemplateCSSLayoutURLs ,
          AlmostStandardsMode
        )
	SELECT
		N.value('CREATED_DATE[1]', 'smalldatetime'),
		N.value('CREATED_BY[1]', 'varchar(50)'),
		N.value('MODIFIED_DATE[1]', 'smalldatetime'),
		N.value('MODIFIED_BY[1]', 'varchar(50)'),
		N.value('MemberID[1]', 'int'),
		N.value('SystemTemplate[1]', 'bit'),
		N.value('Owner[1]', 'char(3)'),
		N.value('StyleSheetUrl[1]', 'varchar(150)'),
		N.value('JavaScriptTopUrl[1]', 'varchar(150)'),
		N.value('JavaScriptBottomUrl[1]', 'varchar(150)'),
		N.value('ShortCutIcon[1]', 'varchar(150)'),
		N.value('AppleTouchIcon[1]', 'varchar(150)'),
		N.value('BodyTagExtras[1]', 'varchar(150)'),
		N.value('Background[1]', 'varchar(150)'),
		N.value('BackgroundColour[1]', 'varchar(7)'),
		N.value('FontFamily[1]', 'varchar(100)'),
		N.value('FontColour[1]', 'varchar(7)'),
		N.value('FieldLabelColour[1]', 'varchar(7)'),
		N.value('MenuFontColour[1]', 'varchar(7)'),
		N.value('MenuBgColour[1]', 'varchar(7)'),
		N.value('TitleFontColour[1]', 'varchar(7)'),
		N.value('TitleBgColour[1]', 'varchar(7)'),
		N.value('LinkColour[1]', 'varchar(7)'),
		N.value('ALinkColour[1]', 'varchar(7)'),
		N.value('VLinkColour[1]', 'varchar(7)'),
		N.value('AlertColour[1]', 'varchar(7)'),
		(SELECT TOP 1 tl.LayoutID FROM dbo.GBL_Template_Layout tl INNER JOIN dbo.GBL_Template_Layout_Description tld ON tld.LayoutID = tl.LayoutID AND (tl.MemberID=@MemberID OR tl.MemberID IS NULL) WHERE tld.LayoutName=N.value('HeaderLayoutName[1]', 'nvarchar(255)')),
		(SELECT TOP 1 tl.LayoutID FROM dbo.GBL_Template_Layout tl INNER JOIN dbo.GBL_Template_Layout_Description tld ON tld.LayoutID = tl.LayoutID AND (tl.MemberID=@MemberID OR tl.MemberID IS NULL) WHERE tld.LayoutName=N.value('FooterLayoutName[1]', 'nvarchar(255)')),
		(SELECT TOP 1 tl.LayoutID FROM dbo.GBL_Template_Layout tl INNER JOIN dbo.GBL_Template_Layout_Description tld ON tld.LayoutID = tl.LayoutID AND (tl.MemberID=@MemberID OR tl.MemberID IS NULL) WHERE tld.LayoutName=N.value('SearchLayoutCICName[1]', 'nvarchar(255)')),
		(SELECT TOP 1 tl.LayoutID FROM dbo.GBL_Template_Layout tl INNER JOIN dbo.GBL_Template_Layout_Description tld ON tld.LayoutID = tl.LayoutID AND (tl.MemberID=@MemberID OR tl.MemberID IS NULL) WHERE tld.LayoutName=N.value('SearchLayoutVOLName[1]', 'nvarchar(255)')),
		N.value('fcContent[1]', 'varchar(7)'),
		N.value('bgColorContent[1]', 'varchar(7)'),
		N.value('borderColorContent[1]', 'varchar(7)'),
		N.value('iconColorContent[1]', 'varchar(7)'),
		N.value('fcHeader[1]', 'varchar(7)'),
		N.value('bgColorHeader[1]', 'varchar(7)'),
		N.value('borderColorHeader[1]', 'varchar(7)'),
		N.value('iconColorHeader[1]', 'varchar(7)'),
		N.value('fcDefault[1]', 'varchar(7)'),
		N.value('bgColorDefault[1]', 'varchar(7)'),
		N.value('borderColorDefault[1]', 'varchar(7)'),
		N.value('iconColorDefault[1]', 'varchar(7)'),
		N.value('fcHover [1]', 'varchar(7)'),
		N.value('bgColorHover[1]', 'varchar(7)'),
		N.value('borderColorHover[1]', 'varchar(7)'),
		N.value('iconColorHover[1]', 'varchar(7)'),
		N.value('fcActive[1]', 'varchar(7)'),
		N.value('bgColorActive[1]', 'varchar(7)'),
		N.value('borderColorActive[1]', 'varchar(7)'),
		N.value('iconColorActive[1]', 'varchar(7)'),
		N.value('fcHighlight[1]', 'varchar(7)'),
		N.value('bgColorHighlight[1]', 'varchar(7)'),
		N.value('borderColorHighlight[1]', 'varchar(7)'),
		N.value('iconColorHighlight[1]', 'varchar(7)'),
		N.value('fcError [1]', 'varchar(7)'),
		N.value('bgColorError[1]', 'varchar(7)'),
		N.value('borderColorError[1]', 'varchar(7)'),
		N.value('iconColorError[1]', 'varchar(7)'),
		N.value('cornerRadius[1]', 'varchar(10)'),
		N.value('fsDefault[1]', 'varchar(10)'),
		N.value('TemplateCSSVersionDate[1]', 'datetime'),
		N.value('TemplateCSSLayoutURLs[1]', 'varchar(max)'),
		N.value('AlmostStandardsMode[1]', 'bit')
	FROM @xmlData.nodes('//Template') as T(N)
	WHERE N.value('Template_ID[1]', 'int')=@TemplateID
		AND NOT EXISTS(SELECT * FROM dbo.GBL_Template t
			INNER JOIN dbo.GBL_Template_Description td ON t.Template_ID=td.Template_ID
			WHERE MemberID=@MemberID AND td.Name=N.value('TemplateName[1]', 'nvarchar(255)'))
	
	IF @@ROWCOUNT > 0 BEGIN
		SET @NewTemplateID=SCOPE_IDENTITY()
	END ELSE BEGIN
		SELECT @NewTemplateID=NULL
	END
	
	IF @NewTemplateID IS NOT NULL BEGIN
		INSERT INTO dbo.GBL_Template_Description
		        ( Template_ID ,
		          LangID ,
		          CREATED_DATE ,
		          CREATED_BY ,
		          MODIFIED_DATE ,
		          MODIFIED_BY ,
		          Name ,
		          Logo ,
		          LogoLink ,
		          CopyrightNotice
		        )
		SELECT
				@NewTemplateID,
				N.value('LangID[1]', 'smallint'),
				N.value('CREATED_DATE[1]', 'smalldatetime'),
				N.value('CREATED_BY[1]', 'varchar(50)'),
				N.value('MODIFIED_DATE[1]', 'smalldatetime'),
				N.value('MODIFIED_BY[1]', 'varchar(50)'),
				N.value('Name[1]', 'nvarchar(150)'),
				N.value('Logo[1]', 'nvarchar(150)'),
				N.value('LogoLink[1]', 'varchar(150)'),
				N.value('CopyrightNotice[1]', 'nvarchar(255)')
		FROM @xmlData.nodes('//Template/Descriptions/Lang') AS T(N)
			WHERE N.value('Template_ID[1]', 'int')=@TemplateID
	
		INSERT INTO dbo.GBL_Template_Menu
		        ( Template_ID ,
		          LangID ,
		          CREATED_DATE ,
		          CREATED_BY ,
		          MODIFIED_DATE ,
		          MODIFIED_BY ,
		          MenuType ,
		          Display ,
		          Link ,
		          DisplayOrder
		        )
		SELECT
				@NewTemplateID,
				N.value('LangID[1]', 'smallint'),
				N.value('CREATED_DATE[1]', 'smalldatetime'),
				N.value('CREATED_BY[1]', 'varchar(50)'),
				N.value('MODIFIED_DATE[1]', 'smalldatetime'),
				N.value('MODIFIED_BY[1]', 'varchar(50)'),
		        N.value('MenuType[1]', 'varchar(10)'),
		        N.value('Display[1]', 'nvarchar(200)'),
		        N.value('Link[1]', 'varchar(150)'),
		        N.value('DisplayOrder[1]', 'tinyint')
		FROM @xmlData.nodes('//Template/MenuItems/MenuLang') AS T(N)
			WHERE N.value('Template_ID[1]', 'int')=@TemplateID
	END

	FETCH NEXT FROM TemplateCursor INTO @TemplateID
END

DEALLOCATE TemplateCursor

END

-- Publications

IF 0=1 BEGIN

SET @ObjectType='Publication'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

INSERT INTO dbo.CIC_Publication
        ( MODIFIED_DATE ,
          MODIFIED_BY ,
          CREATED_DATE ,
          CREATED_BY ,
          MemberID ,
          Owner ,
          PubCode ,
          NonPublic ,
          DisplayOrder ,
          FieldHeadings ,
          FieldHeadingsNP ,
          FieldDesc ,
          FieldHeadingGroups ,
          FieldHeadingGroupsNP
        )
SELECT
		N.value('MODIFIED_DATE[1]', 'smalldatetime'),
		N.value('MODIFIED_BY[1]', 'varchar(50)'),
		N.value('CREATED_DATE[1]', 'smalldatetime'),
		N.value('CREATED_BY[1]', 'varchar(50)'),
		N.value('MemberID[1]', 'int'),
		N.value('Owner[1]', 'char(3)'),
		N.value('PubCode[1]', 'varchar(20)'),
		N.value('NonPublic[1]', 'bit'),
		N.value('DisplayOrder[1]', 'tinyint'),
		N.value('FieldHeadings[1]', 'bit'),
		N.value('FieldHeadingsNP[1]', 'bit'),
		N.value('FieldDesc[1]', 'bit'),
		N.value('FieldHeadingGroups[1]', 'bit'),
        N.value('FieldHeadingGroupsNP[1]', 'bit')
FROM @xmlData.nodes('//Pub') AS T(N)
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_Publication WHERE PubCode=N.value('PubCode[1]', 'varchar(20)'))

INSERT INTO dbo.CIC_Publication_Name
        ( PB_ID, LangID, Name, Notes )
SELECT
		PB_ID,
		N.value('LangID[1]', 'smallint'),
		N.value('Name[1]', 'nvarchar(100)'),
		N.value('Notes[1]', 'nvarchar(max)')
FROM @xmlData.nodes('//Pub/Descriptions/Lang') AS T(N)
INNER JOIN dbo.CIC_Publication pb ON pb.PubCode=N.value('../../PubCode[1]', 'varchar(20)')
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_Publication_Name WHERE PB_ID=pb.PB_ID AND LangID=N.value('LangID[1]', 'smallint'))
	
	
DECLARE @OLDGHID TABLE (
	Old int,
	New int
)

MERGE INTO CIC_GeneralHeading dst
USING (
SELECT
		N.value('GH_ID[1]', 'int') AS GH_ID,
		N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
		N.value('CREATED_BY[1]', 'varchar(50)') AS CREATED_BY,
		N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
		N.value('MODIFIED_BY[1]', 'varchar(50)') AS MODIFIED_BY,
		PB_ID,
		NULL AS HeadingGroup, -- XXX handle heading Groups
		N.value('Used[0]', 'bit') AS Used,
		N.value('TaxonomyRestrict[1]', 'bit') AS TaxonomyRestrict,
		N.value('TaxonomyName[1]', 'bit') AS TaxonomyName,
		N.value('TaxonomyWhereClause[1]', 'nvarchar(max)') AS TaxonomyWhereClause,
		N.value('NonPublic[1]', 'bit') AS NonPublic,
		N.value('DisplayOrder[1]', 'tinyint') AS DisplayOrder
		
FROM @xmlData.nodes('//Pub/Headings/Heading') AS T(N)
INNER JOIN dbo.CIC_Publication pb ON pb.PubCode=N.value('../../PubCode[1]', 'varchar(20)')
) AS src
	ON 0=1
WHEN NOT MATCHED BY TARGET THEN
	INSERT
        ( CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          PB_ID ,
          HeadingGroup ,
          Used ,
          TaxonomyRestrict ,
          TaxonomyName ,
          TaxonomyWhereClause ,
          NonPublic ,
          DisplayOrder
        )
    VALUES
        ( src.CREATED_DATE ,
          src.CREATED_BY ,
          src.MODIFIED_DATE ,
          src.MODIFIED_BY ,
          src.PB_ID ,
          src.HeadingGroup ,
          src.Used ,
          src.TaxonomyRestrict ,
          src.TaxonomyName ,
          src.TaxonomyWhereClause ,
          src.NonPublic ,
          src.DisplayOrder
        )
        
        OUTPUT src.GH_ID, inserted.GH_ID INTO @OLDGHID
	;
/*
INSERT INTO @OLDGHID
SELECT
		N.value('GH_ID[1]', 'int') AS GH_ID,
		ROW_NUMBER() OVER (ORDER BY N.value('GH_ID[1]', 'int')) AS New
FROM @xmlData.nodes('//Pub/Headings/Heading') AS T(N)
*/

--SELECT * FROM @OLDGHID

INSERT INTO CIC_GeneralHeading_Name
SELECT New AS GH_ID, LangID, Name
FROM (SELECT
		N.value('../../GH_ID[1]', 'int') AS GH_ID,
		N.value('LangID[1]', 'smallint') AS LangID,
		N.value('Name[1]', 'nvarchar(200)') AS Name
FROM @xmlData.nodes('//Pub/Headings/Heading/Descriptions/Lang') AS T(N)) names
INNER JOIN @OLDGHID ids ON names.GH_ID=ids.Old

END

IF 0=1 BEGIN

-- CIC View

SET @ObjectType='CIC View'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @ViewType int, @ViewName nvarchar(255), @NewViewType int

DECLARE ViewCursor CURSOR LOCAL FOR
SELECT
	N.value('ViewType[1]', 'int'),
	N.value('Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
FROM @xmlData.nodes('//View') as T(N)

OPEN ViewCursor

FETCH NEXT FROM ViewCursor INTO @ViewType, @ViewName

WHILE @@FETCH_STATUS = 0 BEGIN

PRINT @ViewName

INSERT INTO dbo.CIC_View
        ( CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          MemberID ,
          CanSeeNonPublic ,
          CanSeeDeleted ,
          HidePastDueBy ,
          AlertColumn ,
          Template ,
          PrintTemplate ,
          PrintVersionResults ,
          DataMgmtFields ,
          LastModifiedDate ,
          SocialMediaShare ,
          CommSrchWrapAt ,
          OtherCommunity ,
          RespectPrivacyProfile ,
          PB_ID ,
          LimitedView ,
          VolunteerLink ,
          SrchCommunityDefault ,
          ASrchAddress ,
          ASrchAges ,
          ASrchBool ,
          ASrchDist ,
          ASrchEmail ,
          ASrchEmployee ,
          ASrchLastRequest ,
          ASrchNear ,
          ASrchOwner ,
          ASrchVacancy ,
          ASrchVOL ,
          BSrchAutoComplete ,
          BSrchAges ,
          BSrchBrowseByOrg ,
          BSrchNUM ,
          BSrchOCG ,
          BSrchKeywords ,
          BSrchVacancy ,
          BSrchVOL ,
          BSrchWWW ,
          CSrch ,
          CSrchBusRoute ,
          CSrchKeywords ,
          CSrchNear ,
          CSrchSchoolEscort ,
          CSrchSchoolsInArea ,
          CSrchSpaceAvailable ,
          CSrchSubsidy ,
          CSrchTypeOfProgram ,
          CCRFields ,
          QuickListDropDown ,
          QuickListWrapAt ,
          QuickListMatchAll ,
          QuickListSearchGroups ,
          LinkOrgLevels ,
          CanSeeNonPublicPub ,
          UsePubNamesOnly ,
          UseNAICSView ,
          UseTaxonomyView ,
          TaxDefnLevel ,
          UseThesaurusView ,
          UseLocalSubjects ,
          UseZeroSubjects ,
          CCACMETA ,
          AlsoNotify ,
          NoProcessNotify ,
          UseSubmitChangesTo ,
          DataUseAuth ,
          MapSearchResults ,
          Owner ,
          MyList ,
          ViewOtherLangs ,
          AllowFeedbackNotInView ,
          AssignSuggestionsTo
        )
SELECT 
		N.value('CREATED_DATE[1]', 'smalldatetime'),
		N.value('CREATED_BY[1]', 'varchar(50)'),
		N.value('MODIFIED_DATE[1]', 'smalldatetime'),
		N.value('MODIFIED_BY[1]', 'varchar(50)'),
		N.value('MemberID[1]', 'int'),
		N.value('CanSeeNonPublic[1]', 'bit'),
		N.value('CanSeeDeleted[1]', 'bit'),
		N.value('HidePastDueBy[1]', 'int'),
		N.value('AlertColumn[1]', 'bit'),
		(SELECT TOP 1 t.Template_ID FROM dbo.GBL_Template t INNER JOIN dbo.GBL_Template_Description td ON td.Template_ID = t.Template_ID AND (t.MemberID=@MemberID OR t.MemberID IS NULL) WHERE td.Name=N.value('TemplateName[1]', 'nvarchar(255)')),
		(SELECT TOP 1 t.Template_ID FROM dbo.GBL_Template t INNER JOIN dbo.GBL_Template_Description td ON td.Template_ID = t.Template_ID AND (t.MemberID=@MemberID OR t.MemberID IS NULL) WHERE td.Name=N.value('PrintTemplateName[1]', 'nvarchar(255)')),
		N.value('PrintVersionResults[1]', 'bit'),
		N.value('DataMgmtFields[1]', 'bit'),
		N.value('LastModifiedDate[1]', 'bit'),
		N.value('SocialMediaShare[1]', 'bit'),
		N.value('CommSrchWrapAt[1]', 'tinyint'),
		N.value('OtherCommunity[1]', 'bit'),
		N.value('RespectPrivacyProfile[1]', 'bit'),
		(SELECT PB_ID FROM dbo.CIC_Publication WHERE PubCode=N.value('PubCode[1]', 'varchar(20)')),
		N.value('LimitedView[1]', 'bit'),
		N.value('VolunteerLink[1]', 'bit'),
		N.value('SrchCommunityDefault[1]', 'bit'),
		N.value('ASrchAddress[1]', 'bit'),
		N.value('ASrchAges[1]', 'bit'),
		N.value('ASrchBool[1]', 'bit'),
		N.value('ASrchDist[1]', 'bit'),
		N.value('ASrchEmail[1]', 'bit'),
		N.value('ASrchEmployee[1]', 'bit'),
		N.value('ASrchLastRequest[1]', 'bit'),
		N.value('ASrchNear[1]', 'bit'),
		N.value('ASrchOwner[1]', 'bit'),
		N.value('ASrchVacancy[1]', 'bit'),
		N.value('ASrchVOL[1]', 'bit'),
		N.value('BSrchAutoComplete[1]', 'bit'),
		N.value('BSrchAges[1]', 'bit'),
		N.value('BSrchBrowseByOrg[1]', 'bit'),
		N.value('BSrchNUM[1]', 'bit'),
		N.value('BSrchOCG[1]', 'bit'),
		N.value('BSrchKeywords[1]', 'bit'),
		N.value('BSrchVacancy[1]', 'bit'),
		N.value('BSrchVOL[1]', 'bit'),
		N.value('BSrchWWW[1]', 'bit'),
		N.value('CSrch[1]', 'bit'),
		N.value('CSrchBusRoute[1]', 'bit'),
		N.value('CSrchKeywords[1]', 'bit'),
		N.value('CSrchNear[1]', 'bit'),
		N.value('CSrchSchoolEscort[1]', 'bit'),
		N.value('CSrchSchoolsInArea[1]', 'bit'),
		N.value('CSrchSpaceAvailable[1]', 'bit'),
		N.value('CSrchSubsidy[1]', 'bit'),
		N.value('CSrchTypeOfProgram[1]', 'bit'),
		N.value('CCRFields[1]', 'bit'),
		N.value('QuickListDropDown[1]', 'tinyint'),
		N.value('QuickListWrapAt[1]', 'int'),
		N.value('QuickListMatchAll[1]', 'bit'),
		N.value('QuickListSearchGroups[1]', 'bit'),
		N.value('LinkOrgLevels[1]', 'bit'),
		N.value('CanSeeNonPublicPub[1]', 'bit'),
		N.value('UsePubNamesOnly[1]', 'bit'),
		N.value('UseNAICSView[1]', 'bit'),
		N.value('UseTaxonomyView[1]', 'bit'),
		N.value('TaxDefnLevel[1]', 'int'),
		N.value('UseThesaurusView[1]', 'bit'),
		N.value('UseLocalSubjects[1]', 'bit'),
		N.value('UseZeroSubjects[1]', 'bit'),
		N.value('CCACMETA[1]', 'bit'),
		N.value('AlsoNotify[1]', 'varchar(60)'),
		N.value('NoProcessNotify[1]', 'bit'),
		N.value('UseSubmitChangesTo[1]', 'bit'),
		N.value('DataUseAuth[1]', 'bit'),
		N.value('MapSearchResults[1]', 'bit'),
		N.value('Owner[1]', 'char(3)'),
		N.value('MyList[1]', 'bit'),
		N.value('ViewOtherLangs[1]', 'bit'),
		N.value('AllowFeedbackNotInView[1]', 'bit'),
        N.value('AssignSuggestionsTo[1]', 'char(3)')
		FROM @xmlData.nodes('//View') AS T(N)
			WHERE N.value('ViewType[1]', 'int')=@ViewType
				AND NOT EXISTS(SELECT * FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND vw.MemberID=@MemberID AND vwd.ViewName=@ViewName)

	IF @@ROWCOUNT > 0 BEGIN
		SET @NewViewType=SCOPE_IDENTITY()
	END ELSE BEGIN 
		SELECT @NewViewType=NULL
	END
	
	IF @NewViewType IS NOT NULL BEGIN
		INSERT INTO dbo.CIC_View_Description
				( ViewType ,
				  LangID ,
				  CREATED_DATE ,
				  CREATED_BY ,
				  MODIFIED_DATE ,
				  MODIFIED_BY ,
				  ViewName ,
				  Notes ,
				  Title ,
				  BottomMessage ,
				  MenuMessage ,
				  CSrchText ,
				  QuickListName ,
				  FeedbackBlurb ,
				  TermsOfUseURL ,
				  InclusionPolicy ,
				  SearchTips ,
				  SearchLeftMessage ,
				  SearchRightMessage ,
				  SearchAlertMessage
				)
		SELECT
			@NewViewType,
			N.value('LangID[1]', 'smallint'),
			N.value('CREATED_DATE[1]', 'smalldatetime'),
			N.value('CREATED_BY[1]', 'varchar(50)'),
			N.value('MODIFIED_DATE[1]', 'smalldatetime'),
			N.value('MODIFIED_BY[1]', 'varchar(50)'),
			N.value('ViewName[1]', 'nvarchar(100)'),
			N.value('Notes[1]', 'nvarchar(max)'),
			N.value('Title[1]', 'nvarchar(255)'),
			N.value('BottomMessage[1]', 'nvarchar(max)'),
			N.value('MenuMessage[1]', 'nvarchar(max)'),
			N.value('CSrchText[1]', 'nvarchar(255)'),
			N.value('QuickListName[1]', 'nvarchar(25)'),
			N.value('FeedbackBlurb[1]', 'nvarchar(max)'),
			N.value('TermsOfUseURL[1]', 'varchar(200)'),
			(SELECT InclusionPolicyID FROM dbo.GBL_InclusionPolicy WHERE PolicyTitle=N.value('InclusionPolicyName[1]', 'nvarchar(255)')),
			(SELECT SearchTipsID FROM dbo.GBL_SearchTips WHERE PageTitle=N.value('SearchTipsName[1]', 'nvarchar(255)')),
			N.value('SearchLeftMessage[1]', 'nvarchar(max)'),
			N.value('SearchRightMessage[1]', 'nvarchar(max)'),
			N.value('SearchAlertMessage[1]', 'nvarchar(max)')
		FROM @xmlData.nodes('//View/Descriptions/Lang') AS T(N)
			WHERE N.value('../../ViewType[1]', 'int')=@ViewType
				AND NOT EXISTS(SELECT * FROM dbo.CIC_View_Description WHERE ViewType=@NewViewType AND LangID=N.value('LangID[1]', 'smallint'))
	END

	FETCH NEXT FROM ViewCursor INTO @ViewType, @ViewName
END

DEALLOCATE ViewCursor


INSERT INTO dbo.CIC_View_ChkField
        ( ViewType, FieldID )
SELECT vwd.ViewType,
      (SELECT FieldID FROM dbo.GBL_FieldOption WHERE FieldName=N.value('.[1]', 'varchar(100)'))
FROM @xmlData.nodes('//View/ChkField/FieldName') AS T(N)
	INNER JOIN dbo.CIC_View_Description vwd
		ON vwd.LangID=(SELECT TOP 1 LangID FROM	dbo.CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd.ViewName=N.value('../../Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.CIC_View vw WHERE vw.MemberID=@MemberID AND vw.ViewType=vwd.ViewType)
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_View_ChkField WHERE ViewType=vwd.ViewType AND FieldID=(SELECT FieldID FROM dbo.GBL_FieldOption WHERE FieldName=N.value('.[1]', 'varchar(100)')))

	
INSERT INTO dbo.CIC_View_AutoAddPub
        ( ViewType, PB_ID )
SELECT vwd.ViewType,
      (SELECT PB_ID FROM dbo.CIC_Publication WHERE PubCode=N.value('.[1]', 'varchar(20)'))
FROM @xmlData.nodes('//View/AutoAddPub/PubCode') AS T(N)
	INNER JOIN dbo.CIC_View_Description vwd
		ON vwd.LangID=(SELECT TOP 1 LangID FROM	dbo.CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd.ViewName=N.value('../../Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.CIC_View vw WHERE vw.MemberID=@MemberID AND vw.ViewType=vwd.ViewType)
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_View_AutoAddPub WHERE ViewType=vwd.ViewType AND PB_ID=(SELECT PB_ID FROM dbo.CIC_Publication WHERE PubCode=N.value('.[1]', 'varchar(20)')))

INSERT INTO dbo.CIC_View_QuickListPub
        ( ViewType, PB_ID )
SELECT vwd.ViewType,
	(SELECT PB_ID FROM dbo.CIC_Publication WHERE PubCode=N.value('.[1]', 'varchar(20)'))
FROM @xmlData.nodes('//View/QuickListPub/PubCode') AS T(N)
	INNER JOIN dbo.CIC_View_Description vwd
		ON vwd.LangID=(SELECT TOP 1 LangID FROM	dbo.CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd.ViewName=N.value('../../Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.CIC_View vw WHERE vw.MemberID=@MemberID AND vw.ViewType=vwd.ViewType)
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_View_QuickListPub WHERE ViewType=vwd.ViewType AND PB_ID=(SELECT PB_ID FROM dbo.CIC_Publication WHERE PubCode=N.value('.[1]', 'varchar(20)')))

INSERT INTO dbo.CIC_View_Community
        ( ViewType, CM_ID, DisplayOrder )
SELECT vwd.ViewType,
      cm.CM_ID,
      N.value('DisplayOrder[1]', 'tinyint')
FROM @xmlData.nodes('//View/Communities/Community') AS T(N)
	LEFT JOIN dbo.GBL_Community cm
		ON cm.CM_GUID=N.value('CM_GUID[1]', 'uniqueidentifier')
			AND EXISTS(SELECT * FROM dbo.GBL_Community_Name cmn WHERE cmn.CM_ID=cm.CM_ID AND Name=N.value('Name[1]', 'nvarchar(255)'))
	INNER JOIN dbo.CIC_View_Description vwd
		ON vwd.LangID=(SELECT TOP 1 LangID FROM	dbo.CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd.ViewName=N.value('../../Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.CIC_View vw WHERE vw.MemberID=@MemberID AND vw.ViewType=vwd.ViewType)
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_View_Community WHERE ViewType=vwd.ViewType AND CM_ID=cm.CM_ID)

INSERT INTO dbo.CIC_View_Recurse
        ( ViewType, CanSee )
SELECT vwd.ViewType,
	vwd2.Viewtype
FROM @xmlData.nodes('//View/Recurse/CanSeeView') AS T(N)
	INNER JOIN dbo.CIC_View_Description vwd
		ON vwd.LangID=(SELECT TOP 1 LangID FROM	dbo.CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd.ViewName=N.value('../../Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.CIC_View vw WHERE vw.MemberID=@MemberID AND vw.ViewType=vwd.ViewType)
	INNER JOIN dbo.CIC_View_Description vwd2
		ON vwd2.LangID=(SELECT TOP 1 LangID FROM dbo.CIC_View_Description WHERE ViewType=vwd2.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd2.ViewName=N.value('.[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.CIC_View vw2 WHERE vw2.MemberID=@MemberID AND vw2.ViewType=vwd2.ViewType)
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_View_Recurse WHERE ViewType=vwd.ViewType AND CanSee=vwd2.ViewType)

END

-- Member 2

IF 0=1 BEGIN

SET @ObjectType='Member'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

UPDATE mem SET
	mem.DefaultTemplate = (SELECT TOP 1 t.Template_ID FROM dbo.GBL_Template t INNER JOIN dbo.GBL_Template_Description td ON td.Template_ID = t.Template_ID AND (t.MemberID=@MemberID OR t.MemberID IS NULL) WHERE td.Name=N.value('DefaultTemplateName[1]', 'nvarchar(255)')),
	mem.DefaultPrintTemplate = (SELECT TOP 1 t.Template_ID FROM dbo.GBL_Template t INNER JOIN dbo.GBL_Template_Description td ON td.Template_ID = t.Template_ID AND (t.MemberID=@MemberID OR t.MemberID IS NULL) WHERE td.Name=N.value('DefaultPrintTemplateName[1]', 'nvarchar(255)')),
	mem.DefaultViewCIC = (SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('DefaultViewCICName[1]', 'nvarchar(255)'))--,
	--mem.DefaultViewVOL = (SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('DefaultViewVOLName[1]', 'nvarchar(255)')),
FROM dbo.STP_Member mem
	INNER JOIN @xmlData.nodes('//Member') as T(N)
		ON mem.MemberID=N.value('MemberID[1]', 'int')

END

-- CIC View

IF 0=1 BEGIN

	SET @ObjectType='CIC View'

	SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
	WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

	DECLARE @OldIDs TABLE (
		Old int,
		New int
	)

	MERGE INTO CIC_View_DisplayFieldGroup dst
	USING (
	SELECT 
		vwd.ViewType,
		N.value('DisplayOrder[1]', 'tinyint') AS DisplayOrder,
		N.value('DisplayFieldGroupID[1]', 'int') AS DisplayFieldGroupID
	FROM @xmlData.nodes('//View/DisplayFieldGroup/FieldGroup') AS T(N)
		INNER JOIN dbo.CIC_View_Description vwd
			ON vwd.LangID=(SELECT TOP 1 LangID FROM	dbo.CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
				AND vwd.ViewName=N.value('../../Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
				AND EXISTS(SELECT * FROM dbo.CIC_View vw WHERE vw.MemberID=@MemberID AND vw.ViewType=vwd.ViewType)
				) src 
			ON 1=0
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ViewType, DisplayOrder)
				VALUES (src.ViewType, src.DisplayOrder)
			OUTPUT src.DisplayFieldGroupID, inserted.DisplayFieldGroupID INTO @OldIDs
			;
			/*
INSERT INTO @OldIDs (Old, New)
SELECT
	N.value('DisplayFieldGroupID[1]', 'int'),
	fgn.DisplayFieldGroupID
FROM @xmlData.nodes('//View/DisplayFieldGroup/FieldGroup') AS T(N)
	INNER JOIN dbo.CIC_View_Description vwd
		ON vwd.LangID=(SELECT TOP 1 LangID FROM	dbo.CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd.ViewName=N.value('../../Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.CIC_View vw WHERE vw.MemberID=@MemberID AND vw.ViewType=vwd.ViewType)
	INNER JOIN dbo.CIC_View_DisplayFieldGroup_Name fgn
		ON fgn.LangID=(SELECT TOP 1 LangID FROM	dbo.CIC_View_DisplayFieldGroup_Name WHERE DisplayFieldGroupID=fgn.DisplayFieldGroupID ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND fgn.Name=N.value('Descriptions[1]/Lang[LangID=0][1]/Name[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM CIC_View_DisplayFieldGroup fg INNER JOIN CIC_View vw ON fg.ViewType=vw.ViewType WHERE vw.MemberID=@MemberID AND fg.DisplayFieldGroupID=fgn.DisplayFieldGroupID)
			
SELECT * FROM @OldIDs
*/
			
	INSERT INTO CIC_View_DisplayFieldGroup_Name ( DisplayFieldGroupID, LangID, Name )
	SELECT New, LangID, Name FROM (
		SELECT 
			N.value('Name[1]', 'nvarchar(100)') AS Name,
			N.value('LangID[1]', 'smallint') AS LangID,
			N.value('../../DisplayFieldGroupID[1]', 'int') AS DisplayFieldGroupID
		FROM @xmlData.nodes('//View/DisplayFieldGroup/FieldGroup/Descriptions/Lang') AS T(N)
	) src
	INNER JOIN @OldIDs ids
		ON Old=src.DisplayFieldGroupID


	INSERT INTO CIC_View_DisplayField ( DisplayFieldGroupID, FieldID )
	SELECT  DISTINCT New, FieldID FROM (
		SELECT 
			N.value('.', 'nvarchar(100)') AS FieldName,
			N.value('../../DisplayFieldGroupID[1]', 'int') AS DisplayFieldGroupID
		FROM @xmlData.nodes('//View/DisplayFieldGroup/FieldGroup/DisplayField/FieldName') AS T(N)
	) src
	INNER JOIN @OldIDs ids
		ON Old=src.DisplayFieldGroupID
	INNER JOIN GBL_FieldOption fo
		ON src.FieldName=fo.FieldName
	
	INSERT INTO CIC_View_FeedbackField ( DisplayFieldGroupID, FieldID )
	SELECT  DISTINCT New, FieldID FROM (
		SELECT 
			N.value('.', 'nvarchar(100)') AS FieldName,
			N.value('../../DisplayFieldGroupID[1]', 'int') AS DisplayFieldGroupID
		FROM @xmlData.nodes('//View/DisplayFieldGroup/FieldGroup/FeedbackField/FieldName') AS T(N)
	) src
	INNER JOIN @OldIDs ids
		ON Old=src.DisplayFieldGroupID
	INNER JOIN GBL_FieldOption fo
		ON src.FieldName=fo.FieldName
	
	INSERT INTO CIC_View_MailFormField ( DisplayFieldGroupID, FieldID )
	SELECT  DISTINCT New, FieldID FROM (
		SELECT 
			N.value('.', 'nvarchar(100)') AS FieldName,
			N.value('../../DisplayFieldGroupID[1]', 'int') AS DisplayFieldGroupID
		FROM @xmlData.nodes('//View/DisplayFieldGroup/FieldGroup/MailFormField/FieldName') AS T(N)
	) src
	INNER JOIN @OldIDs ids
		ON Old=src.DisplayFieldGroupID
	INNER JOIN GBL_FieldOption fo
		ON src.FieldName=fo.FieldName
	
	INSERT INTO CIC_View_UpdateField ( DisplayFieldGroupID, FieldID )
	SELECT DISTINCT New, FieldID FROM (
		SELECT 
			N.value('.', 'nvarchar(100)') AS FieldName,
			N.value('../../DisplayFieldGroupID[1]', 'int') AS DisplayFieldGroupID
		FROM @xmlData.nodes('//View/DisplayFieldGroup/FieldGroup/UpdateField/FieldName') AS T(N)
	) src
	INNER JOIN @OldIDs ids
		ON Old=src.DisplayFieldGroupID
	INNER JOIN GBL_FieldOption fo
		ON src.FieldName=fo.FieldName

END

-- CIC User Type

IF 0=1 BEGIN

SET @ObjectType='CIC User Type'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @SLID int, @SecurityLevel nvarchar(255), @NewSLID int

DECLARE UserTypeCursor CURSOR LOCAL FOR
SELECT
	N.value('SL_ID[1]', 'int'),
	N.value('Descriptions[1]/Lang[LangID=0][1]/SecurityLevel[1]', 'nvarchar(255)')
FROM @xmlData.nodes('//UserType') as T(N)

OPEN UserTypeCursor

FETCH NEXT FROM UserTypeCursor INTO @SLID, @SecurityLevel

WHILE @@FETCH_STATUS = 0 BEGIN

PRINT @SecurityLevel

INSERT INTO dbo.CIC_SecurityLevel
        ( CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          MemberID ,
          Owner ,
          ViewType ,
          ViewTypeOffline ,
          CanAddRecord ,
          CanAddSQL ,
          CanAssignFeedback ,
          CanCopyRecord ,
          CanDeleteRecord ,
          CanDoBulkOps ,
          CanDoFullUpdate ,
          CanEditRecord ,
          EditByViewList ,
          CanIndexTaxonomy ,
          CanManageUsers ,
          CanRequestUpdate ,
          CanUpdatePubs ,
          CanViewStats ,
          ExportPermission ,
          ImportPermission ,
          SuppressNotifyEmail ,
          FeedbackAlert ,
          CommentAlert ,
          WebDeveloper ,
          SuperUser ,
          SuperUserGlobal
        )
SELECT
		N.value('CREATED_DATE[1]', 'smalldatetime'),
		N.value('CREATED_BY[1]', 'varchar(50)'),
		N.value('MODIFIED_DATE[1]', 'smalldatetime'),
		N.value('MODIFIED_BY[1]', 'varchar(50)'),
 		N.value('MemberID[1]', 'int'),
		N.value('Owner[1]', 'char(3)'),
 		(SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('ViewTypeName[1]', 'nvarchar(255)')),
 		(SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('ViewTypeOfflineName[1]', 'nvarchar(255)')),
		N.value('CanAddRecord[1]', 'bit'),
		N.value('CanAddSQL[1]', 'bit'),
		N.value('CanAssignFeedback[1]', 'bit'),
		N.value('CanCopyRecord[1]', 'bit'),
		N.value('CanDeleteRecord[1]', 'bit'),
		N.value('CanDoBulkOps[1]', 'bit'),
		N.value('CanDoFullUpdate[1]', 'bit'),
 		N.value('CanEditRecord[1]', 'tinyint'),
		N.value('EditByViewList[1]', 'bit'),
 		N.value('CanIndexTaxonomy[1]', 'tinyint'),
		N.value('CanManageUsers[1]', 'bit'),
		N.value('CanRequestUpdate[1]', 'bit'),
 		N.value('CanUpdatePubs[1]', 'tinyint'),
		N.value('CanViewStats[1]', 'bit'),
 		N.value('ExportPermission[1]', 'int'),
		N.value('ImportPermission[1]', 'bit'),
		N.value('SuppressNotifyEmail[1]', 'bit'),
		N.value('FeedbackAlert[1]', 'bit'),
		N.value('CommentAlert[1]', 'bit'),
		N.value('WebDeveloper[1]', 'bit'),
		N.value('SuperUser[1]', 'bit'),
        N.value('SuperUserGlobal[1]', 'bit')
FROM @xmlData.nodes('//UserType') as T(N)
	WHERE N.value('SL_ID[1]', 'int')=@SLID
		AND NOT EXISTS(SELECT * FROM dbo.CIC_SecurityLevel sl INNER JOIN dbo.CIC_SecurityLevel_Name sln ON sln.SL_ID = sl.SL_ID AND sl.MemberID=@MemberID AND sln.SecurityLevel=@SecurityLevel)

	IF @@ROWCOUNT > 0 BEGIN
		SET @NewSLID=SCOPE_IDENTITY()
	END ELSE BEGIN 
		SELECT @NewSLID=NULL
	END
	
	IF @NewSLID IS NOT NULL BEGIN
		INSERT INTO dbo.CIC_SecurityLevel_Name
		        ( SL_ID ,
		          LangID ,
		          MemberID_Cache ,
		          SecurityLevel
		        )
		SELECT
			@NewSLID,
		    N.value('LangID[1]', 'smallint'),
		    N.value('MemberID_Cache[1]', 'int'),
		    N.value('SecurityLevel[1]', 'nvarchar(100)')
		FROM @xmlData.nodes('//UserType/Descriptions/Lang') AS T(N)
			WHERE N.value('../../SL_ID[1]', 'int')=@SLID
				AND NOT EXISTS(SELECT * FROM dbo.CIC_SecurityLevel_Name WHERE SL_ID=@NewSLID AND LangID=N.value('LangID[1]', 'smallint'))
	END

	FETCH NEXT FROM UserTypeCursor INTO @SLID, @SecurityLevel
END

DEALLOCATE UserTypeCursor

END

-- Users
IF 0=1 BEGIN

SET @ObjectType='User'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

INSERT INTO dbo.GBL_Users
        ( CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          MemberID_Cache ,
          UserUID ,
          UserName ,
          TechAdmin ,
          SL_ID_CIC ,
          SL_ID_VOL ,
          StartModule ,
          StartLanguage ,
          Agency ,
          FirstName ,
          LastName ,
          Initials ,
          Email ,
          PasswordHashRepeat ,
          PasswordHashSalt ,
          PasswordHash ,
          SavedSearchQuota ,
          SingleLogin ,
          SingleLoginKey ,
          CanUpdateAccount ,
          CanUpdatePassword ,
          Inactive ,
          ActiveStatusChanged ,
          ActiveStatusChangedBy ,
          PasswordChanged ,
          PasswordChangedBy ,
          LastSuccessfulLogin ,
          LastSuccessfulLoginIP ,
          LoginAttempts ,
          LastLoginAttempt ,
          LastLoginAttemptIP
        )
SELECT
		N.value('CREATED_DATE[1]', 'smalldatetime'),
		N.value('CREATED_BY[1]', 'varchar(50)'),
		N.value('MODIFIED_DATE[1]', 'smalldatetime'),
		N.value('MODIFIED_BY[1]', 'varchar(50)'),
 		N.value('MemberID_Cache[1]', 'int'),
		N.value('UserUID[1]', 'uniqueidentifier'),
		N.value('UserName[1]', 'varchar(50)'),
		N.value('TechAdmin[1]', 'bit'),
 		(SELECT TOP 1 sl.SL_ID FROM dbo.CIC_SecurityLevel sl INNER JOIN dbo.CIC_SecurityLevel_Name sln ON sln.SL_ID = sl.SL_ID AND (sl.MemberID=@MemberID OR sl.MemberID IS NULL) WHERE sln.SecurityLevel=N.value('SecurityLevelCIC[1]', 'nvarchar(255)')),
 		(SELECT TOP 1 sl.SL_ID FROM dbo.VOL_SecurityLevel sl INNER JOIN dbo.VOL_SecurityLevel_Name sln ON sln.SL_ID = sl.SL_ID AND (sl.MemberID=@MemberID OR sl.MemberID IS NULL) WHERE sln.SecurityLevel=N.value('SecurityLevelVOL[1]', 'nvarchar(255)')),
 		N.value('StartModule[1]', 'tinyint'),
 		N.value('StartLanguage[1]', 'smallint'),
		N.value('Agency[1]', 'char(3)'),
		N.value('FirstName[1]', 'varchar(50)'),
		N.value('LastName[1]', 'varchar(50)'),
		N.value('Initials[1]', 'varchar(6)'),
		N.value('Email[1]', 'varchar(60)'),
 		N.value('PasswordHashRepeat[1]', 'int'),
		N.value('PasswordHashSalt[1]', 'char(44)'),
		N.value('PasswordHash[1]', 'char(44)'),
 		N.value('SavedSearchQuota[1]', 'tinyint'),
		N.value('SingleLogin[1]', 'bit'),
		N.value('SingleLoginKey[1]', 'char(44)'),
		N.value('CanUpdateAccount[1]', 'bit'),
		N.value('CanUpdatePassword[1]', 'bit'),
		N.value('Inactive[1]', 'bit'),
		N.value('ActiveStatusChanged[1]', 'smalldatetime'),
		N.value('ActiveStatusChangedBy[1]', 'varchar(50)'),
		N.value('PasswordChanged[1]', 'smalldatetime'),
		N.value('PasswordChangedBy[1]', 'varchar(50)'),
        N.value('LastSuccessfulLogin[1]', 'datetime'),
		N.value('LastSuccessfulLoginIP[1]', 'varchar(20)'),
 		N.value('LoginAttempts[1]', 'tinyint'),
        N.value('LastLoginAttempt[1]', 'datetime'),
        N.value('LastLoginAttemptIP[1]', 'varchar(20)')
FROM @xmlData.nodes('//User') as T(N)
	WHERE NOT EXISTS(SELECT * FROM dbo.GBL_Users WHERE UserUID=N.value('UserUID[1]', 'uniqueidentifier') OR (UserName=N.value('UserName[1]', 'varchar(50)') AND MemberID_Cache=@MemberID))

INSERT INTO dbo.GBL_Users_History
        ( User_ID ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          UserName ,
          SL_ID_CIC ,
          SL_ID_VOL ,
          StartModule ,
          StartLanguage ,
          Agency ,
          FirstName ,
          LastName ,
          Initials ,
          Email ,
          PasswordChange ,
          SavedSearchQuota ,
          SingleLogin ,
          CanUpdateAccount ,
          CanUpdatePassword ,
          Inactive ,
          NewAccount
        )
SELECT
		(SELECT User_ID FROM GBL_Users WHERE UserUID=N.value('../../UserUID[1]', 'uniqueidentifier')),
        N.value('MODIFIED_DATE[1]', 'datetime'),
		N.value('MODIFIED_BY[1]', 'varchar(50)'),
		N.value('UserName[1]', 'varchar(50)'),
		N.value('SL_ID_CIC[1]', 'varchar(100)'),
		N.value('SL_ID_VOL[1]', 'varchar(100)'),
 		N.value('StartModule[1]', 'tinyint'),
 		N.value('StartLanguage[1]', 'smallint'),
		N.value('Agency[1]', 'char(3)'),
		N.value('FirstName[1]', 'varchar(50)'),
		N.value('LastName[1]', 'varchar(50)'),
		N.value('Initials[1]', 'varchar(6)'),
		N.value('Email[1]', 'varchar(50)'),
		N.value('PasswordChange[1]', 'bit'),
 		N.value('SavedSearchQuota[1]', 'tinyint'),
		N.value('SingleLogin[1]', 'bit'),
		N.value('CanUpdateAccount[1]', 'bit'),
		N.value('CanUpdatePassword[1]', 'bit'),
		N.value('Inactive[1]', 'bit'),
		N.value('NewAccount[1]', 'bit')
FROM @xmlData.nodes('//User/History/Change') as T(N)

END

-- History

IF 0=1 BEGIN

DELETE h
FROM dbo.GBL_BaseTable_History h
INNER JOIN dbo.GBL_BaseTable bt
	ON h.NUM=bt.NUM AND bt.MemberID=@MemberID

UPDATE hl
	SET NewFieldID=fo.FieldID
FROM cioc_data_loader.dbo.HistoryLoader hl
INNER JOIN dbo.GBL_FieldOption fo
	ON hl.FieldName=fo.FieldName

INSERT INTO dbo.GBL_BaseTable_History
        ( NUM ,
          LangID ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          FieldID ,
          FieldDisplay
        )
SELECT NUM ,
          LangID ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          NewFieldID ,
          FieldDisplay FROM cioc_data_loader.dbo.HistoryLoader hl
WHERE EXISTS(SELECT * FROM dbo.GBL_BaseTable_Description btd WHERE btd.LangID=hl.LangID AND btd.NUM=hl.NUM)
ORDER BY hl.MODIFIED_DATE, hl.MODIFIED_BY, hl.NUM, NewFieldID

END

-- Table Options
IF 0=1 BEGIN
SET @ObjectType='CIC Display'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

INSERT INTO dbo.GBL_Display
        ( Domain ,
          User_ID ,
          ViewTypeCIC ,
          ViewTypeVOL ,
          ShowID ,
          ShowOwner ,
          ShowAlert ,
          ShowOrg ,
          ShowCommunity ,
          ShowUpdateSchedule ,
          LinkUpdate ,
          LinkEmail ,
          LinkSelect ,
          LinkWeb ,
          LinkListAdd ,
          OrderBy ,
          OrderByCustom ,
          OrderByDesc ,
          GLinkMail ,
          GLinkPub ,
          VShowTable ,
          VShowPosition ,
          VShowDuties
        )
SELECT
 		N.value('Domain[1]', 'int'),
 		(SELECT User_ID FROM GBL_Users WHERE UserUID=N.value('UserUID[1]', 'uniqueidentifier')),
 		(SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('ViewTypeCICName[1]', 'nvarchar(255)')),
 		(SELECT TOP 1 vw.ViewType FROM dbo.VOL_View vw INNER JOIN dbo.VOL_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('ViewTypeVOLName[1]', 'nvarchar(255)')),
		N.value('ShowID[1]', 'bit'),
		N.value('ShowOwner[1]', 'bit'),
		N.value('ShowAlert[1]', 'bit'),
		N.value('ShowOrg[1]', 'bit'),
		N.value('ShowCommunity[1]', 'bit'),
		N.value('ShowUpdateSchedule[1]', 'bit'),
		N.value('LinkUpdate[1]', 'bit'),
		N.value('LinkEmail[1]', 'bit'),
		N.value('LinkSelect[1]', 'bit'),
		N.value('LinkWeb[1]', 'bit'),
		N.value('LinkListAdd[1]', 'bit'),
 		N.value('OrderBy[1]', 'int'),
 		N.value('OrderByCustom[1]', 'int'),
		N.value('OrderByDesc[1]', 'bit'),
		N.value('GLinkMail[1]', 'bit'),
		N.value('GLinkPub[1]', 'bit'),
		N.value('VShowTable[1]', 'bit'),
		N.value('VShowPosition[1]', 'bit'),
        N.value('VShowDuties[1]', 'bit')
FROM @xmlData.nodes('//Display') as T(N)
	WHERE NOT EXISTS(SELECT * FROM dbo.GBL_Display
		WHERE ViewTypeCIC=(SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('ViewTypeCICName[1]', 'nvarchar(255)'))
			OR ViewTypeVOL=(SELECT TOP 1 vw.ViewType FROM dbo.VOL_View vw INNER JOIN dbo.VOL_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('ViewTypeVOLName[1]', 'nvarchar(255)'))
			OR User_ID=(SELECT User_ID FROM GBL_Users WHERE UserUID=N.value('UserUID[1]', 'uniqueidentifier'))
		)

INSERT INTO dbo.GBL_Display_Fld
        ( DD_ID, FieldID )
SELECT
	(SELECT DD_ID FROM dbo.GBL_Display WHERE ViewTypeCIC=(SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('../../ViewTypeCICName[1]', 'nvarchar(255)'))
			OR ViewTypeVOL=(SELECT TOP 1 vw.ViewType FROM dbo.VOL_View vw INNER JOIN dbo.VOL_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('../../ViewTypeVOLName[1]', 'nvarchar(255)'))
			OR User_ID=(SELECT User_ID FROM GBL_Users WHERE UserUID=N.value('../../UserUID[1]', 'uniqueidentifier'))
	),
	(SELECT FieldID FROM dbo.GBL_FieldOption fo WHERE FieldName=N.value('.[1]','varchar(100)'))
FROM @xmlData.nodes('//Display/Fields/FieldName') as T(N)
	WHERE NOT EXISTS(SELECT * FROM dbo.GBL_Display
		WHERE ViewTypeCIC=(SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('ViewTypeCICName[1]', 'nvarchar(255)'))
			OR ViewTypeVOL=(SELECT TOP 1 vw.ViewType FROM dbo.VOL_View vw INNER JOIN dbo.VOL_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('ViewTypeVOLName[1]', 'nvarchar(255)'))
			OR User_ID=(SELECT User_ID FROM GBL_Users WHERE UserUID=N.value('UserUID[1]', 'uniqueidentifier'))
		)
END
-- Table Options

-- Saved Searches
IF 0=1 BEGIN
SET @ObjectType='Saved Search'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @OLDSSIDS TABLE (
	Old int,
	New int
)

MERGE INTO GBL_SavedSearch dst
USING (
SELECT  
		N.value('SSRCH_ID[1]', 'int') AS SSRCH_ID ,
        N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE ,
        N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE ,
        u.User_ID,
        N.value('SearchName[1]', 'varchar(255)') AS SearchName ,
        N.value('Domain[1]', 'tinyint') AS Domain ,
        N.value('LangID[1]', 'smallint') AS LangID ,
        N.value('WhereClause[1]', 'nvarchar(max)') AS WhereClause ,
        N.value('IncludeDeleted[1]', 'bit') AS IncludeDeleted ,
        N.value('Notes[1]', 'nvarchar(max)') AS Notes ,
        N.value('UpgradeVerified[1]', 'bit') AS UpgradeVerified
FROM @xmlData.nodes('//SavedSearch') AS T(N)
INNER JOIN GBL_Users u 
	ON u.MemberID_Cache=@MemberID AND u.UserUID=N.value('UserUID[1]', 'uniqueidentifier')
) src
	ON 0=1
WHEN NOT MATCHED BY TARGET THEN
	INSERT
        ( CREATED_DATE ,
          MODIFIED_DATE ,
          User_ID ,
          SearchName ,
          Domain ,
          LangID ,
          WhereClause ,
          IncludeDeleted ,
          Notes ,
          UpgradeVerified
        )
    VALUES
        ( src.CREATED_DATE ,
          src.MODIFIED_DATE ,
          src.User_ID ,
          src.SearchName ,
          src.Domain ,
          src.LangID ,
          src.WhereClause ,
          src.IncludeDeleted ,
          src.Notes ,
          src.UpgradeVerified
        )
    OUTPUT src.SSRCH_ID, inserted.SSRCH_ID INTO @OLDSSIDS
;
	/*
INSERT INTO @OLDSSIDS ( Old, New )
SELECT  
		N.value('SSRCH_ID[1]', 'int') AS SSRCH_ID ,
		ROW_NUMBER() OVER(ORDER BY N.value('SSRCH_ID[1]', 'int')) AS New
FROM @xmlData.nodes('//SavedSearch') AS T(N)
*/

SELECT * FROM @OLDSSIDS

INSERT INTO CIC_SecurityLevel_SavedSearch
        ( SL_ID, SSRCH_ID )
SELECT SL_ID, New
FROM (
	SELECT
		N.value('../../SSRCH_ID[1]', 'int') AS SSRCH_ID ,
 		(SELECT TOP 1 sl.SL_ID FROM dbo.CIC_SecurityLevel sl INNER JOIN dbo.CIC_SecurityLevel_Name sld ON sld.SL_ID = sl.SL_ID AND sl.MemberID=@MemberID WHERE sld.SecurityLevel=N.value('.', 'nvarchar(255)')) SL_ID
	FROM @xmlData.nodes('//SavedSearch/CICUserType/SecurityLevel') AS T(N)
) src
INNER JOIN @OLDSSIDS
	ON src.SSRCH_ID=Old

END
-- Saved Searches

-- Print Profiles
IF 0=1 BEGIN

SET @ObjectType='Print Profile'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @OLDPrintIDs TABLE (
	Old int,
	New int
)

MERGE INTO GBL_PrintProfile dst
USING (
SELECT  
          N.value('ProfileID[1]', 'int') AS ProfileID ,
          N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE ,
          N.value('CREATED_BY[1]', 'varchar(50)') AS CREATED_BY ,
          N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE ,
          N.value('MODIFIED_BY[1]', 'varchar(50)') AS MODIFIED_BY ,
          @MemberID AS MemberID ,
          N.value('Domain[1]', 'tinyint') AS Domain ,
          N.value('StyleSheet[1]', 'varchar(150)') AS StyleSheet ,
          N.value('TableClass[1]', 'varchar(50)') AS TableClass ,
          N.value('MsgBeforeRecord[1]', 'bit') AS MsgBeforeRecord ,
          N.value('Separator[1]', 'nvarchar(255)') AS Separator ,
          N.value('PageBreak[1]', 'bit') AS PageBreak
FROM @xmlData.nodes('/PrintProfile') AS T(N) ) src
ON 0=1
WHEN NOT MATCHED BY TARGET THEN
	INSERT 
        ( CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          MemberID ,
          Domain ,
          StyleSheet ,
          TableClass ,
          MsgBeforeRecord ,
          Separator ,
          PageBreak
        )
        VALUES
        ( 
          src.CREATED_DATE ,
          src.CREATED_BY ,
          src.MODIFIED_DATE ,
          src.MODIFIED_BY ,
          src.MemberID ,
          src.Domain ,
          src.StyleSheet ,
          src.TableClass ,
          src.MsgBeforeRecord ,
          src.Separator ,
          src.PageBreak
        )
	
	OUTPUT src.ProfileID, inserted.ProfileID INTO @OLDPrintIDs
	;

/* 
INSERT INTO @OLDPrintIDs ( Old, New )
SELECT  
          N.value('ProfileID[1]', 'int') AS ProfileID ,
          N.value('ProfileID[1]', 'int') + 100
FROM @xmlData.nodes('/PrintProfile') AS T(N)
*/
SELECT * FROM @OLDPrintIDs


INSERT INTO GBL_PrintProfile_Description
        ( ProfileID , LangID , MemberID_Cache , ProfileName , PageTitle , Header , Footer , DefaultMsg )
SELECT New, LangID, MemberID_Cache, ProfileName, PageTitle, Header, Footer, DefaultMsg
FROM 
(SELECT  
          N.value('../../ProfileID[1]', 'int') AS ProfileID ,
          N.value('LangID[1]', 'smallint') AS LangID ,
          @MemberID AS MemberID_Cache,
          N.value('ProfileName[1]', 'nvarchar(50)') AS ProfileName ,
          N.value('PageTitle[1]', 'nvarchar(100)') AS PageTitle ,
          N.value('Header[1]', 'nvarchar(max)') AS Header ,
          N.value('Footer[1]', 'nvarchar(max)') AS Footer ,
          N.value('DefaultMsg[1]', 'nvarchar(max)') AS DefaultMsg
FROM @xmlData.nodes('/PrintProfile/Descriptions/Lang') AS T(N) ) src
LEFT JOIN @OLDPrintIDs ids
	ON ids.Old=src.ProfileID
	

DECLARE @OLDPFLD_ID AS TABLE (
	Old int, New int
)


MERGE INTO GBL_PrintProfile_Fld dst
USING (
SELECT New,PFLD_ID, gfo.FieldID AS GBLFieldID, vfo.FieldID AS VOLFieldID, FieldTypeID, HeadingLevel, LabelStyle, ContentStyle, Separator, src.DisplayOrder
FROM (SELECT
          N.value('PFLD_ID[1]', 'int') AS PFLD_ID ,
          N.value('ProfileID[1]', 'int') AS ProfileID ,
          N.value('GBLFieldName[1]', 'varchar(100)') AS GBLFieldName ,
          N.value('VOLFieldName[1]', 'varchar(100)') AS VOLFieldName ,
          N.value('FieldTypeID[1]', 'int') AS FieldTypeID ,
          N.value('HeadingLevel[1]', 'tinyint') AS HeadingLevel ,
          N.value('LabelStyle[1]', 'varchar(50)') AS LabelStyle ,
          N.value('ContentStyle[1]', 'varchar(50)') AS ContentStyle ,
          N.value('Separator[1]', 'nvarchar(50)') AS Separator ,
          N.value('DisplayOrder[1]', 'tinyint') AS DisplayOrder
FROM @xmlData.nodes('/PrintProfile/Fields/Field') AS T(N) ) src
LEFT JOIN @OLDPrintIDs ids
	ON ids.Old=src.ProfileID
LEFT JOIN GBL_FieldOption gfo
	ON GBLFieldName=gfo.FieldName
LEFT JOIN VOL_FieldOption vfo
	ON VOLFieldName=vfo.FieldName
) src
	ON 0=1
WHEN NOT MATCHED BY TARGET THEN
	INSERT
        ( ProfileID ,
          GBLFieldID ,
          VOLFieldID ,
          FieldTypeID ,
          HeadingLevel ,
          LabelStyle ,
          ContentStyle ,
          Separator ,
          DisplayOrder
        )
	VALUES
        (
          src.New ,
          src.GBLFieldID ,
          src.VOLFieldID ,
          src.FieldTypeID ,
          src.HeadingLevel ,
          src.LabelStyle ,
          src.ContentStyle ,
          src.Separator ,
          src.DisplayOrder
        )
	
	OUTPUT src.PFLD_ID, inserted.PFLD_ID INTO @OLDPFLD_ID
	;
	
	
	/*
INSERT INTO @OLDPFLD_ID ( Old, New )
SELECT  
          N.value('PFLD_ID[1]', 'int') AS PFLD_ID ,
          N.value('PFLD_ID[1]', 'int') + 200
FROM @xmlData.nodes('/PrintProfile/Fields/Field') AS T(N)
*/

SELECT * FROM @OLDPFLD_ID

INSERT INTO GBL_PrintProfile_Fld_Description
        ( PFLD_ID , LangID , Label , Prefix , Suffix , ContentIfEmpty )
SELECT New, LangID, Label, Prefix, Suffix, ContentIfEmpty 
FROM (SELECT 
          N.value('PFLD_ID[1]', 'int') AS PFLD_ID ,
          N.value('LangID[1]', 'smallint') AS LangID ,
          N.value('Label[1]', 'nvarchar(50)') AS Label ,
          N.value('Prefix[1]', 'nvarchar(100)') AS Prefix ,
          N.value('Suffix[1]', 'nvarchar(100)') AS Suffix ,
          N.value('ContentIfEmpty[1]', 'nvarchar(100)') AS ContentIfEmpty
FROM @xmlData.nodes('/PrintProfile/Fields/Field/Descriptions/Lang') AS T(N) ) src
LEFT JOIN @OLDPFLD_ID ids
	ON src.PFLD_ID=ids.Old
         
         
DECLARE @OLDPFLD_RP_ID TABLE (
	Old int, New int
)

MERGE INTO GBL_PrintProfile_Fld_FindReplace dst
USING (
SELECT New, LookFor, ReplaceWith, RunOrder, RegEx, MatchCase, MatchAll, PFLD_RP_ID
FROM (SELECT
          N.value('PFLD_RP_ID[1]', 'int') AS PFLD_RP_ID ,
          N.value('PFLD_ID[1]', 'int') AS PFLD_ID ,
          N.value('LookFor[1]', 'nvarchar(500)') AS LookFor ,
          N.value('ReplaceWith[1]', 'nvarchar(500)') AS ReplaceWith ,
          N.value('RunOrder[1]', 'tinyint') AS RunOrder ,
          N.value('RegEx[1]', 'bit') AS RegEx ,
          N.value('MatchCase[1]', 'bit') AS MatchCase ,
          N.value('MatchAll[1]', 'bit') AS MatchAll
FROM @xmlData.nodes('/PrintProfile/Fields/Field/Replacements/FindReplace') AS T(N) ) src
LEFT JOIN @OLDPFLD_ID ids
	ON src.PFLD_ID=ids.Old
) src
	ON 0=1
WHEN NOT MATCHED BY TARGET THEN
	INSERT
        ( PFLD_ID ,
          LookFor ,
          ReplaceWith ,
          RunOrder ,
          RegEx ,
          MatchCase ,
          MatchAll
        )
    VALUES
        (
		  src.New ,
          src.LookFor ,
          src.ReplaceWith ,
          src.RunOrder ,
          src.RegEx ,
          src.MatchCase ,
          src.MatchAll
        )
	
	OUTPUT src.PFLD_RP_ID, inserted.PFLD_RP_ID INTO @OLDPFLD_RP_ID
	;
	

/*
INSERT INTO @OLDPFLD_RP_ID ( Old, New )
SELECT
          N.value('PFLD_RP_ID[1]', 'int') AS PFLD_RP_ID ,
          N.value('PFLD_RP_ID[1]', 'int') + 400 
FROM @xmlData.nodes('/PrintProfile/Fields/Field/Replacements/FindReplace') AS T(N) 
*/

SELECT * FROM @OLDPFLD_RP_ID

INSERT INTO GBL_PrintProfile_Fld_FindReplace_Lang
        ( PFLD_RP_ID, LangID )
SELECT New, LangID
FROM(SELECT
        N.value('../../PFLD_RP_ID[1]', 'int') AS PFLD_RP_ID,
        N.value('.', 'int') AS LangID 
FROM @xmlData.nodes('/PrintProfile/Fields/Field/Replacements/FindReplace/Languages/LangID') AS T(N) ) src
LEFT JOIN @OLDPFLD_RP_ID ids
	ON ids.Old=Src.PFLD_RP_ID

END
-- Print Profiles


-- Excel Profiles
IF 0=1 BEGIN
SET @ObjectType='Excel Profile'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @OLDExcelProfileIDs TABLE (
	Old int,
	New int
)

MERGE INTO GBL_ExcelProfile dst
USING (
SELECT  
      N.value('ProfileID[1]', 'int') AS ProfileID ,
      N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE ,
      N.value('CREATED_BY[1]', 'varchar(50)') AS CREATED_BY ,
      N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE ,
      N.value('MODIFIED_BY[1]', 'varchar(50)') AS MODIFIED_BY ,
      N.value('MemberID[1]', 'int') AS MemberID ,
      N.value('Domain[1]', 'tinyint') AS Domain ,
      N.value('ColumnHeaders[1]', 'bit') AS ColumnHeaders
FROM @xmlData.nodes('/ExcelProfile') AS T(N)
)src
	ON 0=1
WHEN NOT MATCHED BY TARGET THEN
	INSERT
        ( CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          MemberID ,
          Domain ,
          ColumnHeaders
        )
    VALUES
        ( src.CREATED_DATE ,
          src.CREATED_BY ,
          src.MODIFIED_DATE ,
          src.MODIFIED_BY ,
          @MemberID,
          src.Domain ,
          src.ColumnHeaders
        )
       
   OUTPUT src.ProfileID, inserted.ProfileID INTO @OLDExcelProfileIDs
;

/*  
INSERT INTO @OLDExcelProfileIDs
        ( Old, New )
SELECT  
      N.value('ProfileID[1]', 'int') AS ProfileID ,
      N.value('ProfileID[1]', 'int') + 100 AS ProfileID
FROM @xmlData.nodes('/ExcelProfile') AS T(N)

*/

SELECT * FROM @OLDExcelProfileIDs

INSERT INTO GBL_ExcelProfile_Name
        ( ProfileID, LangID, Name )
SELECT New, LangID, Name
FROM( SELECT 
        N.value('../../ProfileID[1]', 'int') AS ProfileID , 
        N.value('LangID[1]', 'smallint') AS LangID , 
        N.value('Name[1]', 'nvarchar(100)') AS Name
FROM @xmlData.nodes('/ExcelProfile/Descriptions/Lang') AS T(N)) src
LEFT JOIN @OLDExcelProfileIDs ids
	ON ids.Old=src.ProfileID


INSERT INTO GBL_ExcelProfile_Fld
        ( ProfileID ,
          GBLFieldID ,
          VOLFieldID ,
          DisplayOrder ,
          SortByOrder
        )
SELECT New, gfo.FieldID AS GBLFieldID, vfo.FieldID AS VOLFieldID, src.DisplayOrder, src.SortByOrder
FROM (SELECT 
          N.value('../../ProfileID[1]', 'int') AS ProfileID ,
          N.value('GBLField[1]', 'varchar(100)') AS GBLField,
          N.value('VOLField[1]', 'varchar(100)') AS VOLField,
          N.value('DisplayOrder[1]', 'tinyint') AS DisplayOrder ,
          N.value('SortByOrder[1]', 'tinyint') AS SortByOrder
FROM @xmlData.nodes('/ExcelProfile/Fields/Field') AS T(N)) src
LEFT JOIN @OLDExcelProfileIDs ids
	ON ids.Old=src.ProfileID
LEFT JOIN GBL_FieldOption gfo
	ON src.GBLField=gfo.FieldName
LEFT JOIN VOL_FieldOption vfo
	ON src.VOLField=vfo.FieldName
	
	
INSERT INTO CIC_View_ExcelProfile
        ( ViewType, ProfileID )
SELECT ViewType, New
FROM (SELECT
     (SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('.', 'nvarchar(255)')) AS ViewType,
     N.value('../../ProfileID[1]', 'int') AS ProfileID 
FROM @xmlData.nodes('/ExcelProfile/Views/ViewName') AS T(N)) src
LEFT JOIN @OLDExcelProfileIDs ids
	ON ids.Old=src.ProfileID

END
-- Excel Profiles


-- GBL Feedback
IF 0=1 BEGIN

-- TODO CIC_Feedback_Extra and CIC_Feedback_Publication
  
SET @ObjectType='GBL Feedback'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @OLDGBLFB_ID TABLE (
	Old int,
	New int
)

MERGE INTO GBL_FeedbackEntry dst
USING (
SELECT 
      N.value('FB_ID[1]', 'int') AS FB_ID ,
      @MemberID AS MemberID,
      N.value('FEEDBACK_OWNER[1]', 'char(3)') AS FEEDBACK_OWNER ,
      N.value('NUM[1]', 'varchar(8)') AS NUM ,
      N.value('LangID[1]', 'smallint') AS LangID ,
      N.value('SUBMIT_DATE[1]', 'smalldatetime') AS SUBMIT_DATE ,
      N.value('IPAddress[1]', 'varchar(20)') AS IPAddress ,
      u.User_ID,
     (SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('ViewTypeName[1]', 'nvarchar(255)')) AS ViewType,
      N.value('AccessURL[1]', 'varchar(160)') AS AccessURL ,
      N.value('FBKEY[1]', 'varchar(6)') AS FBKEY ,
      N.value('FULL_UPDATE[1]', 'bit') AS FULL_UPDATE ,
      N.value('NO_CHANGES[1]', 'bit') AS NO_CHANGES ,
      N.value('REMOVE_RECORD[1]', 'bit') AS REMOVE_RECORD ,
      N.value('AUTH_INQUIRY[1]', 'bit') AS AUTH_INQUIRY ,
      N.value('AUTH_ONLINE[1]', 'bit') AS AUTH_ONLINE ,
      N.value('AUTH_PRINT[1]', 'bit') AS AUTH_PRINT ,
      N.value('AUTH_TYPE[1]', 'char(1)') AS AUTH_TYPE ,
      N.value('FB_NOTES[1]', 'nvarchar(max)') AS FB_NOTES ,
      N.value('SOURCE_NAME[1]', 'nvarchar(100)') AS SOURCE_NAME ,
      N.value('SOURCE_TITLE[1]', 'nvarchar(100)') AS SOURCE_TITLE ,
      N.value('SOURCE_ORG[1]', 'nvarchar(100)') AS SOURCE_ORG ,
      N.value('SOURCE_PHONE[1]', 'nvarchar(100)') AS SOURCE_PHONE ,
      N.value('SOURCE_FAX[1]', 'nvarchar(100)') AS SOURCE_FAX ,
      N.value('SOURCE_EMAIL[1]', 'nvarchar(60)') AS SOURCE_EMAIL ,
      N.value('SOURCE_BUILDING[1]', 'nvarchar(150)') AS SOURCE_BUILDING ,
      N.value('SOURCE_ADDRESS[1]', 'nvarchar(150)') AS SOURCE_ADDRESS ,
      N.value('SOURCE_CITY[1]', 'nvarchar(100)') AS SOURCE_CITY ,
      N.value('SOURCE_PROVINCE[1]', 'nvarchar(10)') AS SOURCE_PROVINCE ,
      N.value('SOURCE_POSTAL_CODE[1]', 'nvarchar(10)') AS SOURCE_POSTAL_CODE
FROM @xmlData.nodes('/FeedbackEntry') AS T(N)
LEFT JOIN GBL_Users u 
	ON u.MemberID_Cache=@MemberID AND u.UserUID=N.value('UserUID[1]', 'uniqueidentifier')
) src
	ON 0=1
WHEN NOT MATCHED BY TARGET  THEN
	INSERT
        ( MemberID ,
          FEEDBACK_OWNER ,
          NUM ,
          LangID ,
          SUBMIT_DATE ,
          IPAddress ,
          User_ID ,
          ViewType ,
          AccessURL ,
          FBKEY ,
          FULL_UPDATE ,
          NO_CHANGES ,
          REMOVE_RECORD ,
          AUTH_INQUIRY ,
          AUTH_ONLINE ,
          AUTH_PRINT ,
          AUTH_TYPE ,
          FB_NOTES ,
          SOURCE_NAME ,
          SOURCE_TITLE ,
          SOURCE_ORG ,
          SOURCE_PHONE ,
          SOURCE_FAX ,
          SOURCE_EMAIL ,
          SOURCE_BUILDING ,
          SOURCE_ADDRESS ,
          SOURCE_CITY ,
          SOURCE_PROVINCE ,
          SOURCE_POSTAL_CODE
        )
    VALUES
        ( src.MemberID ,
          src.FEEDBACK_OWNER ,
          src.NUM ,
          src.LangID ,
          src.SUBMIT_DATE ,
          src.IPAddress ,
          src.User_ID ,
          src.ViewType ,
          src.AccessURL ,
          src.FBKEY ,
          src.FULL_UPDATE ,
          src.NO_CHANGES ,
          src.REMOVE_RECORD ,
          src.AUTH_INQUIRY ,
          src.AUTH_ONLINE ,
          src.AUTH_PRINT ,
          src.AUTH_TYPE ,
          src.FB_NOTES ,
          src.SOURCE_NAME ,
          src.SOURCE_TITLE ,
          src.SOURCE_ORG ,
          src.SOURCE_PHONE ,
          src.SOURCE_FAX ,
          src.SOURCE_EMAIL ,
          src.SOURCE_BUILDING ,
          src.SOURCE_ADDRESS ,
          src.SOURCE_CITY ,
          src.SOURCE_PROVINCE ,
          src.SOURCE_POSTAL_CODE
        )
	
	OUTPUT src.FB_ID, Inserted.FB_ID INTO @OLDGBLFB_ID
	
	;
	
/*
INSERT INTO @OLDGBLFB_ID ( Old, New )
SELECT 
      N.value('FB_ID[1]', 'int') AS MemberID ,
      N.value('FB_ID[1]', 'int') + 2000
FROM @xmlData.nodes('/FeedbackEntry') AS T(N)
*/

SELECT * FROM @OLDGBLFB_ID

INSERT INTO GBL_Feedback
        ( FB_ID ,
          ACCESSIBILITY ,
          ALT_ORG ,
          BILLING_ADDRESSES ,
          COLLECTED_DATE ,
          COLLECTED_BY ,
          CONTACT_1_NAME ,
          CONTACT_1_TITLE ,
          CONTACT_1_ORG ,
          CONTACT_1_PHONE1 ,
          CONTACT_1_PHONE2 ,
          CONTACT_1_PHONE3 ,
          CONTACT_1_FAX ,
          CONTACT_1_EMAIL ,
          CONTACT_2_NAME ,
          CONTACT_2_TITLE ,
          CONTACT_2_ORG ,
          CONTACT_2_PHONE1 ,
          CONTACT_2_PHONE3 ,
          CONTACT_2_PHONE2 ,
          CONTACT_2_FAX ,
          CONTACT_2_EMAIL ,
          CONTRACT_SIGNATURE ,
          DESCRIPTION ,
          ESTABLISHED ,
          E_MAIL ,
          EXEC_1_NAME ,
          EXEC_1_TITLE ,
          EXEC_1_ORG ,
          EXEC_1_PHONE1 ,
          EXEC_1_PHONE2 ,
          EXEC_1_PHONE3 ,
          EXEC_1_FAX ,
          EXEC_1_EMAIL ,
          EXEC_2_NAME ,
          EXEC_2_TITLE ,
          EXEC_2_ORG ,
          EXEC_2_PHONE1 ,
          EXEC_2_PHONE2 ,
          EXEC_2_PHONE3 ,
          EXEC_2_FAX ,
          EXEC_2_EMAIL ,
          FAX ,
          FORMER_ORG ,
          GEOCODE_NOTES ,
          GEOCODE_TYPE ,
          LATITUDE ,
          LONGITUDE ,
          LEGAL_ORG ,
          LOCATED_IN_CM ,
          MAIL_CARE_OF ,
          MAIL_BOX_TYPE ,
          MAIL_PO_BOX ,
          MAIL_BUILDING ,
          MAIL_STREET_NUMBER ,
          MAIL_STREET ,
          MAIL_STREET_TYPE ,
          MAIL_STREET_TYPE_AFTER ,
          MAIL_STREET_DIR ,
          MAIL_SUFFIX ,
          MAIL_CITY ,
          MAIL_PROVINCE ,
          MAIL_COUNTRY ,
          MAIL_POSTAL_CODE ,
          MAP_LINK ,
          NO_UPDATE_EMAIL ,
          NON_PUBLIC ,
          OFFICE_PHONE ,
          ORG_LEVEL_1 ,
          ORG_LEVEL_2 ,
          ORG_LEVEL_3 ,
          ORG_LEVEL_4 ,
          ORG_LEVEL_5 ,
          SITE_BUILDING ,
          SITE_STREET_NUMBER ,
          SITE_STREET ,
          SITE_STREET_TYPE ,
          SITE_STREET_TYPE_AFTER ,
          SITE_STREET_DIR ,
          SITE_SUFFIX ,
          SITE_CITY ,
          SITE_PROVINCE ,
          SITE_COUNTRY ,
          SITE_POSTAL_CODE ,
          SOCIAL_MEDIA ,
          SORT_AS ,
          TOLL_FREE_PHONE ,
          UPDATE_EMAIL ,
          VOLCONTACT_NAME ,
          VOLCONTACT_TITLE ,
          VOLCONTACT_ORG ,
          VOLCONTACT_PHONE1 ,
          VOLCONTACT_PHONE2 ,
          VOLCONTACT_PHONE3 ,
          VOLCONTACT_FAX ,
          VOLCONTACT_EMAIL ,
          WWW_ADDRESS ,
          ORG_DESCRIPTION ,
          LOCATION_DESCRIPTION ,
          LOCATION_NAME ,
          SERVICE_NAME_LEVEL_1 ,
          SERVICE_NAME_LEVEL_2
        )
SELECT New, 
          ACCESSIBILITY ,
          ALT_ORG ,
          BILLING_ADDRESSES ,
          COLLECTED_DATE ,
          COLLECTED_BY ,
          CONTACT_1_NAME ,
          CONTACT_1_TITLE ,
          CONTACT_1_ORG ,
          CONTACT_1_PHONE1 ,
          CONTACT_1_PHONE2 ,
          CONTACT_1_PHONE3 ,
          CONTACT_1_FAX ,
          CONTACT_1_EMAIL ,
          CONTACT_2_NAME ,
          CONTACT_2_TITLE ,
          CONTACT_2_ORG ,
          CONTACT_2_PHONE1 ,
          CONTACT_2_PHONE3 ,
          CONTACT_2_PHONE2 ,
          CONTACT_2_FAX ,
          CONTACT_2_EMAIL ,
          CONTRACT_SIGNATURE ,
          DESCRIPTION ,
          ESTABLISHED ,
          E_MAIL ,
          EXEC_1_NAME ,
          EXEC_1_TITLE ,
          EXEC_1_ORG ,
          EXEC_1_PHONE1 ,
          EXEC_1_PHONE2 ,
          EXEC_1_PHONE3 ,
          EXEC_1_FAX ,
          EXEC_1_EMAIL ,
          EXEC_2_NAME ,
          EXEC_2_TITLE ,
          EXEC_2_ORG ,
          EXEC_2_PHONE1 ,
          EXEC_2_PHONE2 ,
          EXEC_2_PHONE3 ,
          EXEC_2_FAX ,
          EXEC_2_EMAIL ,
          FAX ,
          FORMER_ORG ,
          GEOCODE_NOTES ,
          GEOCODE_TYPE ,
          LATITUDE ,
          LONGITUDE ,
          LEGAL_ORG ,
          LOCATED_IN_CM ,
          MAIL_CARE_OF ,
          MAIL_BOX_TYPE ,
          MAIL_PO_BOX ,
          MAIL_BUILDING ,
          MAIL_STREET_NUMBER ,
          MAIL_STREET ,
          MAIL_STREET_TYPE ,
          MAIL_STREET_TYPE_AFTER ,
          MAIL_STREET_DIR ,
          MAIL_SUFFIX ,
          MAIL_CITY ,
          MAIL_PROVINCE ,
          MAIL_COUNTRY ,
          MAIL_POSTAL_CODE ,
          MAP_LINK ,
          NO_UPDATE_EMAIL ,
          NON_PUBLIC ,
          OFFICE_PHONE ,
          ORG_LEVEL_1 ,
          ORG_LEVEL_2 ,
          ORG_LEVEL_3 ,
          ORG_LEVEL_4 ,
          ORG_LEVEL_5 ,
          SITE_BUILDING ,
          SITE_STREET_NUMBER ,
          SITE_STREET ,
          SITE_STREET_TYPE ,
          SITE_STREET_TYPE_AFTER ,
          SITE_STREET_DIR ,
          SITE_SUFFIX ,
          SITE_CITY ,
          SITE_PROVINCE ,
          SITE_COUNTRY ,
          SITE_POSTAL_CODE ,
          SOCIAL_MEDIA ,
          SORT_AS ,
          TOLL_FREE_PHONE ,
          UPDATE_EMAIL ,
          VOLCONTACT_NAME ,
          VOLCONTACT_TITLE ,
          VOLCONTACT_ORG ,
          VOLCONTACT_PHONE1 ,
          VOLCONTACT_PHONE2 ,
          VOLCONTACT_PHONE3 ,
          VOLCONTACT_FAX ,
          VOLCONTACT_EMAIL ,
          WWW_ADDRESS ,
          ORG_DESCRIPTION ,
          LOCATION_DESCRIPTION ,
          LOCATION_NAME ,
          SERVICE_NAME_LEVEL_1 ,
          SERVICE_NAME_LEVEL_2
FROM (
SELECT 
		  N.value('FB_ID[1]', 'int') AS FB_ID ,
          N.value('ACCESSIBILITY[1]', 'nvarchar(max)') AS ACCESSIBILITY ,
          N.value('ALT_ORG[1]', 'nvarchar(max)') AS ALT_ORG ,
          N.value('BILLING_ADDRESSES[1]', 'nvarchar(max)') AS BILLING_ADDRESSES ,
          N.value('COLLECTED_DATE[1]', 'varchar(25)') AS COLLECTED_DATE ,
          N.value('COLLECTED_BY[1]', 'varchar(50)') AS COLLECTED_BY ,
          N.value('CONTACT_1_NAME[1]', 'nvarchar(100)') AS CONTACT_1_NAME ,
          N.value('CONTACT_1_TITLE[1]', 'nvarchar(100)') AS CONTACT_1_TITLE ,
          N.value('CONTACT_1_ORG[1]', 'nvarchar(100)') AS CONTACT_1_ORG ,
          N.value('CONTACT_1_PHONE1[1]', 'nvarchar(100)') AS CONTACT_1_PHONE1 ,
          N.value('CONTACT_1_PHONE2[1]', 'nvarchar(100)') AS CONTACT_1_PHONE2 ,
          N.value('CONTACT_1_PHONE3[1]', 'nvarchar(100)') AS CONTACT_1_PHONE3 ,
          N.value('CONTACT_1_FAX[1]', 'nvarchar(100)') AS CONTACT_1_FAX ,
          N.value('CONTACT_1_EMAIL[1]', 'nvarchar(60)') AS CONTACT_1_EMAIL ,
          N.value('CONTACT_2_NAME[1]', 'nvarchar(100)') AS CONTACT_2_NAME ,
          N.value('CONTACT_2_TITLE[1]', 'nvarchar(100)') AS CONTACT_2_TITLE ,
          N.value('CONTACT_2_ORG[1]', 'nvarchar(100)') AS CONTACT_2_ORG ,
          N.value('CONTACT_2_PHONE1[1]', 'nvarchar(100)') AS CONTACT_2_PHONE1 ,
          N.value('CONTACT_2_PHONE3[1]', 'nvarchar(100)') AS CONTACT_2_PHONE3 ,
          N.value('CONTACT_2_PHONE2[1]', 'nvarchar(100)') AS CONTACT_2_PHONE2 ,
          N.value('CONTACT_2_FAX[1]', 'nvarchar(100)') AS CONTACT_2_FAX ,
          N.value('CONTACT_2_EMAIL[1]', 'nvarchar(60)') AS CONTACT_2_EMAIL ,
          N.value('CONTRACT_SIGNATURE[1]', 'nvarchar(max)') AS CONTRACT_SIGNATURE ,
          N.value('DESCRIPTION[1]', 'nvarchar(max)') AS DESCRIPTION ,
          N.value('ESTABLISHED[1]', 'nvarchar(150)') AS ESTABLISHED ,
          N.value('E_MAIL[1]', 'nvarchar(60)') AS E_MAIL ,
          N.value('EXEC_1_NAME[1]', 'nvarchar(100)') AS EXEC_1_NAME ,
          N.value('EXEC_1_TITLE[1]', 'nvarchar(100)') AS EXEC_1_TITLE ,
          N.value('EXEC_1_ORG[1]', 'nvarchar(100)') AS EXEC_1_ORG ,
          N.value('EXEC_1_PHONE1[1]', 'nvarchar(100)') AS EXEC_1_PHONE1 ,
          N.value('EXEC_1_PHONE2[1]', 'nvarchar(100)') AS EXEC_1_PHONE2 ,
          N.value('EXEC_1_PHONE3[1]', 'nvarchar(100)') AS EXEC_1_PHONE3 ,
          N.value('EXEC_1_FAX[1]', 'nvarchar(100)') AS EXEC_1_FAX ,
          N.value('EXEC_1_EMAIL[1]', 'nvarchar(60)') AS EXEC_1_EMAIL ,
          N.value('EXEC_2_NAME[1]', 'nvarchar(100)') AS EXEC_2_NAME ,
          N.value('EXEC_2_TITLE[1]', 'nvarchar(100)') AS EXEC_2_TITLE ,
          N.value('EXEC_2_ORG[1]', 'nvarchar(100)') AS EXEC_2_ORG ,
          N.value('EXEC_2_PHONE1[1]', 'nvarchar(100)') AS EXEC_2_PHONE1 ,
          N.value('EXEC_2_PHONE2[1]', 'nvarchar(100)') AS EXEC_2_PHONE2 ,
          N.value('EXEC_2_PHONE3[1]', 'nvarchar(100)') AS EXEC_2_PHONE3 ,
          N.value('EXEC_2_FAX[1]', 'nvarchar(100)') AS EXEC_2_FAX ,
          N.value('EXEC_2_EMAIL[1]', 'nvarchar(60)') AS EXEC_2_EMAIL ,
          N.value('FAX[1]', 'nvarchar(255)') AS FAX ,
          N.value('FORMER_ORG[1]', 'nvarchar(max)') AS FORMER_ORG ,
          N.value('GEOCODE_NOTES[1]', 'nvarchar(255)') AS GEOCODE_NOTES ,
          N.value('GEOCODE_TYPE[1]', 'tinyint') AS GEOCODE_TYPE ,
          N.value('LATITUDE[1]', 'decimal(11,7)') AS LATITUDE ,
          N.value('LONGITUDE[1]', 'decimal(11,7)') AS LONGITUDE ,
          N.value('LEGAL_ORG[1]', 'nvarchar(255)') AS LEGAL_ORG ,
          N.value('LOCATED_IN_CM[1]', 'nvarchar(max)') AS LOCATED_IN_CM ,
          N.value('MAIL_CARE_OF[1]', 'nvarchar(100)') AS MAIL_CARE_OF ,
          N.value('MAIL_BOX_TYPE[1]', 'nvarchar(20)') AS MAIL_BOX_TYPE ,
          N.value('MAIL_PO_BOX[1]', 'nvarchar(20)') AS MAIL_PO_BOX ,
          N.value('MAIL_BUILDING[1]', 'nvarchar(150)') AS MAIL_BUILDING ,
          N.value('MAIL_STREET_NUMBER[1]', 'nvarchar(30)') AS MAIL_STREET_NUMBER ,
          N.value('MAIL_STREET[1]', 'nvarchar(150)') AS MAIL_STREET ,
          N.value('MAIL_STREET_TYPE[1]', 'nvarchar(20)') AS MAIL_STREET_TYPE ,
          N.value('MAIL_STREET_TYPE_AFTER[1]', 'bit') AS MAIL_STREET_TYPE_AFTER ,
          N.value('MAIL_STREET_DIR[1]', 'nvarchar(10)') AS MAIL_STREET_DIR ,
          N.value('MAIL_SUFFIX[1]', 'nvarchar(150)') AS MAIL_SUFFIX ,
          N.value('MAIL_CITY[1]', 'nvarchar(100)') AS MAIL_CITY ,
          N.value('MAIL_PROVINCE[1]', 'nvarchar(10)') AS MAIL_PROVINCE ,
          N.value('MAIL_COUNTRY[1]', 'nvarchar(60)') AS MAIL_COUNTRY ,
          N.value('MAIL_POSTAL_CODE[1]', 'nvarchar(20)') AS MAIL_POSTAL_CODE ,
          N.value('MAP_LINK[1]', 'nvarchar(max)') AS MAP_LINK ,
          N.value('NO_UPDATE_EMAIL[1]', 'nvarchar(20)') AS NO_UPDATE_EMAIL ,
          N.value('NON_PUBLIC[1]', 'nvarchar(20)') AS NON_PUBLIC ,
          N.value('OFFICE_PHONE[1]', 'nvarchar(max)') AS OFFICE_PHONE ,
          N.value('ORG_LEVEL_1[1]', 'nvarchar(200)') AS ORG_LEVEL_1 ,
          N.value('ORG_LEVEL_2[1]', 'nvarchar(200)') AS ORG_LEVEL_2 ,
          N.value('ORG_LEVEL_3[1]', 'nvarchar(200)') AS ORG_LEVEL_3 ,
          N.value('ORG_LEVEL_4[1]', 'nvarchar(200)') AS ORG_LEVEL_4 ,
          N.value('ORG_LEVEL_5[1]', 'nvarchar(200)') AS ORG_LEVEL_5 ,
          N.value('SITE_BUILDING[1]', 'nvarchar(150)') AS SITE_BUILDING ,
          N.value('SITE_STREET_NUMBER[1]', 'nvarchar(30)') AS SITE_STREET_NUMBER ,
          N.value('SITE_STREET[1]', 'nvarchar(150)') AS SITE_STREET ,
          N.value('SITE_STREET_TYPE[1]', 'nvarchar(20)') AS SITE_STREET_TYPE ,
          N.value('SITE_STREET_TYPE_AFTER[1]', 'bit') AS SITE_STREET_TYPE_AFTER ,
          N.value('SITE_STREET_DIR[1]', 'nvarchar(10)') AS SITE_STREET_DIR ,
          N.value('SITE_SUFFIX[1]', 'nvarchar(150)') AS SITE_SUFFIX ,
          N.value('SITE_CITY[1]', 'nvarchar(100)') AS SITE_CITY ,
          N.value('SITE_PROVINCE[1]', 'nvarchar(10)') AS SITE_PROVINCE ,
          N.value('SITE_COUNTRY[1]', 'nvarchar(60)') AS SITE_COUNTRY ,
          N.value('SITE_POSTAL_CODE[1]', 'nvarchar(20)') AS SITE_POSTAL_CODE ,
          N.value('SOCIAL_MEDIA[1]', 'nvarchar(max)') AS SOCIAL_MEDIA ,
          N.value('SORT_AS[1]', 'nvarchar(255)') AS SORT_AS ,
          N.value('TOLL_FREE_PHONE[1]', 'nvarchar(max)') AS TOLL_FREE_PHONE ,
          N.value('UPDATE_EMAIL[1]', 'nvarchar(60)') AS UPDATE_EMAIL ,
          N.value('VOLCONTACT_NAME[1]', 'nvarchar(100)') AS VOLCONTACT_NAME ,
          N.value('VOLCONTACT_TITLE[1]', 'nvarchar(100)') AS VOLCONTACT_TITLE ,
          N.value('VOLCONTACT_ORG[1]', 'nvarchar(100)') AS VOLCONTACT_ORG ,
          N.value('VOLCONTACT_PHONE1[1]', 'nvarchar(100)') AS VOLCONTACT_PHONE1 ,
          N.value('VOLCONTACT_PHONE2[1]', 'nvarchar(100)') AS VOLCONTACT_PHONE2 ,
          N.value('VOLCONTACT_PHONE3[1]', 'nvarchar(100)') AS VOLCONTACT_PHONE3 ,
          N.value('VOLCONTACT_FAX[1]', 'nvarchar(100)') AS VOLCONTACT_FAX ,
          N.value('VOLCONTACT_EMAIL[1]', 'nvarchar(60)') AS VOLCONTACT_EMAIL ,
          N.value('WWW_ADDRESS[1]', 'nvarchar(200)') AS WWW_ADDRESS ,
          N.value('ORG_DESCRIPTION[1]', 'nvarchar(max)') AS ORG_DESCRIPTION ,
          N.value('LOCATION_DESCRIPTION[1]', 'nvarchar(max)') AS LOCATION_DESCRIPTION ,
          N.value('LOCATION_NAME[1]', 'nvarchar(200)') AS LOCATION_NAME ,
          N.value('SERVICE_NAME_LEVEL_1[1]', 'nvarchar(200)') AS SERVICE_NAME_LEVEL_1 ,
          N.value('SERVICE_NAME_LEVEL_2[1]', 'nvarchar(200)') AS SERVICE_NAME_LEVEL_2
FROM @xmlData.nodes('/FeedbackEntry/GBLs/GBLFeedback') AS T(N)

) src
INNER JOIN @OLDGBLFB_ID ids
	ON ids.Old=src.FB_ID
	
INSERT INTO CIC_Feedback
        ( FB_ID ,
          ACCREDITED ,
          ACTIVITY_INFO ,
          AFTER_HRS_PHONE ,
          APPLICATION ,
          AREAS_SERVED ,
          BOUNDARIES ,
          BUS_ROUTES ,
          CERTIFIED ,
          COMMENTS ,
          CORP_REG_NO ,
          CRISIS_PHONE ,
          DATES ,
          DD_CODE ,
          DISTRIBUTION ,
          ELECTIONS ,
          ELIGIBILITY_NOTES ,
          EMPLOYEES_FT ,
          EMPLOYEES_PT ,
          EMPLOYEES_TOTAL ,
          EMPLOYEES_RANGE ,
          FEES ,
          FISCAL_YEAR_END ,
          FUNDING ,
          HOURS ,
          INTERNAL_MEMO ,
          INTERSECTION ,
          LANGUAGES ,
          LOGO_ADDRESS ,
          LOGO_ADDRESS_LINK ,
          MAX_AGE ,
          MIN_AGE ,
          MEETINGS ,
          MEMBERSHIP ,
          NAICS ,
          OCG_NO ,
          OTHER_ADDRESSES ,
          PAYMENT_TERMS ,
          PREF_CURRENCY ,
          PREF_PAYMENT_METHOD ,
          PRINT_MATERIAL ,
          PUBLIC_COMMENTS ,
          QUALITY ,
          RECORD_TYPE ,
          RESOURCES ,
          SERVICE_LEVEL ,
          SITE_LOCATION ,
          SUBJECTS ,
          SUP_DESCRIPTION ,
          TAX_REG_NO ,
          TAXONOMY ,
          TDD_PHONE ,
          TRANSPORTATION ,
          VACANCY_INFO ,
          WARD ,
          WCB_NO ,
          EXTRA_CHECKLIST_A ,
          EXTRA_CHECKLIST_B ,
          EXTRA_CHECKLIST_C ,
          EXTRA_CHECKLIST_D ,
          EXTRA_CHECKLIST_E ,
          EXTRA_CHECKLIST_F ,
          EXTRA_CONTACT_A_NAME ,
          EXTRA_CONTACT_A_TITLE ,
          EXTRA_CONTACT_A_ORG ,
          EXTRA_CONTACT_A_PHONE1 ,
          EXTRA_CONTACT_A_PHONE2 ,
          EXTRA_CONTACT_A_PHONE3 ,
          EXTRA_CONTACT_A_FAX ,
          EXTRA_CONTACT_A_EMAIL ,
          EXTRA_DROPDOWN_A ,
          EXTRA_DROPDOWN_B ,
          EXTRA_DROPDOWN_C ,
          EXTRA_DROPDOWN_D ,
          EXTRA_DROPDOWN_E ,
          EXTRA_DROPDOWN_F ,
          EXTRA_DROPDOWN_G ,
          EXTRA_DROPDOWN_H
        )
SELECT New,
          ACCREDITED ,
          ACTIVITY_INFO ,
          AFTER_HRS_PHONE ,
          APPLICATION ,
          AREAS_SERVED ,
          BOUNDARIES ,
          BUS_ROUTES ,
          CERTIFIED ,
          COMMENTS ,
          CORP_REG_NO ,
          CRISIS_PHONE ,
          DATES ,
          DD_CODE ,
          DISTRIBUTION ,
          ELECTIONS ,
          ELIGIBILITY_NOTES ,
          EMPLOYEES_FT ,
          EMPLOYEES_PT ,
          EMPLOYEES_TOTAL ,
          EMPLOYEES_RANGE ,
          FEES ,
          FISCAL_YEAR_END ,
          FUNDING ,
          HOURS ,
          INTERNAL_MEMO ,
          INTERSECTION ,
          LANGUAGES ,
          LOGO_ADDRESS ,
          LOGO_ADDRESS_LINK ,
          MAX_AGE ,
          MIN_AGE ,
          MEETINGS ,
          MEMBERSHIP ,
          NAICS ,
          OCG_NO ,
          OTHER_ADDRESSES ,
          PAYMENT_TERMS ,
          PREF_CURRENCY ,
          PREF_PAYMENT_METHOD ,
          PRINT_MATERIAL ,
          PUBLIC_COMMENTS ,
          QUALITY ,
          RECORD_TYPE ,
          RESOURCES ,
          SERVICE_LEVEL ,
          SITE_LOCATION ,
          SUBJECTS ,
          SUP_DESCRIPTION ,
          TAX_REG_NO ,
          TAXONOMY ,
          TDD_PHONE ,
          TRANSPORTATION ,
          VACANCY_INFO ,
          WARD ,
          WCB_NO ,
          EXTRA_CHECKLIST_A ,
          EXTRA_CHECKLIST_B ,
          EXTRA_CHECKLIST_C ,
          EXTRA_CHECKLIST_D ,
          EXTRA_CHECKLIST_E ,
          EXTRA_CHECKLIST_F ,
          EXTRA_CONTACT_A_NAME ,
          EXTRA_CONTACT_A_TITLE ,
          EXTRA_CONTACT_A_ORG ,
          EXTRA_CONTACT_A_PHONE1 ,
          EXTRA_CONTACT_A_PHONE2 ,
          EXTRA_CONTACT_A_PHONE3 ,
          EXTRA_CONTACT_A_FAX ,
          EXTRA_CONTACT_A_EMAIL ,
          EXTRA_DROPDOWN_A ,
          EXTRA_DROPDOWN_B ,
          EXTRA_DROPDOWN_C ,
          EXTRA_DROPDOWN_D ,
          EXTRA_DROPDOWN_E ,
          EXTRA_DROPDOWN_F ,
          EXTRA_DROPDOWN_G ,
          EXTRA_DROPDOWN_H
FROM (
SELECT 
		  N.value('FB_ID[1]', 'int') AS FB_ID ,
          N.value('ACCREDITED[1]', 'nvarchar(255)') AS ACCREDITED ,
          N.value('ACTIVITY_INFO[1]', 'nvarchar(max)') AS ACTIVITY_INFO ,
          N.value('AFTER_HRS_PHONE[1]', 'nvarchar(255)') AS AFTER_HRS_PHONE ,
          N.value('APPLICATION[1]', 'nvarchar(max)') AS APPLICATION ,
          N.value('AREAS_SERVED[1]', 'nvarchar(max)') AS AREAS_SERVED ,
          N.value('BOUNDARIES[1]', 'nvarchar(max)') AS BOUNDARIES ,
          N.value('BUS_ROUTES[1]', 'nvarchar(max)') AS BUS_ROUTES ,
          N.value('CERTIFIED[1]', 'nvarchar(255)') AS CERTIFIED ,
          N.value('COMMENTS[1]', 'nvarchar(max)') AS COMMENTS ,
          N.value('CORP_REG_NO[1]', 'nvarchar(100)') AS CORP_REG_NO ,
          N.value('CRISIS_PHONE[1]', 'nvarchar(255)') AS CRISIS_PHONE ,
          N.value('DATES[1]', 'nvarchar(max)') AS DATES ,
          N.value('DD_CODE[1]', 'nvarchar(200)') AS DD_CODE ,
          N.value('DISTRIBUTION[1]', 'nvarchar(max)') AS DISTRIBUTION ,
          N.value('ELECTIONS[1]', 'nvarchar(255)') AS ELECTIONS ,
          N.value('ELIGIBILITY_NOTES[1]', 'nvarchar(max)') AS ELIGIBILITY_NOTES ,
          N.value('EMPLOYEES_FT[1]', 'nvarchar(20)') AS EMPLOYEES_FT ,
          N.value('EMPLOYEES_PT[1]', 'nvarchar(20)') AS EMPLOYEES_PT ,
          N.value('EMPLOYEES_TOTAL[1]', 'nvarchar(20)') AS EMPLOYEES_TOTAL ,
          N.value('EMPLOYEES_RANGE[1]', 'nvarchar(20)') AS EMPLOYEES_RANGE ,
          N.value('FEES[1]', 'nvarchar(max)') AS FEES ,
          N.value('FISCAL_YEAR_END[1]', 'nvarchar(200)') AS FISCAL_YEAR_END ,
          N.value('FUNDING[1]', 'nvarchar(max)') AS FUNDING ,
          N.value('HOURS[1]', 'nvarchar(max)') AS HOURS ,
          N.value('INTERNAL_MEMO[1]', 'nvarchar(max)') AS INTERNAL_MEMO ,
          N.value('INTERSECTION[1]', 'nvarchar(255)') AS INTERSECTION ,
          N.value('LANGUAGES[1]', 'nvarchar(max)') AS LANGUAGES ,
          N.value('LOGO_ADDRESS[1]', 'nvarchar(200)') AS LOGO_ADDRESS ,
          N.value('LOGO_ADDRESS_LINK[1]', 'nvarchar(200)') AS LOGO_ADDRESS_LINK ,
          N.value('MAX_AGE[1]', 'nvarchar(10)') AS MAX_AGE ,
          N.value('MIN_AGE[1]', 'nvarchar(10)') AS MIN_AGE ,
          N.value('MEETINGS[1]', 'nvarchar(max)') AS MEETINGS ,
          N.value('MEMBERSHIP[1]', 'nvarchar(max)') AS MEMBERSHIP ,
          N.value('NAICS[1]', 'nvarchar(max)') AS NAICS ,
          N.value('OCG_NO[1]', 'nvarchar(100)') AS OCG_NO ,
          N.value('OTHER_ADDRESSES[1]', 'nvarchar(max)') AS OTHER_ADDRESSES ,
          N.value('PAYMENT_TERMS[1]', 'nvarchar(200)') AS PAYMENT_TERMS ,
          N.value('PREF_CURRENCY[1]', 'nvarchar(200)') AS PREF_CURRENCY ,
          N.value('PREF_PAYMENT_METHOD[1]', 'nvarchar(200)') AS PREF_PAYMENT_METHOD ,
          N.value('PRINT_MATERIAL[1]', 'nvarchar(max)') AS PRINT_MATERIAL ,
          N.value('PUBLIC_COMMENTS[1]', 'nvarchar(max)') AS PUBLIC_COMMENTS ,
          N.value('QUALITY[1]', 'nvarchar(10)') AS QUALITY ,
          N.value('RECORD_TYPE[1]', 'nvarchar(10)') AS RECORD_TYPE ,
          N.value('RESOURCES[1]', 'nvarchar(max)') AS RESOURCES ,
          N.value('SERVICE_LEVEL[1]', 'nvarchar(max)') AS SERVICE_LEVEL ,
          N.value('SITE_LOCATION[1]', 'nvarchar(255)') AS SITE_LOCATION ,
          N.value('SUBJECTS[1]', 'nvarchar(max)') AS SUBJECTS ,
          N.value('SUP_DESCRIPTION[1]', 'nvarchar(max)') AS SUP_DESCRIPTION ,
          N.value('TAX_REG_NO[1]', 'nvarchar(100)') AS TAX_REG_NO ,
          N.value('TAXONOMY[1]', 'nvarchar(max)') AS TAXONOMY ,
          N.value('TDD_PHONE[1]', 'nvarchar(255)') AS TDD_PHONE ,
          N.value('TRANSPORTATION[1]', 'nvarchar(max)') AS TRANSPORTATION ,
          N.value('VACANCY_INFO[1]', 'nvarchar(max)') AS VACANCY_INFO ,
          N.value('WARD[1]', 'nvarchar(10)') AS WARD ,
          N.value('WCB_NO[1]', 'nvarchar(100)') AS WCB_NO ,
          N.value('EXTRA_CHECKLIST_A[1]', 'nvarchar(max)') AS EXTRA_CHECKLIST_A ,
          N.value('EXTRA_CHECKLIST_B[1]', 'nvarchar(max)') AS EXTRA_CHECKLIST_B ,
          N.value('EXTRA_CHECKLIST_C[1]', 'nvarchar(max)') AS EXTRA_CHECKLIST_C ,
          N.value('EXTRA_CHECKLIST_D[1]', 'nvarchar(max)') AS EXTRA_CHECKLIST_D ,
          N.value('EXTRA_CHECKLIST_E[1]', 'nvarchar(max)') AS EXTRA_CHECKLIST_E ,
          N.value('EXTRA_CHECKLIST_F[1]', 'nvarchar(max)') AS EXTRA_CHECKLIST_F ,
          N.value('EXTRA_CONTACT_A_NAME[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_NAME ,
          N.value('EXTRA_CONTACT_A_TITLE[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_TITLE ,
          N.value('EXTRA_CONTACT_A_ORG[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_ORG ,
          N.value('EXTRA_CONTACT_A_PHONE1[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_PHONE1 ,
          N.value('EXTRA_CONTACT_A_PHONE2[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_PHONE2 ,
          N.value('EXTRA_CONTACT_A_PHONE3[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_PHONE3 ,
          N.value('EXTRA_CONTACT_A_FAX[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_FAX ,
          N.value('EXTRA_CONTACT_A_EMAIL[1]', 'nvarchar(60)') AS EXTRA_CONTACT_A_EMAIL ,
          N.value('EXTRA_DROPDOWN_A[1]', 'nvarchar(100)') AS EXTRA_DROPDOWN_A ,
          N.value('EXTRA_DROPDOWN_B[1]', 'nvarchar(100)') AS EXTRA_DROPDOWN_B ,
          N.value('EXTRA_DROPDOWN_C[1]', 'nvarchar(100)') AS EXTRA_DROPDOWN_C ,
          N.value('EXTRA_DROPDOWN_D[1]', 'nvarchar(100)') AS EXTRA_DROPDOWN_D ,
          N.value('EXTRA_DROPDOWN_E[1]', 'nvarchar(100)') AS EXTRA_DROPDOWN_E ,
          N.value('EXTRA_DROPDOWN_F[1]', 'nvarchar(100)') AS EXTRA_DROPDOWN_F ,
          N.value('EXTRA_DROPDOWN_G[1]', 'nvarchar(100)') AS EXTRA_DROPDOWN_G ,
          N.value('EXTRA_DROPDOWN_H[1]', 'nvarchar(100)') AS EXTRA_DROPDOWN_H
FROM @xmlData.nodes('/FeedbackEntry/CICs/CICFeedback') AS T(N)

) src
INNER JOIN @OLDGBLFB_ID ids
	ON ids.Old=src.FB_ID
	
	
INSERT INTO CCR_Feedback
        ( FB_ID ,
          TYPE_OF_PROGRAM ,
          BEST_TIME_TO_CALL ,
          TYPE_OF_CARE ,
          ESCORT ,
          SUBSIDY ,
          SPACE_AVAILABLE ,
          SPACE_AVAILABLE_NOTES ,
          SPACE_AVAILABLE_DATE ,
          LICENSE_NUMBER ,
          LICENSE_RENEWAL ,
          LC_TOTAL ,
          LC_INFANT ,
          LC_TODDLER ,
          LC_PRESCHOOL ,
          LC_KINDERGARTEN ,
          LC_SCHOOLAGE ,
          LC_NOTES ,
          SCHOOLS_IN_AREA ,
          SCHOOL_ESCORT
        )
SELECT New, 
          TYPE_OF_PROGRAM ,
          BEST_TIME_TO_CALL ,
          TYPE_OF_CARE ,
          ESCORT ,
          SUBSIDY ,
          SPACE_AVAILABLE ,
          SPACE_AVAILABLE_NOTES ,
          SPACE_AVAILABLE_DATE ,
          LICENSE_NUMBER ,
          LICENSE_RENEWAL ,
          LC_TOTAL ,
          LC_INFANT ,
          LC_TODDLER ,
          LC_PRESCHOOL ,
          LC_KINDERGARTEN ,
          LC_SCHOOLAGE ,
          LC_NOTES ,
          SCHOOLS_IN_AREA ,
          SCHOOL_ESCORT
FROM (
SELECT 
          N.value('FB_ID[1]', 'int') AS FB_ID ,
          N.value('TYPE_OF_PROGRAM[1]', 'int') AS TYPE_OF_PROGRAM ,
          N.value('BEST_TIME_TO_CALL[1]', 'nvarchar(255)') AS BEST_TIME_TO_CALL ,
          N.value('TYPE_OF_CARE[1]', 'nvarchar(max)') AS TYPE_OF_CARE ,
          N.value('ESCORT[1]', 'nvarchar(max)') AS ESCORT ,
          N.value('SUBSIDY[1]', 'nvarchar(20)') AS SUBSIDY ,
          N.value('SPACE_AVAILABLE[1]', 'nvarchar(20)') AS SPACE_AVAILABLE ,
          N.value('SPACE_AVAILABLE_NOTES[1]', 'nvarchar(max)') AS SPACE_AVAILABLE_NOTES ,
          N.value('SPACE_AVAILABLE_DATE[1]', 'nvarchar(25)') AS SPACE_AVAILABLE_DATE ,
          N.value('LICENSE_NUMBER[1]', 'nvarchar(50)') AS LICENSE_NUMBER ,
          N.value('LICENSE_RENEWAL[1]', 'nvarchar(25)') AS LICENSE_RENEWAL ,
          N.value('LC_TOTAL[1]', 'nvarchar(20)') AS LC_TOTAL ,
          N.value('LC_INFANT[1]', 'nvarchar(20)') AS LC_INFANT ,
          N.value('LC_TODDLER[1]', 'nvarchar(20)') AS LC_TODDLER ,
          N.value('LC_PRESCHOOL[1]', 'nvarchar(20)') AS LC_PRESCHOOL ,
          N.value('LC_KINDERGARTEN[1]', 'nvarchar(20)') AS LC_KINDERGARTEN ,
          N.value('LC_SCHOOLAGE[1]', 'nvarchar(20)') AS LC_SCHOOLAGE ,
          N.value('LC_NOTES[1]', 'nvarchar(max)') AS LC_NOTES ,
          N.value('SCHOOLS_IN_AREA[1]', 'nvarchar(max)') AS SCHOOLS_IN_AREA ,
          N.value('SCHOOL_ESCORT[1]', 'nvarchar(max)') AS SCHOOL_ESCORT
FROM @xmlData.nodes('/FeedbackEntry/CCRs/CCRFeedback') AS T(N)

) src
INNER JOIN @OLDGBLFB_ID ids
	ON ids.Old=src.FB_ID
	
END
-- GBL Feedback


-- Field Help (What is the status of this??)

SET @ObjectType='Field Help'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

SELECT fo.FieldID,
		N.value('LangID[1]', 'smallint'),
		N.value('HelpText[1]', 'varchar(max)')
FROM @xmlData.nodes('//FieldHelp') AS T(N)
	INNER JOIN dbo.GBL_FieldOption fo ON N.value('FieldName[1]', 'varchar(100)')=fo.FieldName