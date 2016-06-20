DECLARE @MemberID int, @xmlData xml

DECLARE @LoadCode varchar(10), @ObjectType varchar(50)
SET @LoadCode='ce032015'
SET @MemberID=400

/*
-- Member 1
-- VERIFIED JAN 17, 2015
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
           ,[DefaultProvince]
		   ,[UseLowestVNUM])
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
	N.value('DefaultProvince[1]', 'varchar(2)'),
	N.value('UseLowestVNUM[1]', 'bit')
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
-- Member
*/

/*
-- Layout
-- VERIFIED JAN 17, 2015
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
	          AlmostStandardsMode,
			  FullSSLCompatible
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
		N.value('AlmostStandardsMode[1]', 'bit'),
		N.value('FullSSLCompatible[1]', 'bit')
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
-- Layout
*/

/*
-- Template
-- VERIFIED JAN 17, 2015
BEGIN TRY
	BEGIN TRANSACTION

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
          AlmostStandardsMode ,
		  FullSSLCompatible ,
		  FullSSLCompatible_Cache
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
		N.value('AlmostStandardsMode[1]', 'bit'),
		N.value('FullSSLCompatible[1]', 'bit'),
		N.value('FullSSLCompatible_Cache[1]', 'bit')
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

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH

-- Template
*/

/*
-- Publications
-- VERIFIED JAN 17, 2015
BEGIN TRY
	BEGIN TRANSACTION
SET @ObjectType='Publication'

PRINT @ObjectType

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

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
-- Publications
*/

/*
-- Inclusion Policy
-- VERIFIED JAN 17, 2015
BEGIN TRY
	BEGIN TRANSACTION

SET @ObjectType='Inclusion Policy'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

INSERT INTO dbo.GBL_InclusionPolicy
        ( CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          MemberID ,
          PolicyTitle ,
          PolicyText ,
          LangID
        )
SELECT
	N.value('CREATED_DATE[1]', 'smalldatetime'),
    N.value('CREATED_BY[1]', 'varchar(50)'),
	N.value('MODIFIED_DATE[1]', 'smalldatetime'),
	N.value('MODIFIED_BY[1]', 'varchar(50)'),
	@MemberID,
	N.value('PolicyTitle[1]', 'nvarchar(50)'),
	N.value('PolicyText[1]', 'nvarchar(max)'),
	N.value('LangID[1]', 'smallint')
FROM @xmlData.nodes('//Policy') AS T(N)
WHERE NOT EXISTS(SELECT * FROM dbo.GBL_InclusionPolicy WHERE MemberID=@MemberID AND PolicyTitle=N.value('PolicyTitle[1]', 'nvarchar(50)'))

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
-- Inclusion Policy
*/

/*
-- CIC View 1
-- VERIFIED MAR 07, 2015
BEGIN TRY
	BEGIN TRANSACTION
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
		  BSrchDefaultTab,
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
          AlsoNotify ,
          NoProcessNotify ,
          UseSubmitChangesTo ,
          DataUseAuth ,
          MapSearchResults ,
          Owner ,
          MyList ,
          ViewOtherLangs ,
          AllowFeedbackNotInView ,
          AssignSuggestionsTo ,
		  CSrchLanguages
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
		N.value('BSrchDefaultTab[1]', 'tinyint'),
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
		N.value('AlsoNotify[1]', 'varchar(60)'),
		N.value('NoProcessNotify[1]', 'bit'),
		N.value('UseSubmitChangesTo[1]', 'bit'),
		N.value('DataUseAuth[1]', 'bit'),
		N.value('MapSearchResults[1]', 'bit'),
		N.value('Owner[1]', 'char(3)'),
		N.value('MyList[1]', 'bit'),
		N.value('ViewOtherLangs[1]', 'bit'),
		N.value('AllowFeedbackNotInView[1]', 'bit'),
        N.value('AssignSuggestionsTo[1]', 'char(3)'),
		N.value('CSrchLanguages[1]', 'bit')
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
			  SearchAlertMessage ,
			  SearchTitleOverride ,
			  OrganizationNames ,
			  OrganizationsWithWWW ,
			  OrganizationsWithVolOps ,
			  BrowseByOrg ,
			  FindAnOrgBy ,
			  ViewProgramsAndServices ,
			  ClickToViewDetails ,
			  OrgProgramNames ,
			  Organization ,
			  MultipleOrgWithSimilarMap ,
			  OrgLevel1Name ,
			  OrgLevel2Name ,
			  OrgLevel3Name
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
			(SELECT InclusionPolicyID FROM dbo.GBL_InclusionPolicy WHERE MemberID=@MemberID AND PolicyTitle=N.value('InclusionPolicyName[1]', 'nvarchar(255)')),
			(SELECT SearchTipsID FROM dbo.GBL_SearchTips WHERE MemberID=@MemberID AND PageTitle=N.value('SearchTipsName[1]', 'nvarchar(255)')),
			N.value('SearchLeftMessage[1]', 'nvarchar(max)'),
			N.value('SearchRightMessage[1]', 'nvarchar(max)'),
			N.value('SearchAlertMessage[1]', 'nvarchar(max)'),
			N.value('SearchTitleOverride[1]', 'nvarchar(255)'),
			N.value('OrganizationNames[1]', 'nvarchar(100)'),
			N.value('OrganizationsWithWWW[1]', 'nvarchar(100)'),
			N.value('OrganizationsWithVolOps[1]', 'nvarchar(100)'),
			N.value('BrowseByOrg[1]', 'nvarchar(100)'),
			N.value('FindAnOrgBy[1]', 'nvarchar(100)'),
			N.value('ViewProgramsAndServices[1]', 'nvarchar(100)'),
			N.value('ClickToViewDetails[1]', 'nvarchar(100)'),
			N.value('OrgProgramNames[1]', 'nvarchar(100)'),
			N.value('Organization[1]', 'nvarchar(100)'),
			N.value('MultipleOrgWithSimilarMap[1]', 'nvarchar(100)'),
			N.value('OrgLevel1Name[1]', 'nvarchar(100)'),
			N.value('OrgLevel2Name[1]', 'nvarchar(100)'),
			N.value('OrgLevel3Name[1]', 'nvarchar(100)')
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

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
-- CIC View 1
*/

-- NEED TO CHECK VOL Ball IDS

/*
--Community Set
-- !!!!!DON'T RUN TWICE!!!!!
BEGIN TRY
	BEGIN TRANSACTION

SET @ObjectType='VOL Community Set'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @CSidmap table (Old int, New int)

MERGE INTO VOL_CommunitySet dst
USING (
SELECT  
		N.value('CommunitySetID[1]', 'int') AS CommunitySetID,
		N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
		 N.value('CREATED_BY[1]', 'nvarchar(100)') AS CREATED_BY,
		 N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
		 N.value('MODIFIED_BY[1]', 'nvarchar(100)') AS MODIFIED_BY,
		 @MemberID AS MemberID
FROM @xmlData.nodes('/CommunitySets/CommunitySet') AS T(N)
) src
	ON 0=1
WHEN NOT MATCHED BY TARGET THEN
	INSERT (CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY, MemberID)
		VALUES (src.CREATED_DATE, src.CREATED_BY, src.MODIFIED_DATE, src.MODIFIED_BY, src.MemberID)

	OUTPUT src.CommunitySetID, Inserted.CommunitySetID INTO @CSidmap
	;

SELECT * FROM @CSidmap

INSERT INTO VOL_CommunitySet_Name
		(CommunitySetID,
		 LangID,
		 SetName,
		 AreaServed
		)
SELECT ids.New, src.LangID, src.SetName, src.AreaServed 
FROM (SELECT 
		 N.value('CommunitySetID[1]', 'int') AS CommunitySetID,
		 N.value('LangID[1]', 'smallint') AS LangID,
		 N.value('SetName[1]', 'nvarchar(100)') AS SetName,
		 N.value('AreaServed[1]', 'nvarchar(100)') AS AreaServed
FROM @xmlData.nodes('/CommunitySets/CommunitySet/Names/Name') AS T(N)) src
INNER JOIN @CSidmap ids
	ON ids.Old=src.CommunitySetID

DECLARE @CSGidmap table (Old int, New int)

MERGE INTO VOL_CommunityGroup dst
USING (
SELECT 
		N.value('CommunityGroupID[1]', 'int') AS CommunityGroupID,
	   N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
	   N.value('CREATED_BY[1]', 'nvarchar(100)') AS CREATED_BY,
	   N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
	   N.value('MODIFIED_BY[1]', 'nvarchar(100)') AS MODIFIED_BY,
	   csids.New AS CommunitySetID,
	   N.value('BallID[1]', 'int') AS BallID,
	   N.value('ImageURL[1]', 'nvarchar(150)') AS ImageURL
FROM @xmlData.nodes('/CommunitySets/CommunitySet/Groups/Group') AS T(N)
INNER JOIN @CSidmap csids
	ON csids.Old=N.value('CommunitySetID[1]', 'int')
) src
	ON 0=1
WHEN NOT MATCHED BY TARGET THEN
	INSERT 
		(
		 CREATED_DATE,
		 CREATED_BY,
		 MODIFIED_DATE,
		 MODIFIED_BY,
		 CommunitySetID,
		 BallID,
		 ImageURL
		)
		VALUES
		(
		 src.CREATED_DATE,
		 src.CREATED_BY,
		 src.MODIFIED_DATE,
		 src.MODIFIED_BY,
		 src.CommunitySetID,
		 src.BallID,
		 src.ImageURL
		)
	OUTPUT src.CommunityGroupID, Inserted.CommunityGroupID INTO @CSGidmap
	;

SELECT * FROM @CSGidmap

INSERT INTO VOL_CommunityGroup_Name
		(
		 CommunityGroupID,
		 LangID,
		 CommunityGroupName
		)
SELECT	
		idmap.New AS CommunityGroupID,
		 N.value('LangID[1]', 'smallint') AS LangID,
		 N.value('CommunityGroupName[1]', 'nvarchar(100)') AS CommunityGroupName
FROM @xmlData.nodes('/CommunitySets/CommunitySet/Groups/Group/Names/Name') AS T(N)
INNER JOIN @CSGidmap idmap
	ON idmap.Old= N.value('CommunityGroupID[1]', 'int')

INSERT INTO VOL_CommunityGroup_CM
		(
		 CREATED_DATE,
		 CREATED_BY,
		 MODIFIED_DATE,
		 MODIFIED_BY,
		 CommunityGroupID,
		 CM_ID,
		 DisplayOrder
		)
SELECT	
		 N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
		 N.value('CREATED_BY[1]', 'nvarchar(100)') AS CREATED_BY,
		 N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
		 N.value('MODIFIED_BY[1]', 'nvarchar(100)') AS MODIFIED_BY,
		idmap.New AS CommunityGroupID,
		(SELECT CM_ID FROM GBL_Community WHERE CM_GUID=N.value('CM_GUID[1]', 'uniqueidentifier')) AS CM_ID,
		 N.value('DisplayOrder[1]', 'tinyint') AS DisplayOrder
FROM @xmlData.nodes('/CommunitySets/CommunitySet/Groups/Group/Communities/Community') AS T(N)
INNER JOIN @CSGidmap idmap
	ON idmap.Old= N.value('CommunityGroupID[1]', 'int')


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
--Community Set
*/

/*
-- VOL View 1
-- VERIFIED MAR 07, 2015
BEGIN TRY
	BEGIN TRANSACTION

SET @ObjectType='VOL View'

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

INSERT INTO dbo.VOL_View
        ( CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          MemberID ,
          CommunitySetID ,
          CanSeeNonPublic ,
          CanSeeDeleted ,
          CanSeeExpired ,
          HidePastDueBy ,
          AlertColumn ,
          Template ,
          PrintTemplate ,
          PrintVersionResults ,
          DataMgmtFields ,
          LastModifiedDate ,
          SocialMediaShare ,
          CommSrchWrapAt ,
          SuggestOpLink ,
          BSrchAutoComplete ,
		  BSrchBrowseAll,
		  BSrchBrowseByInterest,
          BSrchBrowseByOrg ,
          BSrchKeywords ,
		  BSrchStepByStep,
		  BSrchStudent,
		  BSrchWhatsNew,
		  BSrchDefaultTab,
          ASrchAges ,
          ASrchBool ,
          ASrchDatesTimes ,
          ASrchEmail ,
          ASrchLastRequest ,
          ASrchOwner ,
          ASrchOSSD ,
          SSrchIndividualCount ,
          UseProfilesView ,
          DataUseAuth ,
          Owner ,
          MyList ,
          ViewOtherLangs ,
          AllowFeedbackNotInView ,
          AssignSuggestionsTo,
		  SSrchDatesTimes
        )
SELECT 
		N.value('CREATED_DATE[1]', 'smalldatetime'),
		N.value('CREATED_BY[1]', 'varchar(50)'),
		N.value('MODIFIED_DATE[1]', 'smalldatetime'),
		N.value('MODIFIED_BY[1]', 'varchar(50)'),
		N.value('MemberID[1]', 'int'),
		(SELECT TOP 1 vcs.CommunitySetID FROM dbo.VOL_CommunitySet vcs INNER JOIN dbo.VOL_CommunitySet_Name vcsn ON vcsn.CommunitySetID = vcs.CommunitySetID AND (vcs.MemberID=@MemberID OR vcs.MemberID IS NULL) WHERE vcsn.SetName=N.value('SetName[1]', 'nvarchar(255)')),
		N.value('CanSeeNonPublic[1]', 'bit'),
		N.value('CanSeeDeleted[1]', 'bit'),
		N.value('CanSeeExpired[1]', 'bit'),
		N.value('HidePastDueBy[1]', 'int'),
		N.value('AlertColumn[1]', 'bit'),
		(SELECT TOP 1 t.Template_ID FROM dbo.GBL_Template t INNER JOIN dbo.GBL_Template_Description td ON td.Template_ID = t.Template_ID AND (t.MemberID=@MemberID OR t.MemberID IS NULL) WHERE td.Name=N.value('TemplateName[1]', 'nvarchar(255)')),
		(SELECT TOP 1 t.Template_ID FROM dbo.GBL_Template t INNER JOIN dbo.GBL_Template_Description td ON td.Template_ID = t.Template_ID AND (t.MemberID=@MemberID OR t.MemberID IS NULL) WHERE td.Name=N.value('PrintTemplateName[1]', 'nvarchar(255)')),
		N.value('PrintVersionResults[1]', 'bit'),
		N.value('DataMgmtFields[1]', 'bit'),
		N.value('LastModifiedDate[1]', 'bit'),
		N.value('SocialMediaShare[1]', 'bit'),
		N.value('CommSrchWrapAt[1]', 'tinyint'),
		N.value('SuggestOpLink[1]', 'bit'),
		N.value('BSrchAutoComplete[1]', 'bit'),
		N.value('BSrchBrowseAll[1]', 'bit'),
		N.value('BSrchBrowseByInterest[1]', 'bit'),
		N.value('BSrchBrowseByOrg[1]', 'bit'),
		N.value('BSrchKeywords[1]', 'bit'),
		N.value('BSrchStepByStep[1]', 'bit'),
		N.value('BSrchStudent[1]', 'bit'),
		N.value('BSrchWhatsNew[1]', 'bit'),
		N.value('BSrchDefaultTab[1]', 'tinyint'),
		N.value('ASrchAges[1]', 'bit'),
		N.value('ASrchBool[1]', 'bit'),
		N.value('ASrchDatesTimes[1]', 'bit'),
		N.value('ASrchEmail[1]', 'bit'),
		N.value('ASrchLastRequest[1]', 'bit'),
		N.value('ASrchOwner[1]', 'bit'),
		N.value('ASrchOSSD[1]', 'bit'),
		N.value('SSrchIndividualCount[1]', 'bit'),
		N.value('UseProfilesView[1]', 'bit'),
		N.value('DataUseAuth[1]', 'bit'),
		N.value('Owner[1]', 'char(3)'),
		N.value('MyList[1]', 'bit'),
		N.value('ViewOtherLangs[1]', 'bit'),
		N.value('AllowFeedbackNotInView[1]', 'bit'),
        N.value('AssignSuggestionsTo[1]', 'char(3)'),
        N.value('SSrchDatesTimes[1]', 'bit')
		FROM @xmlData.nodes('//View') AS T(N)
			WHERE N.value('ViewType[1]', 'int')=@ViewType
				AND NOT EXISTS(SELECT * FROM dbo.VOL_View vw INNER JOIN dbo.VOL_View_Description vwd ON vwd.ViewType = vw.ViewType AND vw.MemberID=@MemberID AND vwd.ViewName=@ViewName)

	IF @@ROWCOUNT > 0 BEGIN
		SET @NewViewType=SCOPE_IDENTITY()
	END ELSE BEGIN 
		SELECT @NewViewType=NULL
	END
	
	IF @NewViewType IS NOT NULL BEGIN
		INSERT INTO dbo.VOL_View_Description
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
		          FeedbackBlurb ,
		          TermsOfUseURL ,
		          InclusionPolicy ,
		          SearchTips ,
		          SearchLeftMessage ,
		          SearchRightMessage ,
		          SearchAlertMessage,
				  SearchPromptOverride
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
			N.value('FeedbackBlurb[1]', 'nvarchar(max)'),
			N.value('TermsOfUseURL[1]', 'varchar(200)'),
			(SELECT InclusionPolicyID FROM dbo.GBL_InclusionPolicy ip WHERE MemberID=@MemberID AND PolicyTitle=N.value('InclusionPolicyName[1]', 'nvarchar(255)') AND ip.MemberID=@MemberID),
			(SELECT SearchTipsID FROM dbo.GBL_SearchTips st WHERE MemberID=@MemberID AND PageTitle=N.value('SearchTipsName[1]', 'nvarchar(255)') AND st.MemberID=@MemberID),
			N.value('SearchLeftMessage[1]', 'nvarchar(max)'),
			N.value('SearchRightMessage[1]', 'nvarchar(max)'),
			N.value('SearchAlertMessage[1]', 'nvarchar(max)'),
			N.value('SearchPromptOverride[1]', 'nvarchar(255)')
		FROM @xmlData.nodes('//View/Descriptions/Lang') AS T(N)
			WHERE N.value('../../ViewType[1]', 'int')=@ViewType
				AND NOT EXISTS(SELECT * FROM dbo.VOL_View_Description WHERE ViewType=@NewViewType AND LangID=N.value('LangID[1]', 'smallint'))
	END

	FETCH NEXT FROM ViewCursor INTO @ViewType, @ViewName
END

DEALLOCATE ViewCursor

INSERT INTO dbo.VOL_View_ChkField
        ( ViewType, FieldID )
SELECT vwd.ViewType,
      (SELECT FieldID FROM dbo.VOL_FieldOption WHERE FieldName=N.value('.[1]', 'varchar(100)'))
FROM @xmlData.nodes('//View/ChkField/FieldName') AS T(N)
	INNER JOIN dbo.VOL_View_Description vwd
		ON vwd.LangID=(SELECT TOP 1 LangID FROM	dbo.VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd.ViewName=N.value('../../Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.VOL_View vw WHERE vw.MemberID=@MemberID AND vw.ViewType=vwd.ViewType)
	WHERE NOT EXISTS(SELECT * FROM dbo.VOL_View_ChkField WHERE ViewType=vwd.ViewType AND FieldID=(SELECT FieldID FROM dbo.VOL_FieldOption WHERE FieldName=N.value('.[1]', 'varchar(100)')))
	
INSERT INTO dbo.VOL_View_DisplayField
        ( ViewType, FieldID )
SELECT vwd.ViewType,
      (SELECT FieldID FROM dbo.VOL_FieldOption WHERE FieldName=N.value('.[1]', 'varchar(100)'))
FROM @xmlData.nodes('//View/DisplayField/FieldName') AS T(N)
	INNER JOIN dbo.VOL_View_Description vwd
		ON vwd.LangID=(SELECT TOP 1 LangID FROM	dbo.VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd.ViewName=N.value('../../Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.VOL_View vw WHERE vw.MemberID=@MemberID AND vw.ViewType=vwd.ViewType)
	WHERE NOT EXISTS(SELECT * FROM dbo.VOL_View_DisplayField WHERE ViewType=vwd.ViewType AND FieldID=(SELECT FieldID FROM dbo.VOL_FieldOption WHERE FieldName=N.value('.[1]', 'varchar(100)')))

INSERT INTO dbo.VOL_View_FeedbackField
        ( ViewType, FieldID )
SELECT vwd.ViewType,
      (SELECT FieldID FROM dbo.VOL_FieldOption WHERE FieldName=N.value('.[1]', 'varchar(100)'))
FROM @xmlData.nodes('//View/FeedbackField/FieldName') AS T(N)
	INNER JOIN dbo.VOL_View_Description vwd
		ON vwd.LangID=(SELECT TOP 1 LangID FROM	dbo.VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd.ViewName=N.value('../../Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.VOL_View vw WHERE vw.MemberID=@MemberID AND vw.ViewType=vwd.ViewType)
	WHERE NOT EXISTS(SELECT * FROM dbo.VOL_View_FeedbackField WHERE ViewType=vwd.ViewType AND FieldID=(SELECT FieldID FROM dbo.VOL_FieldOption WHERE FieldName=N.value('.[1]', 'varchar(100)')))

INSERT INTO dbo.VOL_View_UpdateField
        ( ViewType, FieldID )
SELECT vwd.ViewType,
      (SELECT FieldID FROM dbo.VOL_FieldOption WHERE FieldName=N.value('.[1]', 'varchar(100)'))
FROM @xmlData.nodes('//View/UpdateField/FieldName') AS T(N)
	INNER JOIN dbo.VOL_View_Description vwd
		ON vwd.LangID=(SELECT TOP 1 LangID FROM	dbo.VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd.ViewName=N.value('../../Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.VOL_View vw WHERE vw.MemberID=@MemberID AND vw.ViewType=vwd.ViewType)
	WHERE NOT EXISTS(SELECT * FROM dbo.VOL_View_UpdateField WHERE ViewType=vwd.ViewType AND FieldID=(SELECT FieldID FROM dbo.VOL_FieldOption WHERE FieldName=N.value('.[1]', 'varchar(100)')))

INSERT INTO dbo.VOL_View_Recurse
        ( ViewType, CanSee )
SELECT vwd.ViewType,
	vwd2.Viewtype
FROM @xmlData.nodes('//View/Recurse/CanSeeView') AS T(N)
	INNER JOIN dbo.VOL_View_Description vwd
		ON vwd.LangID=(SELECT TOP 1 LangID FROM	dbo.VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd.ViewName=N.value('../../Descriptions[1]/Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.VOL_View vw WHERE vw.MemberID=@MemberID AND vw.ViewType=vwd.ViewType)
	INNER JOIN dbo.VOL_View_Description vwd2
		ON vwd2.LangID=(SELECT TOP 1 LangID FROM dbo.VOL_View_Description WHERE ViewType=vwd2.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			AND vwd2.ViewName=N.value('.[1]', 'nvarchar(255)')
			AND EXISTS(SELECT * FROM dbo.VOL_View vw2 WHERE vw2.MemberID=@MemberID AND vw2.ViewType=vwd2.ViewType)
	WHERE NOT EXISTS(SELECT * FROM dbo.VOL_View_Recurse WHERE ViewType=vwd.ViewType AND CanSee=vwd2.ViewType)

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
-- VOL View 1
*/

/*
-- Member 2

SET @ObjectType='Member'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

UPDATE mem SET
	mem.DefaultTemplate = (SELECT TOP 1 t.Template_ID FROM dbo.GBL_Template t INNER JOIN dbo.GBL_Template_Description td ON td.Template_ID = t.Template_ID AND (t.MemberID=@MemberID OR t.MemberID IS NULL) WHERE td.Name=N.value('DefaultTemplateName[1]', 'nvarchar(255)')),
	mem.DefaultPrintTemplate = (SELECT TOP 1 t.Template_ID FROM dbo.GBL_Template t INNER JOIN dbo.GBL_Template_Description td ON td.Template_ID = t.Template_ID AND (t.MemberID=@MemberID OR t.MemberID IS NULL) WHERE td.Name=N.value('DefaultPrintTemplateName[1]', 'nvarchar(255)')),
	mem.DefaultViewCIC = (SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('DefaultViewCICName[1]', 'nvarchar(255)')),
	mem.DefaultViewVOL = (SELECT TOP 1 vw.ViewType FROM dbo.VOL_View vw INNER JOIN dbo.VOL_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('DefaultViewVOLName[1]', 'nvarchar(255)'))
FROM dbo.STP_Member mem
	INNER JOIN @xmlData.nodes('//Member') AS T(N)
		ON mem.MemberID=N.value('MemberID[1]', 'int')

-- Member 2
*/


/*
-- CIC View 2
-- !!!!!DON'T RUN TWICE!!!!!
BEGIN TRY
	BEGIN TRANSACTION

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

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
-- CIC View 2
*/

/*
-- CIC User Type
-- MISSING RECORD TYPE
BEGIN TRY
	BEGIN TRANSACTION

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


INSERT INTO CIC_SecurityLevel_EditAgency
		(SL_ID, AgencyCode)
SELECT sl.SL_ID, q.AgencyCode
FROM (SELECT
	N.value('.[1]', 'char(3)') AS AgencyCode,
	N.value('../../Descriptions[1]/Lang[LangID=0][1]/SecurityLevel[1]', 'nvarchar(255)') AS SecurityLevelName
FROM @xmlData.nodes('//UserType/EditAgencies/AgencyCode') AS T(N)) q
INNER JOIN CIC_SecurityLevel_Name sln
	ON sln.SecurityLevel=q.SecurityLevelName AND sln.LangID=0
INNER JOIN CIC_SecurityLevel sl
	ON sl.SL_ID=sln.SL_ID AND sl.MemberID=@MemberID
WHERE NOT EXISTS(SELECT * FROM CIC_SecurityLevel_EditAgency WHERE SL_ID=sl.SL_ID AND AgencyCode=q.AgencyCode)

INSERT INTO CIC_SecurityLevel_EditView
		(SL_ID, ViewType)
SELECT sl.SL_ID, vw.ViewType FROM 
(SELECT
	N.value('.[1]', 'nvarchar(255)') AS ViewName,
	N.value('../../Descriptions[1]/Lang[LangID=0][1]/SecurityLevel[1]', 'nvarchar(255)') AS SecurityLevelName
FROM @xmlData.nodes('//UserType/EditViews/View') AS T(N) ) q
INNER JOIN CIC_View_Description vd
	ON q.ViewName=vd.ViewName AND vd.LangID=0
INNER JOIN CIC_View vw
	ON vw.ViewType = vd.ViewType AND vw.MemberID=@MemberID
INNER JOIN CIC_SecurityLevel_Name sln
	ON sln.SecurityLevel=q.SecurityLevelName AND sln.LangID=0
INNER JOIN CIC_SecurityLevel sl
	ON sl.SL_ID=sln.SL_ID AND sl.MemberID=@MemberID
WHERE NOT EXISTS(SELECT * FROM CIC_SecurityLevel_EditView WHERE SL_ID=sl.SL_ID AND vw.ViewType=ViewType)

INSERT INTO CIC_SecurityLevel_ExternalAPI
		(SL_ID, API_ID)
SELECT sl.SL_ID, eapi.API_ID
FROM (SELECT
	N.value('.[1]', 'nvarchar(255)') AS ExternalAPIName,
	N.value('../../Descriptions[1]/Lang[LangID=0][1]/SecurityLevel[1]', 'nvarchar(255)') AS SecurityLevelName
FROM @xmlData.nodes('//UserType/ExternalAPIs/API') AS T(N)) q
INNER JOIN CIC_SecurityLevel_Name sln
	ON sln.SecurityLevel=q.SecurityLevelName AND sln.LangID=0
INNER JOIN CIC_SecurityLevel sl
	ON sl.SL_ID=sln.SL_ID AND sl.MemberID=@MemberID
INNER JOIN GBL_ExternalAPI_Description eapi
	ON eapi.LangID=0 AND q.ExternalAPIName=eapi.Name
WHERE NOT EXISTS(SELECT * FROM CIC_SecurityLevel_ExternalAPI WHERE SL_ID=sl.SL_ID AND eapi.API_ID=API_ID)

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
-- CIC User Type
*/

-- VOL User Type
/*
BEGIN TRY
	BEGIN TRANSACTION

SET @ObjectType='VOL User Type'

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

INSERT INTO dbo.VOL_SecurityLevel
        ( CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          MemberID ,
          Owner ,
          ViewType ,
          CanAccessProfiles ,
          CanAddRecord ,
          CanAddSQL ,
          CanAssignFeedback ,
          CanCopyRecord ,
          CanDeleteRecord ,
          CanDoBulkOps ,
          CanDoFullUpdate ,
          CanEditRecord ,
          EditByViewList ,
          CanManageMembers ,
          CanManageReferrals ,
          CanManageUsers ,
          CanRequestUpdate ,
          CanViewStats ,
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
 		(SELECT TOP 1 vw.ViewType FROM dbo.VOL_View vw INNER JOIN dbo.VOL_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('ViewTypeName[1]', 'nvarchar(255)')),
		N.value('CanAccessProfiles[1]', 'bit'),
		N.value('CanAddRecord[1]', 'bit'),
		N.value('CanAddSQL[1]', 'bit'),
		N.value('CanAssignFeedback[1]', 'bit'),
		N.value('CanCopyRecord[1]', 'bit'),
		N.value('CanDeleteRecord[1]', 'bit'),
		N.value('CanDoBulkOps[1]', 'bit'),
		N.value('CanDoFullUpdate[1]', 'bit'),
 		N.value('CanEditRecord[1]', 'tinyint'),
		N.value('EditByViewList[1]', 'bit'),
		N.value('CanManageMembers[1]', 'bit'),
		N.value('CanManageReferrals[1]', 'bit'),
		N.value('CanManageUsers[1]', 'bit'),
		N.value('CanRequestUpdate[1]', 'bit'),
		N.value('CanViewStats[1]', 'bit'),
		N.value('SuppressNotifyEmail[1]', 'bit'),
		N.value('FeedbackAlert[1]', 'bit'),
		N.value('CommentAlert[1]', 'bit'),
		N.value('WebDeveloper[1]', 'bit'),
		N.value('SuperUser[1]', 'bit'),
        N.value('SuperUserGlobal[1]', 'bit')
FROM @xmlData.nodes('//UserType') as T(N)
	WHERE N.value('SL_ID[1]', 'int')=@SLID
		AND NOT EXISTS(SELECT * FROM dbo.VOL_SecurityLevel sl INNER JOIN dbo.VOL_SecurityLevel_Name sln ON sln.SL_ID = sl.SL_ID AND sl.MemberID=@MemberID AND sln.SecurityLevel=@SecurityLevel)

	IF @@ROWCOUNT > 0 BEGIN
		SET @NewSLID=SCOPE_IDENTITY()
	END ELSE BEGIN 
		SELECT @NewSLID=NULL
	END
	
	IF @NewSLID IS NOT NULL BEGIN
		INSERT INTO dbo.VOL_SecurityLevel_Name
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
				AND NOT EXISTS(SELECT * FROM dbo.VOL_SecurityLevel_Name WHERE SL_ID=@NewSLID AND LangID=N.value('LangID[1]', 'smallint'))
	END

	FETCH NEXT FROM UserTypeCursor INTO @SLID, @SecurityLevel
END

DEALLOCATE UserTypeCursor
INSERT INTO VOL_SecurityLevel_EditAgency
		(SL_ID, AgencyCode)
SELECT sl.SL_ID, q.AgencyCode
FROM (SELECT
	N.value('.[1]', 'char(3)') AS AgencyCode,
	N.value('../../Descriptions[1]/Lang[LangID=0][1]/SecurityLevel[1]', 'nvarchar(255)') AS SecurityLevelName
FROM @xmlData.nodes('//UserType/EditAgencies/AgencyCode') AS T(N)) q
INNER JOIN VOL_SecurityLevel_Name sln
	ON sln.SecurityLevel=q.SecurityLevelName AND sln.LangID=0
INNER JOIN VOL_SecurityLevel sl
	ON sl.SL_ID=sln.SL_ID AND sl.MemberID=@MemberID
WHERE NOT EXISTS(SELECT * FROM VOL_SecurityLevel_EditAgency WHERE SL_ID=sl.SL_ID AND AgencyCode=q.AgencyCode)

INSERT INTO VOL_SecurityLevel_EditView
		(SL_ID, ViewType)
SELECT sl.SL_ID, vw.ViewType FROM 
(SELECT
	N.value('.[1]', 'nvarchar(255)') AS ViewName,
	N.value('../../Descriptions[1]/Lang[LangID=0][1]/SecurityLevel[1]', 'nvarchar(255)') AS SecurityLevelName
FROM @xmlData.nodes('//UserType/EditViews/View') AS T(N) ) q
INNER JOIN VOL_View_Description vd
	ON q.ViewName=vd.ViewName AND vd.LangID=0
INNER JOIN VOL_View vw
	ON vw.ViewType = vd.ViewType AND vw.MemberID=@MemberID
INNER JOIN VOL_SecurityLevel_Name sln
	ON sln.SecurityLevel=q.SecurityLevelName AND sln.LangID=0
INNER JOIN VOL_SecurityLevel sl
	ON sl.SL_ID=sln.SL_ID AND sl.MemberID=@MemberID
WHERE NOT EXISTS(SELECT * FROM VOL_SecurityLevel_EditView WHERE SL_ID=sl.SL_ID AND vw.ViewType=ViewType)

INSERT INTO VOL_SecurityLevel_ExternalAPI
		(SL_ID, API_ID)
SELECT sl.SL_ID, eapi.API_ID
FROM (SELECT
	N.value('.[1]', 'nvarchar(255)') AS ExternalAPIName,
	N.value('../../Descriptions[1]/Lang[LangID=0][1]/SecurityLevel[1]', 'nvarchar(255)') AS SecurityLevelName
FROM @xmlData.nodes('//UserType/ExternalAPIs/API') AS T(N)) q
INNER JOIN VOL_SecurityLevel_Name sln
	ON sln.SecurityLevel=q.SecurityLevelName AND sln.LangID=0
INNER JOIN VOL_SecurityLevel sl
	ON sl.SL_ID=sln.SL_ID AND sl.MemberID=@MemberID
INNER JOIN GBL_ExternalAPI_Description eapi
	ON eapi.LangID=0 AND q.ExternalAPIName=eapi.Name
WHERE NOT EXISTS(SELECT * FROM VOL_SecurityLevel_ExternalAPI WHERE SL_ID=sl.SL_ID AND eapi.API_ID=API_ID)

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
-- VOL User Type
*/

-- Users
/*
BEGIN TRY
	BEGIN TRANSACTION
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
	WHERE NOT EXISTS(SELECT * FROM dbo.GBL_Users_History uh WHERE uh.User_ID=(SELECT User_ID FROM GBL_Users WHERE UserUID=N.value('../../UserUID[1]', 'uniqueidentifier'))
		AND uh.MODIFIED_DATE=N.value('MODIFIED_DATE[1]', 'datetime') AND uh.MODIFIED_BY=N.value('MODIFIED_BY[1]', 'varchar(50)'))

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
-- Users
*/

/*
-- Distributions

SET @ObjectType='Distribution'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

INSERT INTO dbo.CIC_Distribution
        ( MODIFIED_DATE ,
          MODIFIED_BY ,
          CREATED_DATE ,
          CREATED_BY ,
          MemberID ,
          DistCode
        )
SELECT
		N.value('MODIFIED_DATE[1]', 'smalldatetime'),
		N.value('MODIFIED_BY[1]', 'varchar(50)'),
		N.value('CREATED_DATE[1]', 'smalldatetime'),
		N.value('CREATED_BY[1]', 'varchar(50)'),
		@MemberID,
		N.value('DistCode[1]', 'varchar(20)')
FROM @xmlData.nodes('//Distribution') AS T(N)
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_Distribution WHERE DistCode=N.value('DistCode[1]', 'varchar(20)'))

INSERT INTO dbo.CIC_Distribution_Name
        ( DST_ID, LangID, Name )
SELECT
		DST_ID,
		N.value('LangID[1]', 'smallint'),
		N.value('Name[1]', 'nvarchar(200)')
FROM @xmlData.nodes('//Distribution/Names/Lang') AS T(N)
INNER JOIN dbo.CIC_Distribution dst ON dst.DistCode=N.value('../../DistCode[1]', 'varchar(20)')
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_Distribution_Name WHERE DST_ID=dst.DST_ID AND LangID=N.value('LangID[1]', 'smallint'))

-- Distributions
*/

/*
-- Display Options
BEGIN TRY
	BEGIN TRANSACTION
SET @ObjectType='Display'

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
SELECT * 
FROM (
SELECT
	(SELECT DD_ID FROM dbo.GBL_Display WHERE Domain=1 AND (ViewTypeCIC=(SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('../../ViewTypeCICName[1]', 'nvarchar(255)'))
			OR ViewTypeVOL=(SELECT TOP 1 vw.ViewType FROM dbo.VOL_View vw INNER JOIN dbo.VOL_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('../../ViewTypeVOLName[1]', 'nvarchar(255)'))
			OR User_ID=(SELECT User_ID FROM GBL_Users WHERE UserUID=N.value('../../UserUID[1]', 'uniqueidentifier') ))
	) AS DD_ID,
	(SELECT FieldID FROM dbo.GBL_FieldOption fo WHERE FieldName=N.value('.[1]','varchar(100)')) AS FieldID
FROM @xmlData.nodes('//Display/GBLFields/FieldName') AS T(N)
WHERE N.value('../../Domain[1]', 'tinyint')=1
 ) src
WHERE  NOT EXISTS(SELECT * FROM GBL_Display_Fld WHERE src.DD_ID=DD_ID AND FieldID=src.FieldID)
		
INSERT INTO dbo.VOL_Display_Fld
        ( DD_ID, FieldID )
SELECT * 
FROM (
SELECT
	(SELECT DD_ID FROM dbo.GBL_Display Domain WHERE Domain=2 AND (ViewTypeVOL=(SELECT TOP 1 vw.ViewType FROM dbo.VOL_View vw INNER JOIN dbo.VOL_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('../../ViewTypeVOLName[1]', 'nvarchar(255)'))
			OR ViewTypeVOL=(SELECT TOP 1 vw.ViewType FROM dbo.VOL_View vw INNER JOIN dbo.VOL_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('../../ViewTypeVOLName[1]', 'nvarchar(255)'))
			OR User_ID=(SELECT User_ID FROM GBL_Users WHERE UserUID=N.value('../../UserUID[1]', 'uniqueidentifier')))
	) AS DD_ID,
	(SELECT FieldID FROM dbo.VOL_FieldOption fo WHERE FieldName=N.value('.[1]','varchar(100)')) AS FieldID
FROM @xmlData.nodes('//Display/VOLFields/FieldName') AS T(N)
WHERE N.value('../../Domain[1]', 'tinyint')=2
) src
WHERE NOT EXISTS(SELECT * FROM VOL_Display_Fld WHERE src.DD_ID=DD_ID AND FieldID=src.FieldID)
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
-- Display Options
*/

/*
--Domain Map
SET @ObjectType='GBL View DomainMap'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

INSERT INTO GBL_View_DomainMap
		(
		CREATED_DATE,
		 CREATED_BY,
		 MODIFIED_DATE,
		 MODIFIED_BY,
		 MemberID,
		 DomainName,
		 PathToStart,
		 DefaultLangID,
		 CICViewType,
		 VOLViewType,
		 SecondaryName,
		 GoogleMapsAPIKeyCIC,
		 GoogleMapsClientIDCIC,
		 GoogleMapsChannelCIC,
		 GoogleMapsAPIKeyVOL,
		 GoogleMapsClientIDVOL,
		 GoogleMapsChannelVOL,
		 GoogleAnalyticsCode,
		 FullSSLCompatible
		)
SELECT *
FROM (
SELECT 
		N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
		 N.value('CREATED_BY[1]', 'nvarchar(100)') AS CREATED_BY,
		 N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
		 N.value('MODIFIED_BY[1]', 'nvarchar(100)') AS MODIFIED_BY,
		 N.value('MemberID[1]', 'int') AS MemberID,
		 N.value('DomainName[1]', 'varchar(100)') AS DomainName,
		 N.value('PathToStart[1]', 'varchar(50)') AS PathToStart,
		 N.value('DefaultLangID[1]', 'smallint') AS DefaultLangID,
		 (SELECT TOP 1 vw.ViewType FROM CIC_View_Description vwd INNER JOIN CIC_View vw ON vw.ViewType = vwd.ViewType WHERE ViewName=N.value('CICViewName[1]', 'nvarchar(255)') AND @MemberID=MemberID) AS CICViewType,
		 (SELECT TOP 1 vw.ViewType FROM VOL_View_Description vwd INNER JOIN VOL_View vw ON vw.ViewType = vwd.ViewType WHERE ViewName=N.value('VOLViewName[1]', 'nvarchar(255)') AND @MemberID=MemberID) AS VOLViewType,
		 N.value('SecondaryName[1]', 'bit') AS SecondaryName,
		 N.value('GoogleMapsAPIKeyCIC[1]', 'nvarchar(100)') AS GoogleMapsAPIKeyCIC,
		 N.value('GoogleMapsClientIDCIC[1]', 'nvarchar(100)') AS GoogleMapsClientIDCIC,
		 N.value('GoogleMapsChannelCIC[1]', 'nvarchar(100)') AS GoogleMapsChannelCIC,
		 N.value('GoogleMapsAPIKeyVOL[1]', 'nvarchar(100)') AS GoogleMapsAPIKeyVOL,
		 N.value('GoogleMapsClientIDVOL[1]', 'nvarchar(100)') AS GoogleMapsClientIDVOL,
		 N.value('GoogleMapsChannelVOL[1]', 'nvarchar(100)') AS GoogleMapsChannelVOL,
		 N.value('GoogleAnalyticsCode[1]', 'nvarchar(50)') AS GoogleAnalyticsCode,
		 N.value('FullSSLCompatible[1]', 'bit') AS FullSSLCompatible
FROM @xmlData.nodes('//Domain') AS T(N)) src
WHERE NOT EXISTS(SELECT * FROM GBL_View_DomainMap WHERE DomainName = src.DomainName)
--Domain Map
*/

/*
-- Saved Searches
-- VERIFIED JAN 17, 2015
BEGIN TRY
	BEGIN TRANSACTION


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
	ON dst.User_ID=src.User_ID AND dst.SearchName=src.SearchName
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
	

INSERT INTO VOL_SecurityLevel_SavedSearch
        ( SL_ID, SSRCH_ID )
SELECT SL_ID, New
FROM (
	SELECT
		N.value('../../SSRCH_ID[1]', 'int') AS SSRCH_ID ,
 		(SELECT TOP 1 sl.SL_ID FROM dbo.VOL_SecurityLevel sl INNER JOIN dbo.VOL_SecurityLevel_Name sld ON sld.SL_ID = sl.SL_ID AND sl.MemberID=@MemberID WHERE sld.SecurityLevel=N.value('.', 'nvarchar(255)')) SL_ID
	FROM @xmlData.nodes('//SavedSearch/VOLUserType/SecurityLevel') AS T(N)
) src
INNER JOIN @OLDSSIDS
	ON src.SSRCH_ID=Old



	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
*/
-- Saved Search

-- Print Profiles
-- !!!!! RUN ONCE !!!!!
-- VERIFIED JAN 17, 2015
/*
BEGIN TRY
	BEGIN TRANSACTION
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
WHERE gfo.FieldID IS NOT NULL OR vfo.FieldID IS NOT NULL
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

INSERT INTO GBL_PrintProfile_Fld_FindReplace_Lang
        ( PFLD_RP_ID, LangID )
SELECT New, LangID
FROM(SELECT
        N.value('../../PFLD_RP_ID[1]', 'int') AS PFLD_RP_ID,
        N.value('.', 'int') AS LangID 
FROM @xmlData.nodes('/PrintProfile/Fields/Field/Replacements/FindReplace/Languages/LangID') AS T(N) ) src
LEFT JOIN @OLDPFLD_RP_ID ids
	ON ids.Old=Src.PFLD_RP_ID

INSERT INTO CIC_View_PrintProfile
		(ViewType, ProfileID)
SELECT
		ViewType,
		New
FROM (
SELECT 
	N.value('../../ProfileID[1]', 'int') AS ProfileID,
	(SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('.', 'nvarchar(255)')) AS ViewType
FROM @xmlData.nodes('/PrintProfile/Views/ViewName') AS T(N)) AS src
LEFT JOIN @OLDPrintIDs ids
	ON src.ProfileID=ids.Old

INSERT INTO VOL_View_PrintProfile
		(ViewType, ProfileID)
SELECT
		ViewType,
		New
FROM (
SELECT 
	N.value('../../ProfileID[1]', 'int') AS ProfileID,
	(SELECT TOP 1 vw.ViewType FROM dbo.VOL_View vw INNER JOIN dbo.VOL_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('.', 'nvarchar(255)')) AS ViewType
FROM @xmlData.nodes('/PrintProfile/VOLViews/ViewName') AS T(N)) AS src
LEFT JOIN @OLDPrintIDs ids
	ON src.ProfileID=ids.Old


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
-- Print Profiles
*/

/*
-- Excel Profiles
-- !!!!! RUN ONCE !!!!!
-- VERIFIED JAN 17, 2015
BEGIN TRY
	BEGIN TRANSACTION


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
WHERE gfo.FieldID IS NOT NULL OR vfo.FieldID IS NOT NULL
	
INSERT INTO CIC_View_ExcelProfile
        ( ViewType, ProfileID )
SELECT ViewType, New
FROM (SELECT
     (SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('.', 'nvarchar(255)')) AS ViewType,
     N.value('../../ProfileID[1]', 'int') AS ProfileID 
FROM @xmlData.nodes('/ExcelProfile/Views/ViewName') AS T(N)) src
LEFT JOIN @OLDExcelProfileIDs ids
	ON ids.Old=src.ProfileID


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
-- Excel Profiles
*/

/*
-- General Headings
-- VERIFIED JAN 17, 2015
-- !!!! ONLY RUN ONCE !!!!!
BEGIN TRY
	BEGIN TRANSACTION
SET @ObjectType='Publication'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @OLDGROUPIDS table (Old int, New int)

MERGE INTO CIC_GeneralHeading_Group dst
USING (
SELECT 
		N.value('GroupID[1]', 'int') AS GroupID,
		pub.PB_ID,
	   N.value('DisplayOrder[1]', 'tinyint') AS DisplayOrder
FROM @xmlData.nodes('//Pub/Groups/Grp') AS T(N)
INNER JOIN CIC_Publication pub
	ON pub.PubCode=N.value('../../PubCode[1]', 'nvarchar(100)') 
) src
	ON 0=1
WHEN NOT MATCHED BY TARGET THEN
	INSERT (PB_ID, DisplayOrder) VALUES (src.PB_ID, src.DisplayOrder)

	OUTPUT src.GroupID, Inserted.GroupID INTO @OLDGROUPIDS
	;


INSERT INTO CIC_GeneralHeading_Group_Name
		(GroupID, LangID, Name)
SELECT 
       New AS GroupID,
	   N.value('LangID[1]', 'smallint') AS LangID,
	   N.value('Name[1]', 'nvarchar(200)') AS Name
FROM @xmlData.nodes('//Pub/Groups/Grp/Descriptions/GrpLang') AS T(N)
INNER JOIN @OLDGROUPIDS ids
	ON ids.Old=N.value('GroupID[1]', 'int')

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
		(SELECT New FROM @OLDGROUPIDS WHERE Old=N.value('HeadingGroup[1]', 'int')) AS HeadingGroup,
		N.value('Used[1]', 'bit') AS Used,
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

INSERT INTO CIC_GeneralHeading_Name
SELECT New AS GH_ID, LangID, Name
FROM (SELECT
		N.value('../../GH_ID[1]', 'int') AS GH_ID,
		N.value('LangID[1]', 'smallint') AS LangID,
		N.value('Name[1]', 'nvarchar(200)') AS Name
FROM @xmlData.nodes('//Pub/Headings/Heading/Descriptions/Lang') AS T(N)) names
LEFT JOIN @OLDGHID ids ON names.GH_ID=ids.Old


INSERT INTO CIC_GeneralHeading_Related (GH_ID, RelatedGH_ID)
SELECT 
	   (SELECT New FROM @OLDGHID WHERE Old=N.value('../../GH_ID[1]', 'int')) AS GH_ID,
	   (SELECT New FROM @OLDGHID WHERE Old=N.value('.[1]', 'int')) AS RelatedGH_ID
FROM @xmlData.nodes('//Pub/Headings/Heading/Related/RelatedGH_ID') AS T(N)

DECLARE @OLDHEADINGTAX table (Old int, New int)

MERGE INTO CIC_GeneralHeading_TAX dst
USING (
SELECT 
		N.value('GH_TAX_ID[1]', 'int') AS GH_TAX_ID,
	   (SELECT New FROM @OLDGHID WHERE Old=N.value('GH_ID[1]', 'int')) AS GH_ID,
	   N.value('MatchAny[1]', 'bit') AS MatchAny
FROM @xmlData.nodes('//Pub/Headings/Heading/Taxonomy/Link') AS T(N)
) src
	ON 0=1
WHEN NOT MATCHED BY TARGET THEN
	INSERT (GH_ID, MatchAny) VALUES (src.GH_ID, src.MatchAny)
	
	OUTPUT src.GH_TAX_ID, Inserted.	GH_TAX_ID INTO @OLDHEADINGTAX

	;


INSERT INTO CIC_GeneralHeading_TAX_TM
		(GH_TAX_ID, Code)
SELECT 
	   (SELECT New FROM @OLDHEADINGTAX WHERE Old=N.value('../../GH_TAX_ID[1]', 'int')) AS GH_TAX_ID,
	   N.value('.[1]', 'varchar(21)') AS Code
FROM @xmlData.nodes('//Pub/Headings/Heading/Taxonomy/Link/Terms/Code') AS T(N)

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
*/

-- General Headings

/*
-- Field Help
-- VERIFIED JAN 17, 2015
SET @ObjectType='Field Help'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

INSERT INTO dbo.GBL_FieldOption_Description
        ( FieldID ,
          LangID ,
          CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          HelpText
        )
SELECT * FROM 
(SELECT fo.FieldID AS FieldID,
		N.value('LangID[1]', 'smallint') AS LangID,
		GETDATE() AS CREATED_DATE,
		'(Import)' AS CREATED_BY,
		GETDATE() AS MODIFIED_DATE,
		'(Import)' AS MODIFIED_BY,
		N.value('HelpText[1]', 'varchar(max)') AS HelpText
FROM @xmlData.nodes('//FieldHelp') AS T(N)
	INNER JOIN dbo.GBL_FieldOption fo ON N.value('FieldName[1]', 'varchar(100)')=fo.FieldName
) AS q
WHERE NOT EXISTS(SELECT * FROM GBL_FieldOption_Description WHERE q.LangID=LangID AND q.FieldID=FieldID)

INSERT INTO dbo.GBL_FieldOption_HelpByMember
        ( FieldID ,
          LangID ,
          MemberID ,
          CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          HelpText
        )
SELECT fo.FieldID,
		N.value('LangID[1]', 'smallint'),
		@MemberID,
		GETDATE(),
		'(Import)',
		GETDATE(),
		'(Import)',
		N.value('HelpText[1]', 'varchar(max)')
FROM @xmlData.nodes('//FieldHelp') AS T(N)
	INNER JOIN dbo.GBL_FieldOption fo ON N.value('FieldName[1]', 'varchar(100)')=fo.FieldName
-- Field Help
*/
/*
-- VOL Field Help
-- VERIFIED JAN 29, 2015
BEGIN TRY
	BEGIN TRANSACTION

SET @ObjectType='VOL Field Help'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

INSERT INTO dbo.VOL_FieldOption_Description
        ( FieldID ,
          LangID ,
          CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          HelpText
        )
SELECT * FROM 
(SELECT fo.FieldID AS FieldID,
		N.value('LangID[1]', 'smallint') AS LangID,
		GETDATE() AS CREATED_DATE,
		'(Import)' AS CREATED_BY,
		GETDATE() AS MODIFIED_DATE,
		'(Import)' AS MODIFIED_BY,
		N.value('HelpText[1]', 'varchar(max)') AS HelpText
FROM @xmlData.nodes('//FieldHelp') AS T(N)
	INNER JOIN dbo.VOL_FieldOption fo ON N.value('FieldName[1]', 'varchar(100)')=fo.FieldName
) AS q
WHERE NOT EXISTS(SELECT * FROM VOL_FieldOption_Description WHERE q.LangID=LangID AND q.FieldID=FieldID)

INSERT INTO dbo.VOL_FieldOption_HelpByMember
        ( FieldID ,
          LangID ,
          MemberID ,
          CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          HelpText
        )
SELECT fo.FieldID,
		N.value('LangID[1]', 'smallint'),
		@MemberID,
		GETDATE(),
		'(Import)',
		GETDATE(),
		'(Import)',
		N.value('HelpText[1]', 'varchar(max)')
FROM @xmlData.nodes('//FieldHelp') AS T(N)
	INNER JOIN dbo.VOL_FieldOption fo ON N.value('FieldName[1]', 'varchar(100)')=fo.FieldName

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
-- VOL Field Help
*/

-- Offline Tools
-- VERIFIED MAR 29, 2015
/*
BEGIN TRANSACTION
	BEGIN TRY
SET @ObjectType='Offline Tools'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

INSERT INTO dbo.CIC_Offline_Machines
        ( MemberID, MachineName, PublicKey )
SELECT  @MemberID ,
        N.value('MachineName[1]', 'varchar(255)'),
        N.value('PublicKey[1]', 'varchar(max)')
FROM @xmlData.nodes('//Machine') AS T(N)
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_Offline_Machines WHERE MemberID=@MemberID AND MachineName=N.value('MachineName[1]', 'varchar(255)'))

INSERT INTO dbo.CIC_SecurityLevel_Machine
	( MachineID, SL_ID )
SELECT om.MachineID, sl.SL_ID
FROM @xmlData.nodes('//Machine/UserTypes/SecurityLevel') AS T(N)
INNER JOIN dbo.CIC_SecurityLevel_Name sl
	ON sl.SecurityLevel=N.value('.[1]', 'varchar(255)') AND MemberID_Cache=@MemberID
INNER JOIN dbo.CIC_Offline_Machines om
	ON om.MachineName= N.value('../../MachineName[1]', 'varchar(255)') AND MemberID=@MemberID
WHERE NOT EXISTS(SELECT * FROM dbo.CIC_SecurityLevel_Machine WHERE MachineID=om.MachineID AND SL_ID=sl.SL_ID)

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
*/
-- Offline Tools

-- Update Email Text
-- !!! ONLY RUN ONCE !!!
-- VERIFIED JAN 17, 2015
/*
BEGIN TRY
	BEGIN TRANSACTION


SET @ObjectType='Email Update Text'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @EMAILIDS table (Old int, New int)

MERGE INTO dbo.GBL_StandardEmailUpdate dst
USING (
SELECT  
		N.value('EmailID[1]', 'int') AS EmailID,
		N.value('Domain[1]', 'tinyint') AS Domain,
        N.value('StdForMultipleRecords[1]', 'bit') AS StdForMultipleRecords,
        N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
        N.value('CREATED_BY[1]', 'varchar(50)') AS CREATED_BY,
        N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
        N.value('MODIFIED_BY[1]', 'varchar(50)') AS MODIFIED_BY,
		@MemberID AS MemberID,
        N.value('StdSubjectBilingual[1]', 'varchar(150)') AS StdSubjectBilingual,
        N.value('DefaultMsg[1]', 'bit') AS DefaultMsg
FROM @xmlData.nodes('//UpdateText') AS T(N)
) AS src
	ON 0=1

WHEN NOT MATCHED BY TARGET THEN 
	INSERT
        ( Domain ,
          StdForMultipleRecords ,
          CREATED_DATE ,
          CREATED_BY ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          MemberID ,
          StdSubjectBilingual ,
          DefaultMsg
        )
		VALUES
        ( 
		  src.Domain ,
          src.StdForMultipleRecords ,
          src.CREATED_DATE ,
          src.CREATED_BY ,
          src.MODIFIED_DATE ,
          src.MODIFIED_BY ,
          src.MemberID ,
          src.StdSubjectBilingual ,
          src.DefaultMsg
        )

	OUTPUT src.EmailID, INserted.EmailID INTO @EMAILIDS

	;

INSERT INTO dbo.GBL_StandardEmailUpdate_Description
        ( EmailID ,
          LangID ,
          MemberID_Cache ,
          Name ,
          StdSubject ,
          StdGreetingStart ,
          StdGreetingEnd ,
          StdMessageBody ,
          StdDetailDesc ,
          StdFeedbackDesc ,
          StdSuggestOppDesc ,
          StdOrgOppsDesc ,
          StdContact
        )
SELECT  
		em.New,
        N.value('LangID[1]', 'smallint'),
        @MemberID,
        N.value('Name[1]', 'nvarchar(200)'),
        N.value('StdSubject[1]', 'nvarchar(100)'),
        N.value('StdGreetingStart[1]', 'nvarchar(100)'),
        N.value('StdGreetingEnd[1]', 'nvarchar(100)'),
        N.value('StdMessageBody[1]', 'nvarchar(1500)'),
        N.value('StdDetailDesc[1]', 'nvarchar(100)'),
        N.value('StdFeedbackDesc[1]', 'nvarchar(100)'),
        N.value('StdSuggestOppDesc[1]', 'nvarchar(150)'),
        N.value('StdOrgOppsDesc[1]', 'nvarchar(150)'),
        N.value('StdContact[1]', 'nvarchar(255)')
FROM @xmlData.nodes('//UpdateText/Descriptions/Lang') AS T(N)
INNER JOIN @EMAILIDS em
	ON em.Old=N.value('../../EmailID[1]', 'int')


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
*/
-- Update Email Text

-- History
/*
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
WHERE EXISTS(SELECT * FROM dbo.GBL_BaseTable_Description btd INNER JOIN GBL_BaseTable bt ON bt.NUM = btd.NUM WHERE btd.LangID=hl.LangID AND btd.NUM=hl.NUM AND bt.MemberID=@MemberID)
	AND NewFieldID IS NOT NULL 
ORDER BY hl.MODIFIED_DATE, hl.MODIFIED_BY, hl.NUM, NewFieldID
*/
-- History

-- History
/*
DELETE h
FROM dbo.VOL_Opportunity_History h
INNER JOIN dbo.VOL_Opportunity vo
	ON h.VNUM=vo.VNUM AND vo.MemberID=@MemberID

SET @MemberID = 1000
UPDATE hl
	SET NewFieldID=fo.FieldID
FROM cioc_data_loader.dbo.VHistoryLoader hl
INNER JOIN dbo.VOL_FieldOption fo
	ON hl.FieldName=fo.FieldName

INSERT INTO dbo.VOL_Opportunity_History
        ( VNUM ,
          LangID ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          FieldID ,
          FieldDisplay
        )
SELECT VNUM ,
          LangID ,
          MODIFIED_DATE ,
          MODIFIED_BY ,
          NewFieldID ,
          FieldDisplay FROM cioc_data_loader.dbo.VHistoryLoader hl
WHERE EXISTS(SELECT * FROM dbo.VOL_Opportunity_Description vod INNER JOIN VOL_Opportunity vo ON vo.VNUM = vod.VNUM WHERE vod.LangID=hl.LangID AND vod.VNUM=hl.VNUM AND vo.MemberID=@MemberID)
	AND NewFieldID IS NOT NULL
ORDER BY hl.MODIFIED_DATE, hl.MODIFIED_BY, hl.VNUM, NewFieldID
*/
-- History

-- GBL Feedback

-- TODO CIC_Feedback_Publication
  
/*
BEGIN TRY
	BEGIN TRANSACTION


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
FROM @xmlData.nodes('//FeedbackEntry') AS T(N)
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
FROM @xmlData.nodes('//FeedbackEntry/GBLs/GBLFeedback') AS T(N)

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
          EXTRA_CONTACT_A_NAME ,
          EXTRA_CONTACT_A_TITLE ,
          EXTRA_CONTACT_A_ORG ,
          EXTRA_CONTACT_A_PHONE1 ,
          EXTRA_CONTACT_A_PHONE2 ,
          EXTRA_CONTACT_A_PHONE3 ,
          EXTRA_CONTACT_A_FAX ,
          EXTRA_CONTACT_A_EMAIL
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
          EXTRA_CONTACT_A_NAME ,
          EXTRA_CONTACT_A_TITLE ,
          EXTRA_CONTACT_A_ORG ,
          EXTRA_CONTACT_A_PHONE1 ,
          EXTRA_CONTACT_A_PHONE2 ,
          EXTRA_CONTACT_A_PHONE3 ,
          EXTRA_CONTACT_A_FAX ,
          EXTRA_CONTACT_A_EMAIL
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
          N.value('EXTRA_CONTACT_A_NAME[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_NAME ,
          N.value('EXTRA_CONTACT_A_TITLE[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_TITLE ,
          N.value('EXTRA_CONTACT_A_ORG[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_ORG ,
          N.value('EXTRA_CONTACT_A_PHONE1[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_PHONE1 ,
          N.value('EXTRA_CONTACT_A_PHONE2[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_PHONE2 ,
          N.value('EXTRA_CONTACT_A_PHONE3[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_PHONE3 ,
          N.value('EXTRA_CONTACT_A_FAX[1]', 'nvarchar(100)') AS EXTRA_CONTACT_A_FAX ,
          N.value('EXTRA_CONTACT_A_EMAIL[1]', 'nvarchar(60)') AS EXTRA_CONTACT_A_EMAIL
FROM @xmlData.nodes('//FeedbackEntry/CICs/CICFeedback') AS T(N)

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
FROM @xmlData.nodes('//FeedbackEntry/CCRs/CCRFeedback') AS T(N)

) src
INNER JOIN @OLDGBLFB_ID ids
	ON ids.Old=src.FB_ID
	
INSERT INTO CIC_Feedback_Extra
		(FB_ID, FieldName, Value)
SELECT ids.New, FieldName, Value
FROM (
SELECT 
          N.value('FB_ID[1]', 'int') AS FB_ID ,
          N.value('FieldName[1]', 'nvarchar(255)') AS FieldName ,
          N.value('Value[1]', 'nvarchar(max)') AS Value
FROM @xmlData.nodes('//FeedbackEntry/Extras/Extra') AS T(N)
) src
INNER JOIN @OLDGBLFB_ID ids
	ON ids.Old=src.FB_ID

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH

*/
-- GBL Feedback

-- GBL Reminder
/*
-- VERIFIED JAN 17, 2015
-- Note Missing Agency
--DELETE FROM GBL_Reminder WHERE MemberID=@MemberID
BEGIN TRY
	BEGIN TRANSACTION

SET @ObjectType='Reminder'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode
SELECT @xmlData

DECLARE @OLDReminderID table (
	Old int,
	New int
)

MERGE INTO GBL_Reminder dst
USING 
(SELECT
	 N.value('ReminderID[1]', 'int') AS ReminderID,
	 N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
	 N.value('CREATED_BY[1]', 'nvarchar(50)') AS CREATED_BY,
	 N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
	 N.value('MODIFIED_BY[1]', 'nvarchar(50)') AS MODIFIED_BY,
	 @MemberID AS MemberID,
	 (SELECT User_ID FROM GBL_Users WHERE UserUID=N.value('UserUID[1]', 'uniqueidentifier')) AS UserID,
	 N.value('LangID[1]', 'smallint') AS LangID,
	 N.value('NoteTypeID[1]', 'int') AS NoteTypeID,
	 N.value('ActiveDate[1]', 'smalldatetime') AS ActiveDate,
	 N.value('DueDate[1]', 'smalldatetime') AS DueDate,
	 N.value('Notes[1]', 'nvarchar(max)') AS Notes,
	 N.value('DismissForAll[1]', 'bit') AS DismissForAll,
	 N.value('Dismissed[1]', 'bit') AS Dismissed,
	 N.value('DismissalDate[1]', 'smalldatetime') AS DismissalDate
FROM @xmlData.nodes('//Reminder') AS T(N) WHERE EXISTS(SELECT * FROM GBL_Users WHERE UserUID=N.value('UserUID[1]', 'uniqueidentifier')) ) AS src
	ON 0=1
WHEN NOT MATCHED THEN
	INSERT 
			(CREATED_DATE,
			 CREATED_BY,
			 MODIFIED_DATE,
			 MODIFIED_BY,
			 MemberID,
			 UserID,
			 LangID,
			 NoteTypeID,
			 ActiveDate,
			 DueDate,
			 Notes,
			 DismissForAll,
			 Dismissed,
			 DismissalDate
			)
		VALUES
			(
			 src.CREATED_DATE,
			 src.CREATED_BY,
			 src.MODIFIED_DATE,
			 src.MODIFIED_BY,
			 src.MemberID,
			 src.UserID,
			 src.LangID,
			 src.NoteTypeID,
			 src.ActiveDate,
			 src.DueDate,
			 src.Notes,
			 src.DismissForAll,
			 src.Dismissed,
			 src.DismissalDate
			)
	OUTPUT src.ReminderID, Inserted.ReminderID INTO @OLDReminderID
	;


--INSERT INTO @OLDReminderID (Old, New)
--SELECT N.value('ReminderID[1]', 'int') AS ReminderID,
--	N.value('ReminderID[1]', 'int') + 1000 AS New
--FROM @xmlData.nodes('//Reminder') AS T(N)


SELECT * FROM @OLDReminderID


INSERT INTO GBL_Reminder_User
		(ReminderID, User_ID)
SELECT New, User_ID
FROM (
SELECT
		N.value('../../ReminderID[1]', 'int') AS ReminderID,
		(SELECT User_ID FROM GBL_Users WHERE UserUID=N.value('.', 'uniqueidentifier')) AS User_ID
FROM @xmlData.nodes('//Reminder/Users/UserUID') AS T(N)) src
INNER JOIN @OLDReminderID ids
	ON src.ReminderID=ids.Old
WHERE src.User_ID IS NOT NULL

INSERT INTO GBL_Reminder_User_Dismiss
		(ReminderID,
		 User_ID,
		 DismissalDate
		)
SELECT New, User_ID, DismissalDate
FROM (
SELECT
		N.value('../../ReminderID[1]', 'int') AS ReminderID,
		(SELECT User_ID FROM GBL_Users WHERE UserUID=N.value('UserUID[1]', 'uniqueidentifier')) AS User_ID,
		N.value('DismissalDate[1]', 'datetime') AS DismissalDate
FROM @xmlData.nodes('//Reminder/UserDismissed/Dismiss') AS T(N)) src
INNER JOIN @OLDReminderID ids
	ON src.ReminderID=ids.Old
WHERE src.User_ID IS NOT NULL

INSERT INTO GBL_Reminder_Agency
		(ReminderID, AgencyID)
SELECT New, AgencyID
FROM (
SELECT
		N.value('../../ReminderID[1]', 'int') AS ReminderID,
		(SELECT AgencyID FROM GBL_Agency WHERE AgencyCode=N.value('.', 'char(3)')) AS AgencyID
FROM @xmlData.nodes('//Reminder/Agencies/AgencyCode') AS T(N)) src
INNER JOIN @OLDReminderID ids
	ON src.ReminderID=ids.Old
WHERE src.AgencyID IS NOT NULL

INSERT INTO GBL_BT_Reminder
		(NUM, ReminderID)
SELECT NUM, New
FROM (
SELECT
		N.value('../../ReminderID[1]', 'int') AS ReminderID,
		N.value('.', 'varchar(8)') AS NUM
FROM @xmlData.nodes('//Reminder/CICRecords/NUM') AS T(N)) src
INNER JOIN @OLDReminderID ids
	ON src.ReminderID=ids.Old
WHERE EXISTS(SELECT * FROM dbo.GBL_BaseTable WHERE NUM=src.NUM)

INSERT INTO VOL_OP_Reminder
		(VNUM, ReminderID)
SELECT VNUM, New
FROM (
SELECT
		N.value('../../ReminderID[1]', 'int') AS ReminderID,
		N.value('.', 'varchar(10)') AS VNUM
FROM @xmlData.nodes('//Reminder/VOLRecords/VNUM') AS T(N)) src
INNER JOIN @OLDReminderID ids
	ON src.ReminderID=ids.Old
WHERE EXISTS(SELECT * FROM dbo.VOL_Opportunity WHERE VNUM=src.VNUM)

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
*/
-- GBL Reminder

-- GBL Export Profile
-- VERIFIED JAN 17, 2015
/*
BEGIN TRY
	BEGIN TRANSACTION

SET @ObjectType='Export Profile'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @OLDExportProfileID table (
	Old int,
	New int
)

MERGE INTO CIC_ExportProfile dst
USING (
SELECT 
		 N.value('ProfileID[1]', 'int') AS ProfileID,
		 N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
		 N.value('CREATED_BY[1]', 'varchar(50)') AS CREATED_BY,
		 N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
		 N.value('MODIFIED_BY[1]', 'varchar(50)') AS MODIFIED_BY,
		 @MemberID AS MemberID,
		 N.value('SubmitChangesToAccessURL[1]', 'varchar(200)') AS SubmitChangesToAccessURL,
		 N.value('IncludePrivacyProfiles[1]', 'bit') AS IncludePrivacyProfiles
FROM @xmlData.nodes('/ExportProfile') AS T(N) ) src
	ON 0=1
WHEN NOT MATCHED BY TARGET THEN
	INSERT
		(CREATED_DATE,
		 CREATED_BY,
		 MODIFIED_DATE,
		 MODIFIED_BY,
		 MemberID,
		 SubmitChangesToAccessURL,
		 IncludePrivacyProfiles
		)
	 VALUES
		(src.CREATED_DATE,
		 src.CREATED_BY,
		 src.MODIFIED_DATE,
		 src.MODIFIED_BY,
		 src.MemberID,
		 src.SubmitChangesToAccessURL,
		 src.IncludePrivacyProfiles
		)

	OUTPUT src.ProfileID, Inserted.ProfileID INTO @OLDExportProfileID
	;

-- INSERT INTO @OLDExportProfileID
--		(Old, New)
--SELECT
-- N.value('ProfileID[1]', 'int') AS ProfileID,
--		 N.value('ProfileID[1]', 'int') + 1000 AS ProfileIDNew
--FROM @xmlData.nodes('/ExportProfile') AS T(N)

SELECT * FROM @OLDExportProfileID

INSERT INTO CIC_ExportProfile_Description
		(ProfileID,
		 LangID,
		 MemberID_Cache,
		 Name,
		 SourceDbName,
		 SourceDbURL
		)
SELECT New, LangID, MemberID_Cache, Name, SourceDbName, SourceDbURL
FROM (
SELECT 
		 N.value('../../ProfileID[1]', 'int') AS ProfileID,
		 N.value('LangID[1]', 'smallint') AS LangID,
		 @MemberID AS MemberID_Cache,
		 N.value('Name[1]', 'nvarchar(100)') AS Name,
		 N.value('SourceDbName[1]', 'nvarchar(255)') AS SourceDbName,
		 N.value('SourceDbURL[1]', 'nvarchar(200)') AS SourceDbURL
FROM @xmlData.nodes('/ExportProfile/Descriptions/Lang') AS T(N)) AS src
INNER JOIN @OLDExportProfileID ids
	ON src.ProfileID=ids.Old


INSERT INTO CIC_ExportProfile_Dist
		(ProfileID, DST_ID)
SELECT New, DST_ID
FROM (
SELECT
		N.value('../../ProfileID[1]', 'int') AS ProfileID,
		N.value('.', 'varchar(100)') AS DistCode
FROM @xmlData.nodes('/ExportProfile/Distributions/DistCode') AS T(N)) AS src
INNER JOIN @OLDExportProfileID ids
	ON src.ProfileID=ids.Old
INNER JOIN CIC_Distribution dc
	ON dc.DistCode = src.DistCode 


INSERT INTO CIC_ExportProfile_Fld
		(ProfileID, FieldID)
SELECT New, FieldID
FROM (
SELECT 
		N.value('../../ProfileID[1]', 'int') AS ProfileID,
		N.value('.', 'nvarchar(100)') AS FieldName
FROM @xmlData.nodes('/ExportProfile/Fields/Field') AS T(N)) AS src
INNER JOIN @OLDExportProfileID ids
	ON src.ProfileID=ids.Old
INNER JOIN GBL_FieldOption fo
	ON src.FieldName=fo.FieldName


INSERT INTO CIC_ExportProfile_Pub
		(ProfileID,
		 PB_ID,
		 IncludeHeadings,
		 IncludeDescription
		)
SELECT New, 
		 PB_ID,
		 IncludeHeadings,
		 IncludeDescription
FROM (SELECT
		 N.value('ProfileID[1]', 'int') AS ProfileID,
		 N.value('PubCode[1]', 'varchar(100)') AS PubCode,
		 N.value('IncludeHeadings[1]', 'bit') AS IncludeHeadings,
		 N.value('IncludeDescription[1]', 'bit') AS IncludeDescription
FROM @xmlData.nodes('/ExportProfile/Publications/Publication') AS T(N)) AS src
INNER JOIN @OLDExportProfileID ids
	ON src.ProfileID=ids.Old
INNER JOIN CIC_Publication pb
	ON src.PubCode=pb.PubCode

INSERT INTO CIC_View_ExportProfile
		(ViewType, ProfileID)
SELECT
		ViewType,
		New
FROM (
SELECT 
	N.value('../../ProfileID[1]', 'int') AS ProfileID,
	(SELECT TOP 1 vw.ViewType FROM dbo.CIC_View vw INNER JOIN dbo.CIC_View_Description vwd ON vwd.ViewType = vw.ViewType AND (vw.MemberID=@MemberID OR vw.MemberID IS NULL) WHERE vwd.ViewName=N.value('.', 'nvarchar(255)')) AS ViewType
FROM @xmlData.nodes('/ExportProfile/Views/ViewName') AS T(N)) AS src
INNER JOIN @OLDExportProfileID ids
	ON src.ProfileID=ids.Old

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
*/
-- GBL Export Profile

-- CIC Ward 
/*
-- ONLY RUN ONCE

BEGIN TRY
	BEGIN TRANSACTION

SET @ObjectType='CIC Ward'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @OLDWD_ID table (
	Old int,
	New int
)

MERGE INTO CIC_Ward dst
USING (
SELECT
	N.value('WD_ID[1]', 'int') AS WD_ID,
	N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
	N.value('CREATED_BY[1]', 'nvarchar(50)') AS CREATED_BY,
	N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
	N.value('MODIFIED_BY[1]', 'nvarchar(50)') AS MODIFIED_BY,
	@MemberID AS MemberID,
	N.value('WardNumber[1]', 'smallint') AS WardNumber,
	(SELECT CM_ID FROM GBL_Community WHERE CM_GUID=N.value('CM_GUID[1]', 'uniqueidentifier')) AS Municipality
FROM @xmlData.nodes('/Ward') AS T(N)) src
ON 0=1
	WHEN NOT MATCHED BY TARGET THEN
	INSERT
		(
		 CREATED_DATE,
		 CREATED_BY,
		 MODIFIED_DATE,
		 MODIFIED_BY,
		 MemberID,
		 WardNumber,
		 Municipality
		)
	VALUES
		(
		 src.CREATED_DATE,
		 src.CREATED_BY,
		 src.MODIFIED_DATE,
		 src.MODIFIED_BY,
		 src.MemberID,
		 src.WardNumber,
		 src.Municipality
		)

	OUTPUT src.WD_ID, Inserted.WD_ID INTO @OLDWD_ID
	;


--INSERT INTO @OLDWD_ID (Old, New)
--SELECT 
--	N.value('WD_ID[1]', 'int') AS WD_ID,
--	N.value('WD_ID[1]', 'int') + 1000 AS New
--FROM @xmlData.nodes('/Ward') AS T(N)

SELECT * FROM @OLDWD_ID

INSERT INTO CIC_Ward_Name
		(WD_ID, LangID, Name)
SELECT 
	New,
	LangID,
	Name
FROM (
SELECT
	N.value('../../WD_ID[1]', 'int') AS WD_ID,
	N.value('LangID[1]', 'smallint') AS LangID,
	N.value('Name[1]', 'nvarchar(255)') AS Name
FROM @xmlData.nodes('/Ward/Names/Name') AS T(N)) AS src
INNER JOIN @OLDWD_ID ids
	ON src.WD_ID=ids.Old


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
*/
-- CIC Ward


-- Extra Drop Down
/*
INSERT INTO CIC_ExtraDropDown
		(FieldName,
		 CREATED_DATE,
		 CREATED_BY,
		 MODIFIED_DATE,
		 MODIFIED_BY,
		 MemberID,
		 Code,
		 DisplayOrder
		)
SELECT FieldName,
		 CREATED_DATE,
		 CREATED_BY,
		 MODIFIED_DATE,
		 MODIFIED_BY,
		 @MemberID,
		 Code,
		 DisplayOrder
FROM cioc_data_loader.dbo.CIC_ExtraDropDown src

INSERT INTO CIC_ExtraDropDown_Name
		(EXD_ID, LangID, FieldName_Cache, Name )
SELECT cd.EXD_ID, ddn.LangID, ddn.FieldName_Cache, ddn.Name
FROM cioc_data_loader.dbo.CIC_ExtraDropDown dd
INNER JOIN cioc_data_loader.dbo.CIC_ExtraDropDown_Name ddn
	ON ddn.EXD_ID=dd.EXD_ID
INNER JOIN CIC_ExtraDropDown cd
	ON cd.FieldName=dd.FieldName AND cd.Code=dd.Code

*/
-- Extra Drop Down

-- VOL Commitment Length
-- VERIFIED JAN 17, 2015
/*
BEGIN TRY
	BEGIN TRANSACTION


SET @ObjectType='VOL Commitment Length'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @CLIDS table (Old int, New int)

MERGE INTO VOL_CommitmentLength dst
USING (
SELECT 
		N.value('CL_ID[1]', 'int') AS CL_ID,
	   N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
	   N.value('CREATED_BY[1]', 'nvarchar(100)') AS CREATED_BY,
	   N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
	   N.value('MODIFIED_BY[1]', 'nvarchar(100)') AS MODIFIED_BY,
	   @MemberID AS MemberID,
	   N.value('Code[1]', 'varchar(20)') AS Code,
	   N.value('DisplayOrder[1]', 'tinyint') AS DisplayOrder
FROM @xmlData.nodes('/CommitmentLengths/CommitmentLength') AS T(N)
WHERE NOT EXISTS(SELECT * FROM VOL_CommitmentLength_Name cln INNER JOIN VOL_CommitmentLength cl ON cl.CL_ID = cln.CL_ID WHERE Name=N.value('Descriptions[1]/Lang[LangID=0][1]/Name[1]', 'nvarchar(255)') AND (cl.MemberID IS NULL OR cl.MemberID=@MemberID))
) AS src
	ON 0=1
WHEN NOT MATCHED BY TARGET THEN
	INSERT 
			(CREATED_DATE,
			 CREATED_BY,
			 MODIFIED_DATE,
			 MODIFIED_BY,
			 MemberID,
			 Code,
			 DisplayOrder
			)
	VALUES
			(
			src.CREATED_DATE,
			 src.CREATED_BY,
			 src.MODIFIED_DATE,
			 src.MODIFIED_BY,
			 src.MemberID,
			 src.Code,
			 src.DisplayOrder
			)

	OUTPUT src.CL_ID, Inserted.CL_ID INTO @CLIDS
	;


INSERT INTO VOL_CommitmentLength_Name
		(CL_ID, LangID, Name)
SELECT 
		ids.New,
	   N.value('LangID[1]', 'nvarchar(100)') AS LangID,
	   N.value('Name[1]', 'nvarchar(100)') AS Name
FROM @xmlData.nodes('/CommitmentLengths/CommitmentLength/Descriptions/Lang') AS T(N)
INNER JOIN @CLIDS ids
	ON N.value('CL_ID[1]', 'nvarchar(100)')=ids.Old


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
*/
-- VOL Commitment Length

-- VOL Profile
/*
BEGIN TRY
	BEGIN TRANSACTION

SET @ObjectType='VOL Profile'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

INSERT INTO VOL_Profile
		(ProfileID,
		 CREATED_DATE,
		 MODIFIED_DATE,
		 MemberID,
		 Email,
		 Password,
		 PasswordHashRepeat,
		 PasswordHashSalt,
		 PasswordHash,
		 Active,
		 Blocked,
		 LoginKey,
		 FirstName,
		 LastName,
		 Phone,
		 Address,
		 City,
		 Province,
		 PostalCode,
		 LangID,
		 BirthDate,
		 NotifyNew,
		 NotifyUpdated,
		 SCH_M_Morning,
		 SCH_M_Afternoon,
		 SCH_M_Evening,
		 SCH_TU_Morning,
		 SCH_TU_Afternoon,
		 SCH_TU_Evening,
		 SCH_W_Morning,
		 SCH_W_Afternoon,
		 SCH_W_Evening,
		 SCH_TH_Morning,
		 SCH_TH_Afternoon,
		 SCH_TH_Evening,
		 SCH_F_Morning,
		 SCH_F_Afternoon,
		 SCH_F_Evening,
		 SCH_ST_Morning,
		 SCH_ST_Afternoon,
		 SCH_ST_Evening,
		 SCH_SN_Morning,
		 SCH_SN_Afternoon,
		 SCH_SN_Evening,
		 OrgCanContact,
		 NewEmail,
		 ConfirmationToken,
		 ConfirmationDate,
		 Verified,
		 AgreedToPrivacyPolicy
		)
SELECT 
		N.value('ProfileID[1]', 'uniqueidentifier') AS ProfileID,
	   N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
	   N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
	   @MemberID AS MemberID,
	   N.value('Email[1]', 'varchar(60)') AS Email,
	   N.value('Password[1]', 'varchar(32)') AS Password,
	   N.value('PasswordHashRepeat[1]', 'int') AS PasswordHashRepeat,
	   N.value('PasswordHashSalt[1]', 'varchar(44)') AS PasswordHashSalt,
	   N.value('PasswordHash[1]', 'varchar(44)') AS PasswordHash,
	   N.value('Active[1]', 'bit') AS Active,
	   N.value('Blocked[1]', 'bit') AS Blocked,
	   N.value('LoginKey[1]', 'char(32)') AS LoginKey,
	   N.value('FirstName[1]', 'nvarchar(50)') AS FirstName,
	   N.value('LastName[1]', 'nvarchar(50)') AS LastName,
	   N.value('Phone[1]', 'nvarchar(100)') AS Phone,
	   N.value('Address[1]', 'nvarchar(150)') AS Address,
	   N.value('City[1]', 'nvarchar(100)') AS City,
	   N.value('Province[1]', 'varchar(2)') AS Province,
	   N.value('PostalCode[1]', 'varchar(20)') AS PostalCode,
	   N.value('LangID[1]', 'smallint') AS LangID,
	   N.value('BirthDate[1]', 'smalldatetime') AS BirthDate,
	   N.value('NotifyNew[1]', 'bit') AS NotifyNew,
	   N.value('NotifyUpdated[1]', 'bit') AS NotifyUpdated,
	   N.value('SCH_M_Morning[1]', 'bit') AS SCH_M_Morning,
	   N.value('SCH_M_Afternoon[1]', 'bit') AS SCH_M_Afternoon,
	   N.value('SCH_M_Evening[1]', 'bit') AS SCH_M_Evening,
	   N.value('SCH_TU_Morning[1]', 'bit') AS SCH_TU_Morning,
	   N.value('SCH_TU_Afternoon[1]', 'bit') AS SCH_TU_Afternoon,
	   N.value('SCH_TU_Evening[1]', 'bit') AS SCH_TU_Evening,
	   N.value('SCH_W_Morning[1]', 'bit') AS SCH_W_Morning,
	   N.value('SCH_W_Afternoon[1]', 'bit') AS SCH_W_Afternoon,
	   N.value('SCH_W_Evening[1]', 'bit') AS SCH_W_Evening,
	   N.value('SCH_TH_Morning[1]', 'bit') AS SCH_TH_Morning,
	   N.value('SCH_TH_Afternoon[1]', 'bit') AS SCH_TH_Afternoon,
	   N.value('SCH_TH_Evening[1]', 'bit') AS SCH_TH_Evening,
	   N.value('SCH_F_Morning[1]', 'bit') AS SCH_F_Morning,
	   N.value('SCH_F_Afternoon[1]', 'bit') AS SCH_F_Afternoon,
	   N.value('SCH_F_Evening[1]', 'bit') AS SCH_F_Evening,
	   N.value('SCH_ST_Morning[1]', 'bit') AS SCH_ST_Morning,
	   N.value('SCH_ST_Afternoon[1]', 'bit') AS SCH_ST_Afternoon,
	   N.value('SCH_ST_Evening[1]', 'bit') AS SCH_ST_Evening,
	   N.value('SCH_SN_Morning[1]', 'bit') AS SCH_SN_Morning,
	   N.value('SCH_SN_Afternoon[1]', 'bit') AS SCH_SN_Afternoon,
	   N.value('SCH_SN_Evening[1]', 'bit') AS SCH_SN_Evening,
	   N.value('OrgCanContact[1]', 'bit') AS OrgCanContact,
	   N.value('NewEmail[1]', 'varchar(60)') AS NewEmail,
	   N.value('ConfirmationToken[1]', 'char(32)') AS ConfirmationToken,
	   N.value('ConfirmationDate[1]', 'smalldatetime') AS ConfirmationDate,
	   N.value('Verified[1]', 'bit') AS Verified,
	   N.value('AgreedToPrivacyPolicy[1]', 'bit') AS AgreedToPrivacyPolicy
FROM @xmlData.nodes('/VolProfiles/VolProfile') AS T(N)
--WHERE NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=N.value('ProfileID[1]', 'uniqueidentifier') )


INSERT INTO VOL_Profile_AI
		(ProfileID, AI_ID)
SELECT * FROM
(
SELECT 
	   N.value('../../ProfileID[1]', 'uniqueidentifier') AS ProfileID,
	   intname.AI_ID
FROM @xmlData.nodes('/VolProfiles/VolProfile/Interests/Name') AS T(N)
INNER JOIN VOL_Interest_Name intname
	ON intname.Name=N.value('.', 'nvarchar(255)') AND LangID=0
) src
--WHERE NOT EXISTS(SELECT * FROM VOL_Profile_AI WHERE src.ProfileID=ProfileID AND src.AI_ID=AI_ID)


INSERT INTO VOL_Profile_CM
		(ProfileID, CM_ID)
SELECT * FROM
(
SELECT 
	   N.value('../../ProfileID[1]', 'uniqueidentifier') AS ProfileID,
	   (SELECT CM_ID FROM GBL_Community WHERE CM_GUID=N.value('.', 'uniqueidentifier')) AS CM_ID
FROM @xmlData.nodes('/VolProfiles/VolProfile/Communities/CM_GUID') AS T(N)
) src
--WHERE NOT EXISTS(SELECT * FROM VOL_Profile_CM WHERE src.ProfileID=ProfileID AND src.CM_ID=CM_ID)

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
*/
-- VOL Profile

-- VOL Referral
/*
SET @ObjectType='VOL Referral'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

INSERT INTO VOL_OP_Referral
		(CREATED_DATE,
		 CREATED_BY,
		 MODIFIED_DATE,
		 MODIFIED_BY,
		 MemberID,
		 ViewType,
		 AccessURL,
		 LangID,
		 ReferralDate,
		 FollowUpFlag,
		 ProfileID,
		 VolunteerName,
		 VolunteerPhone,
		 VolunteerEmail,
		 VolunteerAddress,
		 VolunteerCity,
		 VolunteerPostalCode,
		 VolunteerNotes,
		 NotifyOrgType,
		 NotifyOrgDate,
		 VolunteerContactType,
		 VolunteerContactDate,
		 SuccessfulPlacement,
		 OutcomeNotes,
		 VolunteerSuccessfulPlacement,
		 VolunteerOutcomeNotes,
		 VolunteerHideReferral,
		 VNUM
		)
--SELECT 
--	   CREATED_DATE,
--	   CREATED_BY,
--	   MODIFIED_DATE,
--	   MODIFIED_BY,
--	   MemberID,
--	   (SELECT vw.ViewType FROM VOL_View vw INNER JOIN VOL_View_Description vd ON vd.ViewType = vw.ViewType WHERE vw.MemberID=@MemberID AND LangID=0 AND ViewName=r.ViewName) AS ViewType,
--	   AccessURL,
--	   LangID,
--	   ReferralDate,
--	   FollowUpFlag,
--	   ProfileID,
--	   VolunteerName,
--	   VolunteerPhone,
--	   VolunteerEmail,
--	   VolunteerAddress,
--	   VolunteerCity,
--	   VolunteerPostalCode,
--	   VolunteerNotes,
--	   NotifyOrgType,
--	   NotifyOrgDate,
--	   VolunteerContactType,
--	   VolunteerContactDate,
--	   SuccessfulPlacement,
--	   OutcomeNotes,
--	   VolunteerSuccessfulPlacement,
--	   VolunteerOutcomeNotes,
--	   VolunteerHideReferral,
--	   VNUM
--FROM cioc_data_loader.dbo.VOL_OP_Referral r
--WHERE MemberID=@MemberID
SELECT 
	   N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
	   N.value('CREATED_BY[1]', 'varchar(50)') AS CREATED_BY,
	   N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
	   N.value('MODIFIED_BY[1]', 'varchar(50)') AS MODIFIED_BY,
	   @MemberID AS MemberID,
	   (SELECT vw.ViewType FROM VOL_View vw INNER JOIN VOL_View_Description vd ON vd.ViewType = vw.ViewType WHERE vw.MemberID=@MemberID AND LangID=0 AND ViewName=N.value('ViewName[1]', 'nvarchar(255)')) AS ViewType,
	   N.value('AccessURL[1]', 'nvarchar(160)') AS AccessURL,
	   N.value('LangID[1]', 'smallint') AS LangID,
	   N.value('ReferralDate[1]', 'smalldatetime') AS ReferralDate,
	   N.value('FollowUpFlag[1]', 'bit') AS FollowUpFlag,
	   N.value('ProfileID[1]', 'uniqueidentifier') AS ProfileID,
	   N.value('VolunteerName[1]', 'nvarchar(100)') AS VolunteerName,
	   N.value('VolunteerPhone[1]', 'nvarchar(100)') AS VolunteerPhone,
	   N.value('VolunteerEmail[1]', 'varchar(60)') AS VolunteerEmail,
	   N.value('VolunteerAddress[1]', 'nvarchar(150)') AS VolunteerAddress,
	   N.value('VolunteerCity[1]', 'nvarchar(100)') AS VolunteerCity,
	   N.value('VolunteerPostalCode[1]', 'varchar(20)') AS VolunteerPostalCode,
	   N.value('VolunteerNotes[1]', 'nvarchar(max)') AS VolunteerNotes,
	   N.value('NotifyOrgType[1]', 'int') AS NotifyOrgType,
	   N.value('NotifyOrgDate[1]', 'smalldatetime') AS NotifyOrgDate,
	   N.value('VolunteerContactType[1]', 'int') AS VolunteerContactType,
	   N.value('VolunteerContactDate[1]', 'smalldatetime') AS VolunteerContactDate,
	   N.value('SuccessfulPlacement[1]', 'bit') AS SuccessfulPlacement,
	   N.value('OutcomeNotes[1]', 'nvarchar(max)') AS OutcomeNotes,
	   N.value('VolunteerSuccessfulPlacement[1]', 'bit') AS VolunteerSuccessfulPlacement,
	   N.value('VolunteerOutcomeNotes[1]', 'nvarchar(max)') AS VolunteerOutcomeNotes,
	   N.value('VolunteerHideReferral[1]', 'bit') AS VolunteerHideReferral,
	   N.value('VNUM[1]', 'varchar(10)') AS VNUM
FROM @xmlData.nodes('/Referrals/Referral') AS T(N)
*/

-- VOL Referral

-- VOL Feedback
-- TODO VOL_Feedback_Extra
/*
SET @ObjectType='VOL Feedback'
SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

BEGIN TRY
	BEGIN TRANSACTION

INSERT INTO VOL_Feedback
		(MemberID,
		 FEEDBACK_OWNER,
		 LangID,
		 SUBMIT_DATE,
		 IPAddress,
		 User_ID,
		 ViewType,
		 AccessURL,
		 FULL_UPDATE,
		 NO_CHANGES,
		 REMOVE_RECORD,
		 FB_NOTES,
		 FBKEY,
		 NUM,
		 ACCESSIBILITY,
		 ADDITIONAL_REQUIREMENTS,
		 APPLICATION_DEADLINE,
		 BENEFITS,
		 CLIENTS,
		 COMMITMENT_LENGTH,
		 CONTACT_NAME,
		 CONTACT_TITLE,
		 CONTACT_ORG,
		 CONTACT_PHONE1,
		 CONTACT_PHONE2,
		 CONTACT_PHONE3,
		 CONTACT_FAX,
		 CONTACT_EMAIL,
		 COST,
		 DISPLAY_UNTIL,
		 DUTIES,
		 END_DATE,
		 EXTRA,
		 EXTRA_B,
		 INTERACTION_LEVEL,
		 INTERESTS,
		 INTERNAL_MEMO,
		 LOCATION,
		 LIABILITY_INSURANCE,
		 MAX_AGE,
		 MIN_AGE,
		 MINIMUM_HOURS,
		 MINIMUM_HOURS_PER,
		 MORE_INFO_URL,
		 NO_UPDATE_EMAIL,
		 NON_PUBLIC,
		 NUM_NEEDED,
		 NUM_NEEDED_NOTES,
		 NUM_NEEDED_TOTAL,
		 ORG_NAME,
		 OSSD,
		 POLICE_CHECK,
		 POSITION_TITLE,
		 PUBLIC_COMMENTS,
		 REQUEST_DATE,
		 SCHEDULE_GRID,
		 SCHEDULE_NOTES,
		 SEASONS,
		 SOCIAL_MEDIA,
		 SOURCE_EMAIL,
		 SOURCE_FAX,
		 SOURCE_NAME,
		 SOURCE_PUBLICATION_DATE,
		 SOURCE_ORG,
		 SOURCE_PHONE,
		 SOURCE_PUBLICATION,
		 SOURCE_TITLE,
		 SKILLS,
		 START_DATE_FIRST,
		 START_DATE_LAST,
		 SUITABILITY,
		 TRAINING,
		 TRANSPORTATION,
		 UPDATE_EMAIL,
		 VNUM
		)
SELECT 
		@MemberID AS MemberID,
		 N.value('FEEDBACK_OWNER[1]', 'nvarchar(100)') AS FEEDBACK_OWNER,
		 N.value('LangID[1]', 'nvarchar(100)') AS LangID,
		 N.value('SUBMIT_DATE[1]', 'nvarchar(100)') AS SUBMIT_DATE,
		 N.value('IPAddress[1]', 'nvarchar(100)') AS IPAddress,
		(SELECT User_ID FROM GBL_Users WHERE UserUID=N.value('UserUID[1]', 'uniqueidentifier')) AS User_ID,
	   (SELECT vw.ViewType FROM VOL_View vw INNER JOIN VOL_View_Description vd ON vd.ViewType = vw.ViewType WHERE vw.MemberID=@MemberID AND LangID=0 AND ViewName=N.value('ViewName[1]', 'nvarchar(255)')) AS ViewType,
		 N.value('AccessURL[1]', 'nvarchar(100)') AS AccessURL,
		 N.value('FULL_UPDATE[1]', 'nvarchar(100)') AS FULL_UPDATE,
		 N.value('NO_CHANGES[1]', 'nvarchar(100)') AS NO_CHANGES,
		 N.value('REMOVE_RECORD[1]', 'nvarchar(100)') AS REMOVE_RECORD,
		 N.value('FB_NOTES[1]', 'nvarchar(100)') AS FB_NOTES,
		 N.value('FBKEY[1]', 'nvarchar(100)') AS FBKEY,
		 N.value('NUM[1]', 'nvarchar(100)') AS NUM,
		 N.value('ACCESSIBILITY[1]', 'nvarchar(100)') AS ACCESSIBILITY,
		 N.value('ADDITIONAL_REQUIREMENTS[1]', 'nvarchar(100)') AS ADDITIONAL_REQUIREMENTS,
		 N.value('APPLICATION_DEADLINE[1]', 'nvarchar(100)') AS APPLICATION_DEADLINE,
		 N.value('BENEFITS[1]', 'nvarchar(100)') AS BENEFITS,
		 N.value('CLIENTS[1]', 'nvarchar(100)') AS CLIENTS,
		 N.value('COMMITMENT_LENGTH[1]', 'nvarchar(100)') AS COMMITMENT_LENGTH,
		 N.value('CONTACT_NAME[1]', 'nvarchar(100)') AS CONTACT_NAME,
		 N.value('CONTACT_TITLE[1]', 'nvarchar(100)') AS CONTACT_TITLE,
		 N.value('CONTACT_ORG[1]', 'nvarchar(100)') AS CONTACT_ORG,
		 N.value('CONTACT_PHONE1[1]', 'nvarchar(100)') AS CONTACT_PHONE1,
		 N.value('CONTACT_PHONE2[1]', 'nvarchar(100)') AS CONTACT_PHONE2,
		 N.value('CONTACT_PHONE3[1]', 'nvarchar(100)') AS CONTACT_PHONE3,
		 N.value('CONTACT_FAX[1]', 'nvarchar(100)') AS CONTACT_FAX,
		 N.value('CONTACT_EMAIL[1]', 'nvarchar(100)') AS CONTACT_EMAIL,
		 N.value('COST[1]', 'nvarchar(100)') AS COST,
		 N.value('DISPLAY_UNTIL[1]', 'nvarchar(100)') AS DISPLAY_UNTIL,
		 N.value('DUTIES[1]', 'nvarchar(100)') AS DUTIES,
		 N.value('END_DATE[1]', 'nvarchar(100)') AS END_DATE,
		 N.value('EXTRA[1]', 'nvarchar(100)') AS EXTRA,
		 N.value('EXTRA_B[1]', 'nvarchar(100)') AS EXTRA_B,
		 N.value('INTERACTION_LEVEL[1]', 'nvarchar(100)') AS INTERACTION_LEVEL,
		 N.value('INTERESTS[1]', 'nvarchar(100)') AS INTERESTS,
		 N.value('INTERNAL_MEMO[1]', 'nvarchar(100)') AS INTERNAL_MEMO,
		 N.value('LOCATION[1]', 'nvarchar(100)') AS LOCATION,
		 N.value('LIABILITY_INSURANCE[1]', 'nvarchar(100)') AS LIABILITY_INSURANCE,
		 N.value('MAX_AGE[1]', 'nvarchar(100)') AS MAX_AGE,
		 N.value('MIN_AGE[1]', 'nvarchar(100)') AS MIN_AGE,
		 N.value('MINIMUM_HOURS[1]', 'nvarchar(100)') AS MINIMUM_HOURS,
		 N.value('MINIMUM_HOURS_PER[1]', 'nvarchar(100)') AS MINIMUM_HOURS_PER,
		 N.value('MORE_INFO_URL[1]', 'nvarchar(100)') AS MORE_INFO_URL,
		 N.value('NO_UPDATE_EMAIL[1]', 'nvarchar(100)') AS NO_UPDATE_EMAIL,
		 N.value('NON_PUBLIC[1]', 'nvarchar(100)') AS NON_PUBLIC,
		 N.value('NUM_NEEDED[1]', 'nvarchar(100)') AS NUM_NEEDED,
		 N.value('NUM_NEEDED_NOTES[1]', 'nvarchar(100)') AS NUM_NEEDED_NOTES,
		 N.value('NUM_NEEDED_TOTAL[1]', 'nvarchar(100)') AS NUM_NEEDED_TOTAL,
		 N.value('ORG_NAME[1]', 'nvarchar(100)') AS ORG_NAME,
		 N.value('OSSD[1]', 'nvarchar(100)') AS OSSD,
		 N.value('POLICE_CHECK[1]', 'nvarchar(100)') AS POLICE_CHECK,
		 N.value('POSITION_TITLE[1]', 'nvarchar(100)') AS POSITION_TITLE,
		 N.value('PUBLIC_COMMENTS[1]', 'nvarchar(100)') AS PUBLIC_COMMENTS,
		 N.value('REQUEST_DATE[1]', 'nvarchar(100)') AS REQUEST_DATE,
		 N.value('SCHEDULE_GRID[1]', 'nvarchar(100)') AS SCHEDULE_GRID,
		 N.value('SCHEDULE_NOTES[1]', 'nvarchar(100)') AS SCHEDULE_NOTES,
		 N.value('SEASONS[1]', 'nvarchar(100)') AS SEASONS,
		 N.value('SOCIAL_MEDIA[1]', 'nvarchar(100)') AS SOCIAL_MEDIA,
		 N.value('SOURCE_EMAIL[1]', 'nvarchar(100)') AS SOURCE_EMAIL,
		 N.value('SOURCE_FAX[1]', 'nvarchar(100)') AS SOURCE_FAX,
		 N.value('SOURCE_NAME[1]', 'nvarchar(100)') AS SOURCE_NAME,
		 N.value('SOURCE_PUBLICATION_DATE[1]', 'nvarchar(100)') AS SOURCE_PUBLICATION_DATE,
		 N.value('SOURCE_ORG[1]', 'nvarchar(100)') AS SOURCE_ORG,
		 N.value('SOURCE_PHONE[1]', 'nvarchar(100)') AS SOURCE_PHONE,
		 N.value('SOURCE_PUBLICATION[1]', 'nvarchar(100)') AS SOURCE_PUBLICATION,
		 N.value('SOURCE_TITLE[1]', 'nvarchar(100)') AS SOURCE_TITLE,
		 N.value('SKILLS[1]', 'nvarchar(100)') AS SKILLS,
		 N.value('START_DATE_FIRST[1]', 'nvarchar(100)') AS START_DATE_FIRST,
		 N.value('START_DATE_LAST[1]', 'nvarchar(100)') AS START_DATE_LAST,
		 N.value('SUITABILITY[1]', 'nvarchar(100)') AS SUITABILITY,
		 N.value('TRAINING[1]', 'nvarchar(100)') AS TRAINING,
		 N.value('TRANSPORTATION[1]', 'nvarchar(100)') AS TRANSPORTATION,
		 N.value('UPDATE_EMAIL[1]', 'nvarchar(100)') AS UPDATE_EMAIL,
		 N.value('VNUM[1]', 'nvarchar(100)') AS VNUM
FROM @xmlData.nodes('//Feedback') AS T(N)

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
*/
-- VOL Feedback

-- GBL PageMsg
/*
-- VERIFIED JAN 17, 2015
BEGIN TRY
	BEGIN TRANSACTION

SET @ObjectType='Page Message'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode
--SELECT @xmlData

DECLARE @OLDPageMessageID table (
	Old int,
	New int
)

MERGE INTO GBL_PageMsg dst
USING 
(
SELECT
		 N.value('PageMsgID[1]', 'int') AS PageMsgID,
		 N.value('CREATED_DATE[1]', 'smalldatetime') AS CREATED_DATE,
		 N.value('CREATED_BY[1]', 'varchar(50)') AS CREATED_BY,
		 N.value('MODIFIED_DATE[1]', 'smalldatetime') AS MODIFIED_DATE,
		 N.value('MODIFIED_BY[1]', 'varchar(50)') AS MODIFIED_BY,
		 @MemberID AS MemberID,
		 N.value('MsgTitle[1]', 'nvarchar(50)') AS MsgTitle,
		 N.value('LangID[1]', 'smallint') AS LangID,
		 N.value('PageMsg[1]', 'nvarchar(max)') AS PageMsg,
		 N.value('VisiblePrintMode[1]', 'bit') AS VisiblePrintMode,
		 N.value('Bottom[1]', 'bit') AS Bottom
FROM @xmlData.nodes('//PageMessage') AS T(N) ) AS src
	ON 0=1
WHEN NOT MATCHED THEN
	INSERT 
			(CREATED_DATE,
			 CREATED_BY,
			 MODIFIED_DATE,
			 MODIFIED_BY,
			 MemberID,
			 MsgTitle,
			 LangID,
			 PageMsg,
			 VisiblePrintMode,
			 Bottom
			)
		VALUES
			(
			 src.CREATED_DATE,
			 src.CREATED_BY,
			 src.MODIFIED_DATE,
			 src.MODIFIED_BY,
			 src.MemberID,
			 src.MsgTitle,
			 src.LangID,
			 src.PageMsg,
			 src.VisiblePrintMode,
			 src.Bottom
			)
	OUTPUT src.PageMsgID, Inserted.PageMsgID INTO @OLDPageMessageID
	;

--INSERT INTO @OLDPageMessageID
--		(Old, New)
--SELECT
--		 N.value('PageMsgID[1]', 'int') AS PageMsgID,
--		 N.value('PageMsgID[1]', 'int') + 100 AS PageMsgID
--FROM @xmlData.nodes('//PageMessage') AS T(N) 

INSERT INTO GBL_PageMsg_PageInfo
		(PageName, PageMsgID)
SELECT PageName, New
FROM (
SELECT

		 N.value('../../PageMsgID[1]', 'int') AS PageMsgID,
		 N.value('.', 'varchar(255)') AS PageName
FROM @xmlData.nodes('//PageMessage/PAGES/PageName') AS T(N) ) src
INNER JOIN @OLDPageMessageID ids
	ON src.PageMsgID=Old

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage nvarchar(4000);
    DECLARE @ErrorSeverity int;
    DECLARE @ErrorState int;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
*/

-- GBL PageMsg


/*
BEGIN TRY
	BEGIN TRANSACTION
INSERT INTO VOL_OP_AC
		(AC_ID, VNUM)
SELECT ac.AC_ID, VNUM FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/ACCESSIBILITY/CHK') AS T(N)
WHERE ie.MemberID=@MemberID
) src
INNER JOIN GBL_Accessibility_Name ac
	ON ac.Name=CASE WHEN src.Name = 'Unknown or Not Applicable' THEN 'Unknown' ELSE src.Name END AND ac.LangID=0
WHERE NOT EXISTS(SELECT * FROM VOL_OP_AC WHERE AC_ID=ac.AC_ID AND src.VNUM=VNUM)


INSERT INTO VOL_OP_AC_Notes
		(OP_AC_ID, LangID, Notes)
SELECT opac.OP_AC_ID, 0, Notes
FROM (
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name, N.value('@N', 'nvarchar(255)') AS Notes
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/ACCESSIBILITY/CHK[@N]') AS T(N)
WHERE ie.MemberID=@MemberID
) src
INNER JOIN GBL_Accessibility_Name ac
	ON ac.Name=CASE WHEN src.Name = 'Unknown or Not Applicable' THEN 'Unknown' ELSE src.Name END AND ac.LangID=0
INNER JOIN VOL_OP_AC opac
	ON ac.AC_ID=opac.AC_ID AND src.VNUM=opac.VNUM
WHERE NOT EXISTS(SELECT * FROM VOL_OP_AC_Notes WHERE OP_AC_ID=opac.OP_AC_ID AND LangID=0)

INSERT INTO VOL_OP_AI
		(AI_ID, VNUM)
SELECT ai.AI_ID, VNUM FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/INTERESTS/CHK') AS T(N)
WHERE ie.MemberID=@MemberID
) src
INNER JOIN VOL_Interest_Name ai
	ON ai.Name=src.Name AND ai.LangID=0
WHERE NOT EXISTS(SELECT * FROM VOL_OP_AI WHERE AI_ID=ai.AI_ID AND src.VNUM=VNUM)


INSERT INTO VOL_OP_CL
		(CL_ID, VNUM)
SELECT cl.CL_ID, VNUM FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/COMMITMENT_LENGTH/CHK') AS T(N)
WHERE ie.MemberID=@MemberID
) src
INNER JOIN VOL_CommitmentLength_Name cl
	ON cl.Name=src.Name AND cl.LangID=0
WHERE NOT EXISTS(SELECT * FROM VOL_OP_CL WHERE CL_ID=cl.CL_ID AND src.VNUM=VNUM)


INSERT INTO VOL_OP_CL_Notes
		(OP_CL_ID, LangID, Notes)
SELECT opcl.OP_CL_ID, 0, Notes FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name, N.value('@N', 'nvarchar(255)') AS Notes
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/COMMITMENT_LENGTH/CHK[@N]') AS T(N)
WHERE ie.MemberID=@MemberID
) src
INNER JOIN VOL_CommitmentLength_Name cl
	ON cl.Name=src.Name AND cl.LangID=0
INNER JOIN VOL_OP_CL opcl
	ON cl.CL_ID=opcl.CL_ID AND src.VNUM=opcl.VNUM
WHERE NOT EXISTS(SELECT * FROM VOL_OP_CL_Notes WHERE OP_CL_ID=opcl.OP_CL_ID AND LangID=0)


INSERT INTO VOL_OP_CM
		(CM_ID, NUM_NEEDED, VNUM)
SELECT cmn.CM_ID, NUM_NEEDED, VNUM FROM 
(
SELECT ed.VNUM, N.value('@NO_NEEDED', 'smallint') AS NUM_NEEDED, N.value('@V', 'nvarchar(255)') AS Name, N.value('@CTRY', 'nvarchar(255)') AS Country, N.value('@PRV', 'nvarchar(3)') AS Province
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/NUM_NEEDED/CM') AS T(N)
WHERE ie.MemberID=@MemberID
) src
LEFT JOIN GBL_Community_Name cmn
	ON cmn.Name=src.Name AND cmn.LangID=0 
WHERE NOT EXISTS(SELECT * FROM VOL_OP_CM WHERE CM_ID=cmn.CM_ID AND src.VNUM=VNUM)


INSERT INTO VOL_OP_CommunitySet
		(CommunitySetID, VNUM)
SELECT cs.CommunitySetID, VNUM FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/COMMUNITY_SETS/CHK') AS T(N)
WHERE ie.MemberID=@MemberID
) src
LEFT JOIN VOL_CommunitySet_Name cs
	ON cs.SetName=src.Name AND cs.LangID=0
WHERE NOT EXISTS(SELECT * FROM VOL_OP_CommunitySet WHERE CommunitySetID=cs.CommunitySetID AND src.VNUM=VNUM)


INSERT INTO VOL_OP_IL
		(IL_ID, VNUM)
SELECT il.IL_ID, VNUM FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/INTERACTION_LEVEL/CHK') AS T(N)
WHERE ie.MemberID=@MemberID
) src
LEFT JOIN VOL_InteractionLevel_Name il
	ON il.Name=src.Name AND il.LangID=0
WHERE NOT EXISTS(SELECT * FROM VOL_OP_IL WHERE IL_ID=il.IL_ID AND src.VNUM=VNUM)


INSERT INTO VOL_OP_IL_Notes
		(OP_IL_ID, LangID, Notes)
SELECT opil.OP_IL_ID, 0, Notes FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name, N.value('@N', 'nvarchar(255)') AS Notes
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/INTERACTION_LEVEL/CHK[@N]') AS T(N)
WHERE ie.MemberID=@MemberID
) src
INNER JOIN VOL_InteractionLevel_Name il
	ON il.Name=src.Name AND il.LangID=0
INNER JOIN VOL_OP_IL opil
	ON il.IL_ID=opil.IL_ID AND src.VNUM=opil.VNUM
WHERE NOT EXISTS(SELECT * FROM VOL_OP_IL_Notes WHERE OP_IL_ID=opil.OP_IL_ID AND LangID=0)


INSERT INTO VOL_OP_SB
		(SB_ID, VNUM)
SELECT sb.SB_ID, VNUM FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/SUITABILITY/CHK') AS T(N)
WHERE ie.MemberID=@MemberID
) src
LEFT JOIN VOL_Suitability_Name sb
	ON sb.Name=CASE WHEN src.Name = 'Corporate Groups' THEN 'Workplaces / Corporate Groups' ELSE src.NAME END AND sb.LangID=0
WHERE NOT EXISTS(SELECT * FROM VOL_OP_SB WHERE SB_ID=sb.SB_ID AND src.VNUM=VNUM)

INSERT INTO VOL_OP_SB_Notes
		(OP_SB_ID, LangID, Notes)
SELECT opsb.OP_SB_ID, 0, Notes FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name, N.value('@N', 'nvarchar(255)') AS Notes
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/SUITABIILTY/CHK[@N]') AS T(N)
WHERE ie.MemberID=@MemberID
) src
INNER JOIN VOL_Suitability_Name sb
	ON sb.Name=CASE WHEN src.Name = 'Corporate Groups' THEN 'Workplaces / Corporate Groups' ELSE src.NAME END AND sb.LangID=0
INNER JOIN VOL_OP_SB opsb
	ON sb.SB_ID=opsb.SB_ID AND src.VNUM=opsb.VNUM
WHERE NOT EXISTS(SELECT * FROM VOL_OP_SB_Notes WHERE OP_SB_ID=opsb.OP_SB_ID AND LangID=0)

INSERT INTO VOL_OP_SK
		(SK_ID, VNUM)
SELECT sk.SK_ID, VNUM FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/SKILLS/CHK') AS T(N)
WHERE ie.MemberID=@MemberID
) src
LEFT JOIN VOL_Skill_Name sk
	ON sk.Name= src.NAME AND sk.LangID=0
WHERE NOT EXISTS(SELECT * FROM VOL_OP_SK WHERE SK_ID=sk.SK_ID AND src.VNUM=VNUM)

INSERT INTO VOL_OP_SK_Notes
		(OP_SK_ID, LangID, Notes)
SELECT opsk.OP_SK_ID, 0, Notes FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name, N.value('@N', 'nvarchar(255)') AS Notes
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/SUITABIILTY/CHK[@N]') AS T(N)
WHERE ie.MemberID=@MemberID
) src
INNER JOIN VOL_Skill_Name sk
	ON sk.Name=src.Name AND sk.LangID=0
INNER JOIN VOL_OP_SK opsk
	ON sk.SK_ID=opsk.SK_ID AND src.VNUM=opsk.VNUM
WHERE NOT EXISTS(SELECT * FROM VOL_OP_SK_Notes WHERE OP_SK_ID=opsk.OP_SK_ID AND LangID=0)

INSERT INTO VOL_OP_SSN
		(SSN_ID, VNUM)
SELECT ssn.SSN_ID, VNUM FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/SEASONS/CHK') AS T(N)
WHERE ie.MemberID=@MemberID
) src
LEFT JOIN VOL_Seasons_Name ssn
	ON ssn.Name= src.NAME AND ssn.LangID=0
WHERE NOT EXISTS(SELECT * FROM VOL_OP_SSN WHERE SSN_ID=ssn.SSN_ID AND src.VNUM=VNUM)

INSERT INTO VOL_OP_SSN_Notes
		(OP_SSN_ID, LangID, Notes)
SELECT opssn.OP_SSN_ID, 0, Notes FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name, N.value('@N', 'nvarchar(255)') AS Notes
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/SEASONS/CHK[@N]') AS T(N)
WHERE ie.MemberID=@MemberID
) src
INNER JOIN VOL_Seasons_Name ssn
	ON ssn.Name=src.Name AND ssn.LangID=0
INNER JOIN VOL_OP_SSN opssn
	ON ssn.SSN_ID=opssn.SSN_ID AND src.VNUM=opssn.VNUM
WHERE NOT EXISTS(SELECT * FROM VOL_OP_SSN_Notes WHERE OP_SSN_ID=opssn.OP_SSN_ID AND LangID=0)

INSERT INTO VOL_OP_TRN
		(TRN_ID, VNUM)
SELECT trn.TRN_ID, VNUM FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/TRAINING/CHK') AS T(N)
WHERE ie.MemberID=@MemberID
) src
LEFT JOIN VOL_Training_Name trn
	ON trn.Name= src.NAME AND trn.LangID=0
WHERE NOT EXISTS(SELECT * FROM VOL_OP_TRN WHERE TRN_ID=trn.TRN_ID AND src.VNUM=VNUM)

INSERT INTO VOL_OP_TRN_Notes
		(OP_TRN_ID, LangID, Notes)
SELECT optrn.OP_TRN_ID, 0, Notes FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name, N.value('@N', 'nvarchar(255)') AS Notes
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/TRAINING/CHK[@N]') AS T(N)
WHERE ie.MemberID=@MemberID
) src
INNER JOIN VOL_Training_Name trn
	ON trn.Name=src.Name AND trn.LangID=0
INNER JOIN VOL_OP_TRN optrn
	ON trn.TRN_ID=optrn.TRN_ID AND src.VNUM=optrn.VNUM
WHERE NOT EXISTS(SELECT * FROM VOL_OP_TRN_Notes WHERE OP_TRN_ID=optrn.OP_TRN_ID AND LangID=0)


INSERT INTO VOL_OP_TRP
		(TRP_ID, VNUM)
SELECT trp.TRP_ID, VNUM FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/TRANSPORTATION/CHK') AS T(N)
WHERE ie.MemberID=@MemberID
) src
LEFT JOIN VOL_Transportation_Name trp
	ON trp.Name= src.NAME AND trp.LangID=0
WHERE NOT EXISTS(SELECT * FROM VOL_OP_TRP WHERE TRP_ID=trp.TRP_ID AND src.VNUM=VNUM)

INSERT INTO VOL_OP_TRP_Notes
		(OP_TRP_ID, LangID, Notes)
SELECT optrp.OP_TRP_ID, 0, Notes FROM 
(
SELECT ed.VNUM, N.value('@V', 'nvarchar(255)') AS Name, N.value('@N', 'nvarchar(255)') AS Notes
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/TRANSPORTATION/CHK[@N]') AS T(N)
WHERE ie.MemberID=@MemberID
) src
INNER JOIN VOL_Transportation_Name trp
	ON trp.Name=src.Name AND trp.LangID=0
INNER JOIN VOL_OP_TRP optrp
	ON trp.TRP_ID=optrp.TRP_ID AND src.VNUM=optrp.VNUM
WHERE NOT EXISTS(SELECT * FROM VOL_OP_TRP_Notes WHERE OP_TRP_ID=optrp.OP_TRP_ID AND LangID=0)


INSERT INTO GBL_Contact
		(
		 LangID,
		 VolContactType,
		 NAME_HONORIFIC,
		 NAME_FIRST,
		 NAME_LAST,
		 NAME_SUFFIX,
		 TITLE,
		 ORG,
		 EMAIL,
		 FAX_NOTE,
		 FAX_NO,
		 FAX_EXT,
		 FAX_CALLFIRST,
		 PHONE_1_TYPE,
		 PHONE_1_NOTE,
		 PHONE_1_NO,
		 PHONE_1_EXT,
		 PHONE_1_OPTION,
		 PHONE_2_TYPE,
		 PHONE_2_NOTE,
		 PHONE_2_NO,
		 PHONE_2_EXT,
		 PHONE_2_OPTION,
		 PHONE_3_TYPE,
		 PHONE_3_NOTE,
		 PHONE_3_NO,
		 PHONE_3_EXT,
		 PHONE_3_OPTION,
		 VolVNUM,
		 VolOPDID
		)
SELECT src.*, OPD_ID
FROM
(SELECT 
				CASE WHEN N.value('@LANG', 'char(1)') = 'F' THEN 2 ELSE 0 END AS LangID,
				'CONTACT' AS VolContactType,
				N.value('@NMH', 'nvarchar(20)') AS NAME_HONORIFIC,
				N.value('@NMFIRST', 'nvarchar(60)') AS NAME_FIRST,
				N.value('@NMLAST', 'nvarchar(100)') AS NAME_LAST,
				N.value('@NMS', 'nvarchar(30)') AS NAME_SUFFIX,
				N.value('@TTL', 'nvarchar(100)') AS TITLE,
				N.value('@ORG', 'nvarchar(100)') AS ORG,
				N.value('@EML', 'nvarchar(60)') AS EMAIL,
				N.value('@FAXN', 'nvarchar(100)') AS FAX_NOTE,
				N.value('@FAXNO', 'nvarchar(20)') AS FAX_NO,
				N.value('@FAXEXT', 'nvarchar(10)') AS FAX_EXT,
				ISNULL(N.value('@FAXCALL', 'bit'), 0) AS FAX_CALLFIRST,
				N.value('@PH1TYPE', 'nvarchar(20)') AS PHONE_1_TYPE,	
				N.value('@PH1N', 'nvarchar(100)') AS PHONE_1_NOTE,
				N.value('@PH1NO', 'nvarchar(20)') AS PHONE_1_NO,
				N.value('@PH1EXT', 'nvarchar(10)') AS PHONE_1_EXT,
				N.value('@PH1OPT', 'nvarchar(10)') AS PHONE_1_OPTION,
				N.value('@PH2TYPE', 'nvarchar(20)') AS PHONE_2_TYPE,	
				N.value('@PH2N', 'nvarchar(100)') AS PHONE_2_NOTE,
				N.value('@PH2NO', 'nvarchar(20)') AS PHONE_2_NO,
				N.value('@PH2EXT', 'nvarchar(10)') AS PHONE_2_EXT,
				N.value('@PH2OPT', 'nvarchar(10)') AS PHONE_2_OPTION,
				N.value('@PH3TYPE', 'nvarchar(20)') AS PHONE_3_TYPE,	
				N.value('@PH3N', 'nvarchar(100)') AS PHONE_3_NOTE,
				N.value('@PH3NO', 'nvarchar(20)') AS PHONE_3_NO,
				N.value('@PH3EXT', 'nvarchar(10)') AS PHONE_3_EXT,
				N.value('@PH3OPT', 'nvarchar(10)') AS PHONE_3_OPTION,
				ed.VNUM
FROM VOL_ImportEntry_Data ed 
INNER JOIN VOL_ImportEntry ie 
	ON ie.EF_ID = ed.EF_ID 
CROSS APPLY ed.DATA.nodes('/RECORD/CONTACT/CONTACT') AS T(N)
WHERE ie.MemberID=@MemberID
) src
LEFT JOIN VOL_Opportunity_Description opd
	ON src.VNUM=opd.VNUM AND src.LangID=opd.LangID
WHERE COALESCE(NAME_FIRST,NAME_LAST,NAME_SUFFIX, 
				TITLE,ORG,EMAIL,
				FAX_NOTE,FAX_NO,FAX_EXT,
				PHONE_1_TYPE,PHONE_1_NOTE,PHONE_1_NO,PHONE_1_EXT,PHONE_1_OPTION,
				PHONE_2_TYPE,PHONE_2_NOTE,PHONE_2_NO,PHONE_2_EXT,PHONE_2_OPTION,
				PHONE_3_TYPE,PHONE_3_NOTE,PHONE_3_NO,PHONE_3_EXT,PHONE_3_OPTION) IS NOT NULL
AND NOT EXISTS(SELECT * FROM GBL_Contact WHERE VolVNUM=src.VNUM AND VolContactType=src.VolContactType AND LangiD=src.LangID)

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRAN
	END

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	SET @ErrorMessage = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState = ERROR_STATE();
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
*/



/*
SET @ObjectType='CIC View'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @ViewType int, @ViewName nvarchar(255), @NewViewType int

UPDATE vwd SET SearchTips=src.SearchTips, InclusionPolicy=src.InclusionPolicy
FROM CIC_View_Description vwd
INNER JOIN (
SELECT
	(SELECT TOP 1 vw.ViewType FROM CIC_View_Description vwd INNER JOIN CIC_View vw ON vw.ViewType = vwd.ViewType WHERE ViewName=N.value('../Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)') AND LangID=0 AND MemberID=@MemberID) AS ViewType,
	N.value('LangID[1]', 'smallint') AS LangID,
	(SELECT SearchTipsID FROM dbo.GBL_SearchTips WHERE MemberID=@MemberID AND PageTitle=N.value('SearchTipsName[1]', 'nvarchar(255)')) AS SearchTips,
	(SELECT InclusionPolicyID FROM dbo.GBL_InclusionPolicy WHERE MemberID=@MemberID AND PolicyTitle=N.value('InclusionPolicyName[1]', 'nvarchar(255)')) AS InclusionPolicy
FROM @xmlData.nodes('//View/Descriptions/Lang') AS T(N)
) src
	ON vwd.ViewType=src.ViewType AND vwd.LangID=src.LangID
*/

/*
SET @ObjectType='VOL View'

SELECT @xmlData=Data FROM cioc_data_loader.dbo.MultiObjectLoader
WHERE ObjectType=@ObjectType AND LoadCode=@LoadCode

DECLARE @ViewType int, @ViewName nvarchar(255), @NewViewType int

UPDATE vwd SET SearchTips=src.SearchTips
--SELECT src.*
FROM VOL_View_Description vwd
INNER JOIN (
SELECT
	(SELECT TOP 1 vw.ViewType FROM VOL_View_Description vwd INNER JOIN VOL_View vw ON vw.ViewType = vwd.ViewType WHERE ViewName=N.value('../Lang[LangID=0][1]/ViewName[1]', 'nvarchar(255)') AND LangID=0 AND MemberID=@MemberID) AS ViewType,
	N.value('LangID[1]', 'smallint') AS LangID,
	(SELECT SearchTipsID FROM dbo.GBL_SearchTips WHERE MemberID=@MemberID AND PageTitle=N.value('SearchTipsName[1]', 'nvarchar(255)')) AS SearchTips,
	(SELECT InclusionPolicyID FROM dbo.GBL_InclusionPolicy WHERE MemberID=@MemberID AND PolicyTitle=N.value('InclusionPolicyName[1]', 'nvarchar(255)')) AS InclusionPolicy
FROM @xmlData.nodes('//View/Descriptions/Lang') AS T(N)

) src
	ON vwd.ViewType=src.ViewType AND vwd.LangID=src.LangID
*/
