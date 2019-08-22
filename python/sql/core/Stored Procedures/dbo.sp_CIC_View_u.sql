SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_View_u]
	@ViewType INT,
	@MODIFIED_BY VARCHAR(50),
	@MemberID INT,
	@AgencyCode CHAR(3),
	@Owner CHAR(3),
	@CanSeeNonPublic BIT,
	@CanSeeDeleted BIT,
	@HidePastDueBy SMALLINT,
	@AlertColumn BIT,
	@Template INT,
	@PrintTemplate INT,
	@PrintVersionResults BIT,
	@DataMgmtFields BIT,
	@LastModifiedDate BIT,
	@SocialMediaShare BIT,
	@CommSrchWrapAt TINYINT,
	@ASrchAges BIT,
	@ASrchBool BIT,
	@ASrchEmail BIT,
	@ASrchLastRequest BIT,
	@ASrchOwner BIT,
	@BSrchAutoComplete BIT,
	@BSrchBrowseByOrg BIT,
	@BSrchKeywords BIT,
	@DataUseAuth BIT,
	@DataUseAuthPhone BIT,
	@MyList BIT,
	@ViewOtherLangs BIT,
	@AllowFeedbackNotInView BIT,
	@AssignSuggestionsTo VARCHAR(3),
	@AllowPDF BIT,
	@CommSrchDropDown BIT,
	@OtherCommunity BIT,
	@RespectPrivacyProfile BIT,
	@PB_ID INT,
	@LimitedView BIT,
	@VolunteerLink BIT,
	@SrchCommunityDefault BIT,
	@ASrchAddress BIT,
	@ASrchEmployee BIT,
	@ASrchNear BIT,
	@ASrchVacancy BIT,
	@ASrchVOL BIT,
	@BSrchAges BIT,
	@BSrchLanguage BIT,
	@BSrchNUM BIT,
	@BSrchOCG BIT,
	@BSrchVacancy BIT,
	@BSrchVOL BIT,
	@BSrchWWW BIT,
	@BSrchDefaultTab TINYINT,
	@BSrchNear2 BIT,
	@BSrchNear5 BIT,
	@BSrchNear10 BIT,
	@BSrchNear15 BIT,
	@BSrchNear25 BIT,
	@BSrchNear50 BIT,
	@BSrchNear100 BIT,
	@CSrch BIT,
	@CSrchBusRoute BIT,
	@CSrchKeywords BIT,
	@CSrchLanguages BIT,
	@CSrchNear BIT,
	@CSrchSchoolEscort BIT,
	@CSrchSchoolsInArea BIT,
	@CSrchSpaceAvailable BIT,
	@CSrchSubsidy BIT,
	@CSrchTypeOfProgram BIT,
	@CCRFields BIT,
	@QuickListDropDown TINYINT,
	@QuickListWrapAt TINYINT,
	@QuickListMatchAll BIT,
	@QuickListSearchGroups BIT,
	@QuickListPubHeadings INT,
	@LinkOrgLevels BIT,
	@CanSeeNonPublicPub BIT,
	@UsePubNamesOnly BIT,
	@UseNAICSView BIT,
	@UseTaxonomyView BIT,
	@TaxDefnLevel TINYINT,
	@UseThesaurusView BIT,
	@UseLocalSubjects BIT,
	@UseZeroSubjects BIT,
	@AlsoNotify VARCHAR(60),
	@NoProcessNotify BIT,
	@UseSubmitChangesTo BIT,
	@MapSearchResults BIT,
	@AutoMapSearchResults BIT,
	@ResultsPageSize SMALLINT,
	@ShowID BIT,
	@ShowOwner BIT,
	@ShowAlert BIT,
	@ShowOrg BIT,
	@ShowCommunity BIT,
	@ShowUpdateSchedule BIT,
	@LinkUpdate BIT,
	@LinkEmail BIT,
	@LinkSelect BIT,
	@LinkWeb BIT,
	@LinkListAdd BIT,
	@OrderBy INT,
	@OrderByCustom INT,
	@OrderByDesc BIT,
    @TableSort BIT,
	@GLinkMail BIT,
	@GLinkPub BIT,
	@ShowTable BIT,
	@VShowPosition BIT,
	@VShowDuties BIT,
	@ShowRecordDetailsSidebar BIT,
	@GoogleTranslateWidget BIT,
	@DefaultPrintProfile INT,
	@RefineField1 INT,
	@RefineField2 INT,
	@RefineField3 INT,
	@RefineField4 INT,
	@Descriptions XML,
	@Views XML,
	@AdvSrchCheckLists XML,
	@Publications XML,
	@AddPublications XML,
	@DisplayOptFields VARCHAR(MAX),
	@ErrMsg NVARCHAR(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 04-May-2016
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@FieldObjectName nvarchar(100),
		@TemplateObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100),
		@PrintProfileObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')
SET @TemplateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Design Template')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')
SET @PrintProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Print Profile')

DECLARE @DescTable table (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	ViewName nvarchar(100) NOT NULL,
	Notes nvarchar(MAX) NULL,
	Title nvarchar(255) NULL,
	BottomMessage nvarchar(MAX) NULL,
	MenuMessage nvarchar(MAX) NULL,
	MenuTitle nvarchar(100) NULL,
	MenuGlyph varchar(30) NULL,
	CSrchText nvarchar(255) NULL,
	QuickListName nvarchar(25) NULL,
	FeedbackBlurb nvarchar(MAX) NULL,
	TermsOfUseURL varchar(200) NULL,
	InclusionPolicy int NULL,
	SearchTips int NULL,
	SearchLeftTitle nvarchar(100) NULL,
	SearchLeftMessage nvarchar(MAX) NULL,
	SearchLeftGlyph varchar(30) NULL,
	SearchCentreTitle nvarchar(100) NULL,
	SearchCentreMessage nvarchar(MAX) NULL,
	SearchCentreGlyph varchar(30) NULL,
	SearchRightTitle nvarchar(100) NULL,
	SearchRightGlyph varchar(30) NULL,
	SearchRightMessage nvarchar(MAX) NULL,
	SearchAlertTitle nvarchar(100) NULL,
	SearchAlertGlyph varchar(30) NULL,
	SearchAlertMessage nvarchar(MAX) NULL,
	KeywordSearchTitle nvarchar(100) NULL,
	KeywordSearchGlyph varchar(30) NULL,
	OtherSearchTitle nvarchar(100) NULL,
	OtherSearchGlyph varchar(30) NULL,
	SearchTitleOverride nvarchar(255) NULL,
	OrganizationNames nvarchar(100) NULL,
	OrganizationsWithWWW nvarchar(100) NULL,
	OrganizationsWithVolOps nvarchar(100) NULL,
	BrowseByOrg nvarchar(100) NULL,
	FindAnOrgBy nvarchar(100) NULL,
	ViewProgramsAndServices nvarchar(100) NULL,
	ClickToViewDetails nvarchar(100) NULL,
	OrgProgramNames nvarchar(100) NULL,
	Organization nvarchar(100) NULL,
	MultipleOrgWithSimilarMap nvarchar(100) NULL,
	OrgLevel1Name nvarchar(100) NULL,
	OrgLevel2Name nvarchar(100) NULL,
	OrgLevel3Name nvarchar(100) NULL,
	QuickSearchTitle nvarchar(100) NULL,
	QuickSearchGlyph varchar(30) NULL,
	PDFBottomMessage nvarchar(MAX) NULL,
	PDFBottomMargin varchar(20) NULL,
	GoogleTranslateDisclaimer nvarchar(1000) NULL,
	TagLine nvarchar(300) NULL,
	NoResultsMsg nvarchar(2000) NULL
)

DECLARE @ViewTable table (
	ViewType int NOT NULL
)

DECLARE @AdvSrchChkTable table (
	FieldID int NOT NULL
)

DECLARE @PublicationTable table (
	PB_ID int NOT NULL
)

DECLARE @AddPublicationTable table (
	PB_ID int NOT NULL
)

DECLARE @UsedNamesDesc nvarchar(MAX),
		@BadCulturesDesc nvarchar(MAX)

INSERT INTO @DescTable (
	Culture,
	LangID,
	ViewName,
	Notes,
	Title,
	BottomMessage,
	MenuMessage,
	MenuTitle,
	MenuGlyph,
	CSrchText,
	QuickListName,
	FeedbackBlurb,
	TermsOfUseURL,
	InclusionPolicy,
	SearchTips,
	SearchLeftTitle,
	SearchLeftGlyph,
	SearchLeftMessage,
	SearchCentreTitle,
	SearchCentreGlyph,
	SearchCentreMessage,
	SearchRightTitle,
	SearchRightGlyph,
	SearchRightMessage,
	SearchAlertTitle,
	SearchAlertGlyph,
	SearchAlertMessage,
	KeywordSearchTitle,
	KeywordSearchGlyph,
	OtherSearchTitle,
	OtherSearchGlyph,
	SearchTitleOverride,
	OrganizationNames,
	OrganizationsWithWWW,
	OrganizationsWithVolOps,
	BrowseByOrg,
	FindAnOrgBy,
	ViewProgramsAndServices,
	ClickToViewDetails,
	OrgProgramNames,
	Organization,
	MultipleOrgWithSimilarMap,
	OrgLevel1Name,
	OrgLevel2Name,
	OrgLevel3Name,
	QuickSearchTitle,
	QuickSearchGlyph,
	PDFBottomMessage,
	PDFBottomMargin,
	GoogleTranslateDisclaimer,
	TagLine,
	NoResultsMsg
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('ViewName[1]', 'nvarchar(100)') AS ViewName,
	N.value('Notes[1]', 'nvarchar(max)') AS Notes,
	N.value('Title[1]', 'nvarchar(255)') AS Title,
	N.value('BottomMessage[1]', 'nvarchar(max)') AS BottomMessage,
	N.value('MenuMessage[1]', 'nvarchar(max)') AS MenuMessage,
	N.value('MenuTitle[1]', 'nvarchar(100)') AS MenuTitle,
	N.value('MenuGlyph[1]', 'nvarchar(30)') AS MenuGlyph,
	N.value('CSrchText[1]', 'nvarchar(255)') AS CSrchText,
	N.value('QuickListName[1]', 'nvarchar(25)') AS QuickListName,
	N.value('FeedbackBlurb[1]', 'nvarchar(2000)') AS FeedbackBlurb,
	N.value('TermsOfUseURL[1]', 'varchar(200)') AS TermsOfUseURL,
	(SELECT InclusionPolicyID FROM GBL_InclusionPolicy WHERE MemberID=@MemberID AND InclusionPolicyID=N.value('InclusionPolicy[1]', 'int')) AS InclusionPolicy,
	(SELECT SearchTipsID
		FROM GBL_SearchTips
		WHERE MemberID=@MemberID AND Domain=1 AND SearchTipsID=N.value('SearchTips[1]', 'int')
			AND LangID=(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1)
		) AS SearchTips,
	N.value('SearchLeftTitle[1]', 'nvarchar(100)') AS SearchLeftTitle,
	N.value('SearchLeftGlyph[1]', 'nvarchar(30)') AS SearchLeftGlyph,
	N.value('SearchLeftMessage[1]', 'nvarchar(max)') AS SearchLeftMessage,
	N.value('SearchCentreTitle[1]', 'nvarchar(100)') AS SearchCentreTitle,
	N.value('SearchCentreGlyph[1]', 'nvarchar(30)') AS SearchCentreGlyph,
	N.value('SearchCentreMessage[1]', 'nvarchar(max)') AS SearchCentreMessage,
	N.value('SearchRightTitle[1]', 'nvarchar(100)') AS SearchRightTitle,
	N.value('SearchRightGlyph[1]', 'nvarchar(30)') AS SearchRightGlyph,
	N.value('SearchRightMessage[1]', 'nvarchar(max)') AS SearchRightMessage,
	N.value('SearchAlertTitle[1]', 'nvarchar(100)') AS SearchAlertTitle,
	N.value('SearchAlertGlyph[1]', 'nvarchar(30)') AS SearchAlertGlyph,
	N.value('SearchAlertMessage[1]', 'nvarchar(max)') AS SearchAlertMessage,
	N.value('KeywordSearchTitle[1]', 'nvarchar(100)') AS KeywordSearchTitle,
	N.value('KeywordSearchGlyph[1]', 'nvarchar(30)') AS KeywordSearchGlyph,
	N.value('OtherSearchTitle[1]', 'nvarchar(100)') AS OtherSearchTitle,
	N.value('OtherSearchGlyph[1]', 'nvarchar(30)') AS OtherSearchGlyph,
	N.value('SearchTitleOverride[1]', 'nvarchar(255)') AS SearchTitleOverride,
    N.value('OrganizationNames[1]', 'nvarchar(100)') AS OrganizationNames,
    N.value('OrganizationsWithWWW[1]', 'nvarchar(100)') AS OrganizationsWithWWW,
    N.value('OrganizationsWithVolOps[1]', 'nvarchar(100)') AS OrganizationsWithVolOps,
    N.value('BrowseByOrg[1]', 'nvarchar(100)') AS BrowseByOrg,
    N.value('FindAnOrgBy[1]', 'nvarchar(100)') AS FindAnOrgBy,
    N.value('ViewProgramsAndServices[1]', 'nvarchar(100)') AS ViewProgramsAndServices,
    N.value('ClickToViewDetails[1]', 'nvarchar(100)') AS ClickToViewDetails,
    N.value('OrgProgramNames[1]', 'nvarchar(100)') AS OrgProgramNames,
    N.value('Organization[1]', 'nvarchar(100)') AS Organization,
    N.value('MultipleOrgWithSimilarMap[1]', 'nvarchar(100)') AS MultipleOrgWithSimilarMap,
	N.value('OrgLevel1Name[1]', 'nvarchar(100)') AS OrgLevel1Name,
	N.value('OrgLevel2Name[1]', 'nvarchar(100)') AS OrgLevel2Name,
	N.value('OrgLevel3Name[1]', 'nvarchar(100)') AS OrgLevel3Name,
	N.value('QuickSearchTitle[1]', 'nvarchar(100)') AS QuickSearchTitle,
	N.value('QuickSearchGlyph[1]', 'nvarchar(30)') AS QuickSearchGlyph,
	N.value('PDFBottomMessage[1]', 'nvarchar(MAX)') AS PDFBottomMessage,
	N.value('PDFBottomMargin[1]', 'varchar(20)') AS PDFBottomMargin,
	N.value('GoogleTranslateDisclaimer[1]', 'nvarchar(1000)') AS GoogleTranslateDisclaimer,
	N.value('TagLine[1]', 'nvarchar(300)') AS TagLine,
	N.value('NoResultsMsg[1]', 'nvarchar(2000)') AS NoResultsMsg
FROM @Descriptions.nodes('//DESC') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg

UPDATE @DescTable
	SET  MenuGlyph = CASE WHEN EXISTS(SELECT * FROM STP_Icon WHERE IconName=MenuGlyph AND Type='glyphicon') THEN MenuGlyph ELSE NULL END,
		SearchLeftGlyph = CASE WHEN EXISTS(SELECT * FROM STP_Icon WHERE IconName=SearchLeftGlyph AND Type='glyphicon') THEN SearchLeftGlyph ELSE NULL END,
		SearchRightGlyph = CASE WHEN EXISTS(SELECT * FROM STP_Icon WHERE IconName=SearchRightGlyph AND Type='glyphicon') THEN SearchRightGlyph ELSE NULL END,
		SearchAlertGlyph = CASE WHEN EXISTS(SELECT * FROM STP_Icon WHERE IconName=SearchAlertGlyph AND Type='glyphicon') THEN SearchAlertGlyph ELSE NULL END,
		QuickSearchGlyph = CASE WHEN EXISTS(SELECT * FROM STP_Icon WHERE IconName=QuickSearchGlyph AND Type='glyphicon') THEN QuickSearchGlyph ELSE NULL END

INSERT INTO @ViewTable
	( ViewType )
SELECT 
	N.value('.', 'int') AS ViewType
FROM @Views.nodes('//VIEW') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg

INSERT INTO @AdvSrchChkTable(
	FieldID
)
SELECT
	N.value('.','int') AS FieldID	
FROM @AdvSrchCheckLists.nodes('//Chk') as T(N)
INNER JOIN GBL_FieldOption fo
	ON N.value('.','int')=fo.FieldID
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

INSERT INTO @PublicationTable(
	PB_ID
)
SELECT
	N.value('.','int') AS PB_ID	
FROM @Publications.nodes('//PBID') as T(N)
INNER JOIN CIC_Publication pb
	ON N.value('.','int')=pb.PB_ID
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg

INSERT INTO @AddPublicationTable(
	PB_ID
)
SELECT
	N.value('.','int') AS PB_ID	
FROM @AddPublications.nodes('//PBID') as T(N)
INNER JOIN CIC_Publication pb
	ON N.value('.','int')=pb.PB_ID
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg

SELECT @UsedNamesDesc = COALESCE(@UsedNamesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ViewName
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM CIC_View vw INNER JOIN CIC_View_Description vwd ON vw.ViewType=vwd.ViewType WHERE ViewName=nt.ViewName AND LangID=nt.LangID AND vw.ViewType<>@ViewType AND MemberID=@MemberID)

SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

IF NOT EXISTS(SELECT * FROM GBL_Agency WHERE AgencyCode=@AssignSuggestionsTo) BEGIN
	SET @AssignSuggestionsTo = NULL
END

IF @LimitedView=1 AND @PB_ID IS NOT NULL BEGIN
	SET @QuickListPubHeadings = NULL
END

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS VARCHAR), @MemberObjectName)
-- View given ?
END ELSE IF @ViewType IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- View exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS VARCHAR), @ViewObjectName)
-- View belongs to Member ?
END ELSE IF @ViewType IS NOT NULL AND NOT EXISTS (SELECT * FROM CIC_View WHERE MemberID=@MemberID AND ViewType=@ViewType) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- Template given ?

	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TemplateObjectName, @ViewObjectName)
-- Template exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Template WHERE Template_ID=@Template) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Template AS VARCHAR), @TemplateObjectName)
-- Template ownership OK?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Template
		WHERE Template_ID=@Template
			AND (MemberID IS NULL OR MemberID=@MemberID)
			AND (
				EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType AND Template=@Template)
				OR (Owner IS NULL OR Owner=@AgencyCode)
			)
		) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TemplateObjectName, NULL)
-- Print Template exists ?
END ELSE IF @PrintTemplate IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_Template WHERE Template_ID=@PrintTemplate) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PrintTemplate AS VARCHAR), @TemplateObjectName)
-- Print Template ownership OK?
END ELSE IF @PrintTemplate IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_Template
		WHERE Template_ID=@PrintTemplate
			AND (MemberID IS NULL OR MemberID=@MemberID)
			AND (
				EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType AND PrintTemplate=@PrintTemplate)
				OR (Owner IS NULL OR Owner=@AgencyCode)
			)
		) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TemplateObjectName, NULL)
-- Publication exists ?
END ELSE IF @PB_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_Publication pb WHERE pb.PB_ID=@PB_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PB_ID AS VARCHAR), @PublicationObjectName)
-- Publication belongs to Member ?
END ELSE IF @PB_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_Publication pb WHERE pb.PB_ID=@PB_ID AND pb.MemberID=@MemberID OR pb.MemberID IS NULL) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, NULL)
-- Publication exists ?
END ELSE IF @QuickListPubHeadings IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_Publication pb WHERE pb.PB_ID=@QuickListPubHeadings) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@QuickListPubHeadings AS VARCHAR), @PublicationObjectName)
-- Publication belongs to Member ?
END ELSE IF @QuickListPubHeadings IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_Publication pb WHERE pb.PB_ID=@QuickListPubHeadings AND pb.MemberID=@MemberID OR pb.MemberID IS NULL) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, NULL)
-- Print Profile Exists ?
END ELSE IF @DefaultPrintProfile IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_PrintProfile pp WHERE pp.ProfileID=@DefaultPrintProfile AND pp.Domain=1) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@DefaultPrintProfile AS VARCHAR), @PrintProfileObjectName)
-- Print Profile belongs to Member ?
END ELSE IF @DefaultPrintProfile IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_PrintProfile pp WHERE pp.ProfileID=@DefaultPrintProfile AND pp.Domain=1 AND pp.MemberID=@MemberID OR pp.MemberID IS NULL) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PrintProfileObjectName, NULL)
-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @ViewObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE ViewName IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @ViewObjectName)
-- Name in use ?
END ELSE IF @UsedNamesDesc IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNamesDesc, @NameObjectName)
-- Invalid language ?
END ELSE IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	UPDATE CIC_View
	SET	MODIFIED_DATE			= GETDATE(),
		MODIFIED_BY				= @MODIFIED_BY,
		Owner					= @Owner,
		CanSeeNonPublic			= ISNULL(@CanSeeNonPublic,CanSeeNonPublic),
		CanSeeDeleted			= ISNULL(@CanSeeDeleted,CanSeeDeleted),
		HidePastDueBy			= @HidePastDueBy,
		AlertColumn				= ISNULL(@AlertColumn,AlertColumn),
		Template				= @Template,
		PrintTemplate			= @PrintTemplate,
		PrintVersionResults		= ISNULL(@PrintVersionResults,PrintVersionResults),
		DataMgmtFields			= ISNULL(@DataMgmtFields,DataMgmtFields),
		LastModifiedDate		= ISNULL(@LastModifiedDate,LastModifiedDate),
		SocialMediaShare		= ISNULL(@SocialMediaShare,SocialMediaShare),
		CommSrchWrapAt			= ISNULL(@CommSrchWrapAt,2),
		ASrchAges				= ISNULL(@ASrchAges,ASrchAges),
		ASrchBool				= ISNULL(@ASrchBool,ASrchBool),
		ASrchEmail				= ISNULL(@ASrchEmail,ASrchEmail),
		ASrchLastRequest		= ISNULL(@ASrchLastRequest,ASrchLastRequest),
		ASrchOwner				= ISNULL(@ASrchOwner,ASrchOwner),
		BSrchAutoComplete		= ISNULL(@BSrchAutoComplete,BSrchAutoComplete),
		BSrchBrowseByOrg		= ISNULL(@BSrchBrowseByOrg,BSrchBrowseByOrg),
		BSrchKeywords			= ISNULL(@BSrchKeywords,BSrchKeywords),
		DataUseAuth				= ISNULL(@DataUseAuth,DataUseAuth),
		DataUseAuthPhone		= ISNULL(@DataUseAuthPhone,DataUseAuthPhone),
		MyList					= ISNULL(@MyList,MyList),
		ViewOtherLangs			= ISNULL(@ViewOtherLangs,ViewOtherLangs),
		AllowFeedbackNotInView	= ISNULL(@AllowFeedbackNotInView,AllowFeedbackNotInView),
		AssignSuggestionsTo		= @AssignSuggestionsTo,
		AllowPDF				= ISNULL(@AllowPDF, AllowPDF),
		GoogleTranslateWidget	= ISNULL(@GoogleTranslateWidget,GoogleTranslateWidget),
		DefaultPrintProfile		= @DefaultPrintProfile,

		-- CIC-only fields
		CommSrchDropDown		= ISNULL(@CommSrchDropDown,0),
		OtherCommunity			= ISNULL(@OtherCommunity,OtherCommunity),
		RespectPrivacyProfile	= ISNULL(@RespectPrivacyProfile,RespectPrivacyProfile),
		PB_ID					= @PB_ID,
		LimitedView				= ISNULL(@LimitedView,LimitedView),
		VolunteerLink			= ISNULL(@VolunteerLink,VolunteerLink),
		SrchCommunityDefault	= ISNULL(@SrchCommunityDefault,SrchCommunityDefault),
		ASrchAddress			= ISNULL(@ASrchAddress,ASrchAddress),
		ASrchEmployee			= ISNULL(@ASrchEmployee,ASrchEmployee),
		ASrchNear				= ISNULL(@ASrchNear,ASrchNear),
		ASrchVacancy			= ISNULL(@ASrchVacancy,ASrchVacancy),
		ASrchVOL				= ISNULL(@ASrchVOL,ASrchVOL),
		BSrchAges				= ISNULL(@BSrchAges,BSrchAges),
		BSrchLanguage			= ISNULL(@BSrchLanguage, BSrchLanguage),
		BSrchNUM				= ISNULL(@BSrchNUM,BSrchNUM),
		BSrchOCG				= ISNULL(@BSrchOCG,BSrchOCG),
		BSrchVacancy			= ISNULL(@BSrchVacancy,BSrchVacancy),
		BSrchVOL				= ISNULL(@BSrchVOL,BSrchVOL),
		BSrchWWW				= ISNULL(@BSrchWWW,BSrchWWW),
		BSrchDefaultTab			= ISNULL(@BSrchDefaultTab, @BSrchDefaultTab),
		BSrchNear2				= ISNULL(@BSrchNear2, BSrchNear2),
		BSrchNear5				= ISNULL(@BSrchNear5, BSrchNear5),
		BSrchNear10				= ISNULL(@BSrchNear10, BSrchNear10),
		BSrchNear15				= ISNULL(@BSrchNear15, BSrchNear15),
		BSrchNear25				= ISNULL(@BSrchNear25, BSrchNear25),
		BSrchNear50				= ISNULL(@BSrchNear50, BSrchNear50),
		BSrchNear100			= ISNULL(@BSrchNear100, BSrchNear100),
		CSrch					= ISNULL(@CSrch,CSrch),
		CSrchBusRoute			= ISNULL(@CSrchBusRoute,CSrchBusRoute),
		CSrchKeywords			= ISNULL(@CSrchKeywords,CSrchKeywords),
		CSrchLanguages			= ISNULL(@CSrchLanguages, CSrchLanguages),
		CSrchNear				= ISNULL(@CSrchNear,CSrchNear),
		CSrchSchoolEscort		= ISNULL(@CSrchSchoolEscort,CSrchSchoolEscort),
		CSrchSchoolsInArea		= ISNULL(@CSrchSchoolsInArea,CSrchSchoolsInArea),
		CSrchSpaceAvailable		= ISNULL(@CSrchSpaceAvailable,CSrchSpaceAvailable),
		CSrchSubsidy			= ISNULL(@CSrchSubsidy,CSrchSubsidy),
		CSrchTypeOfProgram		= ISNULL(@CSrchTypeOfProgram,CSrchTypeOfProgram),
		CCRFields				= ISNULL(@CCRFields,CCRFields),
		QuickListDropDown		= ISNULL(@QuickListDropDown,QuickListDropDown),
		QuickListWrapAt			= ISNULL(@QuickListWrapAt,QuickListWrapAt),
		QuickListMatchAll		= ISNULL(@QuickListMatchAll,QuickListMatchAll),
		QuickListSearchGroups	= ISNULL(@QuickListSearchGroups,QuickListSearchGroups),
		QuickListPubHeadings	= @QuickListPubHeadings,
		LinkOrgLevels			= ISNULL(@LinkOrgLevels,LinkOrgLevels),
		CanSeeNonPublicPub		= @CanSeeNonPublicPub,
		UsePubNamesOnly			= ISNULL(@UsePubNamesOnly,UsePubNamesOnly),
		UseNAICSView			= ISNULL(@UseNAICSView,UseNAICSView),
		UseTaxonomyView			= ISNULL(@UseTaxonomyView,UseTaxonomyView),
		TaxDefnLevel			= ISNULL(@TaxDefnLevel,TaxDefnLevel),
		UseThesaurusView		= ISNULL(@UseThesaurusView,UseThesaurusView),
		UseLocalSubjects		= ISNULL(@UseLocalSubjects,UseLocalSubjects),
		UseZeroSubjects			= ISNULL(@UseZeroSubjects,UseZeroSubjects),
		AlsoNotify				= @AlsoNotify,
		NoProcessNotify			= ISNULL(@NoProcessNotify,NoProcessNotify),
		UseSubmitChangesTo		= ISNULL(@UseSubmitChangesTo,UseSubmitChangesTo),
		MapSearchResults		= ISNULL(@MapSearchResults,MapSearchResults),
		AutoMapSearchResults	= ISNULL(@AutoMapSearchResults,AutoMapSearchResults),
		ResultsPageSize			= @ResultsPageSize,
		ShowRecordDetailsSidebar = ISNULL(@ShowRecordDetailsSidebar, ShowRecordDetailsSidebar),
		RefineField1			= @RefineField1,
		RefineField2			= @RefineField2,
		RefineField3			= @RefineField3,
		RefineField4			= @RefineField4
	WHERE ViewType = @ViewType	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg

	IF @Error=0 BEGIN
		
		UPDATE vwd SET
			ViewName				= nt.ViewName,
			Notes					= nt.Notes,
			Title					= nt.Title,
			BottomMessage			= nt.BottomMessage,
			MenuMessage				= nt.MenuMessage,
			MenuTitle				= nt.MenuTitle,
			MenuGlyph				= nt.MenuGlyph,
			CSrchText				= nt.CSrchText,
			QuickListName			= nt.QuickListName,
			FeedbackBlurb			= nt.FeedbackBlurb,
			TermsOfUseURL			= nt.TermsOfUseURL,
			InclusionPolicy			= nt.InclusionPolicy,
			SearchTips				= nt.SearchTips,
			SearchLeftTitle			= nt.SearchLeftTitle,
			SearchLeftGlyph			= nt.SearchLeftGlyph,
			SearchLeftMessage		= nt.SearchLeftMessage,
			SearchCentreTitle		= nt.SearchCentreTitle,
			SearchCentreGlyph		= nt.SearchCentreGlyph,
			SearchCentreMessage		= nt.SearchCentreMessage,
			SearchRightTitle		= nt.SearchRightTitle,
			SearchRightGlyph		= nt.SearchRightGlyph,
			SearchRightMessage		= nt.SearchRightMessage,
			SearchAlertTitle		= nt.SearchAlertTitle,
			SearchAlertGlyph		= nt.SearchAlertGlyph,
			SearchAlertMessage		= nt.SearchAlertMessage,
			KeywordSearchTitle		= nt.KeywordSearchTitle,
			KeywordSearchGlyph		= nt.KeywordSearchGlyph,
			OtherSearchTitle		= nt.OtherSearchTitle,
			OtherSearchGlyph		= nt.OtherSearchGlyph,
			SearchTitleOverride		= nt.SearchTitleOverride,
		    OrganizationNames		= nt.OrganizationNames,
		    OrganizationsWithWWW	= nt.OrganizationsWithWWW,
		    OrganizationsWithVolOps	= nt.OrganizationsWithVolOps,
		    BrowseByOrg				= nt.BrowseByOrg,
		    FindAnOrgBy				= nt.FindAnOrgBy,
		    ViewProgramsAndServices	= nt.ViewProgramsAndServices,
		    ClickToViewDetails		= nt.ClickToViewDetails,
		    OrgProgramNames			= nt.OrgProgramNames,
		    Organization			= nt.Organization,
		    MultipleOrgWithSimilarMap = nt.MultipleOrgWithSimilarMap,
			OrgLevel1Name			= nt.OrgLevel1Name,
			OrgLevel2Name			= nt.OrgLevel2Name,
			OrgLevel3Name			= nt.OrgLevel3Name,
			QuickSearchTitle		= nt.QuickSearchTitle,
			QuickSearchGlyph		= nt.QuickSearchGlyph,
			PDFBottomMessage		= nt.PDFBottomMessage,
			PDFBottomMargin			= ISNULL(nt.PDFBottomMargin,vwd.PDFBottomMargin),
			GoogleTranslateDisclaimer = nt.GoogleTranslateDisclaimer,
			TagLine					= nt.TagLine,
			NoResultsMsg			= nt.NoResultsMsg
		FROM CIC_View_Description vwd
		INNER JOIN @DescTable nt
			ON vwd.LangID=nt.LangID
		WHERE vwd.ViewType=@ViewType
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg
	
		DELETE vr
		FROM CIC_View_Recurse vr
		WHERE vr.ViewType=@ViewType
			AND NOT EXISTS(SELECT * FROM @ViewTable nt WHERE vr.CanSee=nt.ViewType)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg

		INSERT INTO CIC_View_Recurse (
			ViewType,
			CanSee
		) SELECT
			@ViewType,
			nt.ViewType
		FROM @ViewTable nt
		WHERE EXISTS(SELECT * FROM CIC_View WHERE nt.ViewType=ViewType) AND 
			NOT EXISTS (SELECT * FROM CIC_View_Recurse WHERE ViewType=@ViewType AND CanSee=nt.ViewType)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg
				
		DELETE vchk
		FROM CIC_View_ChkField vchk
		WHERE vchk.ViewType=@ViewType
			AND NOT EXISTS(SELECT * FROM @AdvSrchChkTable nt WHERE vchk.FieldID=nt.FieldID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

		INSERT INTO CIC_View_ChkField (
			ViewType,
			FieldID
		) SELECT
			@ViewType,
			FieldID
		FROM @AdvSrchChkTable nt
		WHERE EXISTS(SELECT * FROM GBL_FieldOption WHERE nt.FieldID=FieldID) 
			AND NOT EXISTS(SELECT * FROM CIC_View_ChkField WHERE ViewType=@ViewType AND FieldID=nt.FieldID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

		DELETE qlp
		FROM CIC_View_QuickListPub qlp
		WHERE qlp.ViewType=@ViewType
			AND NOT EXISTS(SELECT * FROM @PublicationTable nt WHERE qlp.PB_ID=nt.PB_ID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg
		
		INSERT INTO CIC_View_QuickListPub (
			ViewType,
			PB_ID
		) SELECT
			@ViewType,
			PB_ID
		FROM @PublicationTable nt
		WHERE EXISTS(SELECT * FROM CIC_Publication WHERE nt.PB_ID=PB_ID) 
			AND NOT EXISTS(SELECT * FROM CIC_View_QuickListPub WHERE ViewType=@ViewType AND PB_ID=nt.PB_ID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg
		
		MERGE INTO CIC_View_AutoAddPub aap
		USING (SELECT DISTINCT PB_ID FROM @AddPublicationTable) nt
			ON aap.ViewType=@ViewType AND aap.PB_ID=nt.PB_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ViewType, PB_ID) VALUES (@ViewType, nt.PB_ID)
		WHEN NOT MATCHED BY SOURCE AND aap.ViewType=@ViewType THEN
			DELETE ;
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

	END
	
	IF @Error=0 BEGIN
		EXEC @Error = dbo.sp_GBL_Display_u NULL, @ViewType, 1, @ShowID, @ShowOwner, @ShowAlert, @ShowOrg, @ShowCommunity, @ShowUpdateSchedule, @LinkUpdate, @LinkEmail, @LinkSelect, @LinkWeb, @LinkListAdd, @OrderBy, @OrderByCustom, @OrderByDesc, @TableSort, @GlinkMail, @GLinkPub, @ShowTable, @VShowPosition, @VShowDuties, @DisplayOptFields, @ErrMsg OUTPUT
	END
END

RETURN @Error

SET NOCOUNT OFF













GO























GRANT EXECUTE ON  [dbo].[sp_CIC_View_u] TO [cioc_login_role]
GO
