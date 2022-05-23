SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_View_u]
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
	@BSrchBrowseAll BIT,
	@BSrchBrowseByInterest BIT,
	@BSrchBrowseByOrg BIT,
	@BSrchKeywords BIT,
	@BSrchStepByStep BIT,
	@BSrchStudent BIT,
	@BSrchWhatsNew BIT,
	@BSrchDefaultTab TINYINT,
	@BSrchCommunity BIT,
	@BSrchCommitmentLength BIT,
	@BSrchSuitableFor BIT,
	@DataUseAuth BIT,
	@DataUseAuthPhone BIT,
	@MyList BIT,
	@ViewOtherLangs BIT,
	@AllowFeedbackNotInView BIT,
	@AssignSuggestionsTo VARCHAR(3),
	@AllowPDF BIT,
	@CommunitySetID INT,
	@CanSeeExpired BIT,
	@SuggestOpLink BIT,
	@ASrchDatesTimes BIT,
	@ASrchOSSD BIT,
	@SSrchIndividualCount BIT,
	@SSrchDatesTimes BIT,
	@UseProfilesView BIT,
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
	@GoogleTranslateWidget BIT,
	@DefaultPrintProfile INT,
	@Descriptions XML,
	@Views XML,
	@AdvSrchCheckLists XML,
	@DisplayOptFields VARCHAR(MAX),
	@ErrMsg NVARCHAR(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@FieldObjectName nvarchar(100),
		@TemplateObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@CommunitySetObjectName nvarchar(100),
		@PrintProfileObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')
SET @TemplateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Design Template')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @CommunitySetObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community Set')
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
	FeedbackBlurb nvarchar(MAX) NULL,
	TermsOfUseURL varchar(255) NULL,
	InclusionPolicy int NULL,
	SearchTips int NULL,
	SearchLeftTitle nvarchar(100) NULL,
	SearchLeftGlyph varchar(30) NULL,
	SearchLeftMessage nvarchar(MAX) NULL,
	SearchCentreTitle nvarchar(100) NULL,
	SearchCentreMessage nvarchar(MAX) NULL,
	SearchCentreGlyph varchar(30) NULL,
	SearchRightTitle nvarchar(100) NULL,
	SearchRightGlyph varchar(30) NULL,
	SearchRightMessage nvarchar(MAX) NULL,
	SearchAlertTitle nvarchar(100) NULL,
	SearchAlertGlyph varchar(30) NULL,
	SearchAlertMessage nvarchar(MAX) NULL,
	SearchPromptOverride nvarchar(255) NULL,
	KeywordSearchTitle nvarchar(100) NULL,
	KeywordSearchGlyph varchar(30) NULL,
	OtherSearchTitle nvarchar(100) NULL,
	OtherSearchGlyph varchar(30) NULL,
	OtherSearchMessage nvarchar(MAX) NULL,
	PDFBottomMessage nvarchar(MAX) NULL,
	PDFBottomMargin varchar(20) NULL,
	HighlightOpportunity varchar(10) NULL,
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
	SearchPromptOverride,
	KeywordSearchTitle,
	KeywordSearchGlyph,
	OtherSearchTitle,
	OtherSearchGlyph,
	OtherSearchMessage,
	PDFBottomMessage,
	PDFBottomMargin,
	HighlightOpportunity,
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
	N.value('FeedbackBlurb[1]', 'nvarchar(2000)') AS FeedbackBlurb,
	N.value('TermsOfUseURL[1]', 'varchar(255)') AS TermsOfUseURL,
	(SELECT InclusionPolicyID FROM GBL_InclusionPolicy WHERE MemberID=@MemberID AND InclusionPolicyID=N.value('InclusionPolicy[1]', 'int')) AS InclusionPolicy,
	(SELECT SearchTipsID
		FROM GBL_SearchTips
		WHERE MemberID=@MemberID AND Domain=2 AND SearchTipsID=N.value('SearchTips[1]', 'int')
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
	N.value('SearchPromptOverride[1]', 'nvarchar(255)') AS SearchPrompOverride,
	N.value('KeywordSearchTitle[1]', 'nvarchar(100)') AS KeywordSearchTitle,
	N.value('KeywordSearchGlyph[1]', 'nvarchar(30)') AS KeywordSearchGlyph,
	N.value('OtherSearchTitle[1]', 'nvarchar(100)') AS OtherSearchTitle,
	N.value('OtherSearchGlyph[1]', 'nvarchar(30)') AS OtherSearchGlyph,
	N.value('OtherSearchMessage[1]', 'nvarchar(max)') AS OtherSearchMessage,
	N.value('PDFBottomMessage[1]', 'nvarchar(max)') AS PDFBottomMessage,
	N.value('PDFBottomMargin[1]', 'varchar(20)') AS PDFBottomMargin,
	N.value('HighlightOpportunity[1]','varchar(10)') AS HighlightOpportunity,
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
		KeywordSearchGlyph = CASE WHEN EXISTS(SELECT * FROM	dbo.STP_Icon WHERE IconName=KeywordSearchGlyph AND Type='glyphicon') THEN KeywordSearchGlyph ELSE NULL END,
		OtherSearchGlyph = CASE WHEN EXISTS(SELECT * FROM dbo.STP_Icon WHERE IconName=OtherSearchGlyph AND Type='glyphicon') THEN OtherSearchGlyph	ELSE NULL END

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
INNER JOIN VOL_FieldOption fo
	ON N.value('.','int')=fo.FieldID
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

SELECT @UsedNamesDesc = COALESCE(@UsedNamesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ViewName
	FROM @DescTable nt
WHERE EXISTS(SELECT * FROM VOL_View vw INNER JOIN VOL_View_Description vwd ON vw.ViewType=vwd.ViewType WHERE ViewName=nt.ViewName AND LangID=nt.LangID AND vw.ViewType<>@ViewType AND MemberID=@MemberID)

SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
	FROM @DescTable nt
WHERE LangID IS NULL

IF NOT EXISTS(SELECT * FROM GBL_Agency WHERE AgencyCode=@AssignSuggestionsTo) BEGIN
	SET @AssignSuggestionsTo = NULL
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
END ELSE IF NOT EXISTS (SELECT * FROM VOL_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS VARCHAR), @ViewObjectName)
-- View belongs to Member ?
END ELSE IF @ViewType IS NOT NULL AND NOT EXISTS (SELECT * FROM VOL_View WHERE MemberID=@MemberID AND ViewType=@ViewType) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM VOL_View WHERE ViewType=@ViewType AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- Template given ?
END ELSE IF @Template IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TemplateObjectName, NULL)
-- Template exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Template WHERE Template_ID=@Template) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Template AS VARCHAR), @TemplateObjectName)
-- Template ownership OK?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Template
		WHERE Template_ID=@Template
			AND (MemberID IS NULL OR MemberID=@MemberID)
			AND (
				EXISTS(SELECT * FROM VOL_View WHERE ViewType=@ViewType AND Template=@Template)
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
				EXISTS(SELECT * FROM VOL_View WHERE ViewType=@ViewType AND PrintTemplate=@PrintTemplate)
				OR (Owner IS NULL OR Owner=@AgencyCode)
			)
		) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TemplateObjectName, NULL)
-- Community Set given ?
END ELSE IF @CommunitySetID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunitySetObjectName, NULL)
-- Community Set exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_CommunitySet vcs WHERE vcs.CommunitySetID=@CommunitySetID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CommunitySetID AS VARCHAR), @CommunitySetObjectName)
-- Community Set belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_CommunitySet vcs WHERE vcs.CommunitySetID=@CommunitySetID AND vcs.MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunitySetObjectName, NULL)
-- Print Profile Exists ?
END ELSE IF @DefaultPrintProfile IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_PrintProfile pp WHERE pp.ProfileID=@DefaultPrintProfile AND pp.Domain=2) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@DefaultPrintProfile AS VARCHAR), @PrintProfileObjectName)
-- Print Profile belongs to Member ?
END ELSE IF @DefaultPrintProfile IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_PrintProfile pp WHERE pp.ProfileID=@DefaultPrintProfile AND pp.Domain=2 AND pp.MemberID=@MemberID OR pp.MemberID IS NULL) BEGIN
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
	UPDATE VOL_View
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
		BSrchBrowseAll			= ISNULL(@BSrchBrowseAll,BSrchBrowseAll),
		BSrchBrowseByInterest	= ISNULL(@BSrchBrowseByInterest,BSrchBrowseByInterest),
		BSrchBrowseByOrg		= ISNULL(@BSrchBrowseByOrg,BSrchBrowseByOrg),
		BSrchKeywords			= ISNULL(@BSrchKeywords,BSrchKeywords),
		BSrchStepByStep			= ISNULL(@BSrchStepByStep,BSrchStepByStep),
		BSrchStudent			= ISNULL(@BSrchStudent,BSrchStudent),
		BSrchWhatsNew			= ISNULL(@BSrchWhatsNew,BSrchWhatsNew),
		BSrchDefaultTab			= ISNULL(@BSrchDefaultTab, BSrchDefaultTab),
		BSrchCommunity			= ISNULL(@BSrchCommunity, BSrchCommunity),
		BSrchCommitmentLength	= ISNULL(@BSrchCommitmentLength, BSrchCommitmentLength),
		BSrchSuitableFor		= ISNULL(@BSrchSuitableFor, BSrchSuitableFor),
		DataUseAuth				= ISNULL(@DataUseAuth,DataUseAuth),
		DataUseAuthPhone		= ISNULL(@DataUseAuthPhone,DataUseAuthPhone),
		MyList					= ISNULL(@MyList,MyList),
		ViewOtherLangs			= ISNULL(@ViewOtherLangs,ViewOtherLangs),
		AllowFeedbackNotInView	= ISNULL(@AllowFeedbackNotInView,AllowFeedbackNotInView),
		AssignSuggestionsTo		= @AssignSuggestionsTo,
		AllowPDF				= ISNULL(@AllowPDF, AllowPDF),
		GoogleTranslateWidget	= ISNULL(@GoogleTranslateWidget,GoogleTranslateWidget),
		DefaultPrintProfile		= @DefaultPrintProfile,
		
		-- VOL-only fields
		CommunitySetID			= @CommunitySetID,
		CanSeeExpired			= ISNULL(@CanSeeExpired,CanSeeExpired),
		SuggestOpLink			= ISNULL(@SuggestOpLink,SuggestOpLink),
		ASrchDatesTimes			= ISNULL(@ASrchDatesTimes,ASrchDatesTimes),
		ASrchOSSD				= ISNULL(@ASrchOSSD,ASrchOSSD),
		SSrchIndividualCount	= ISNULL(@SSrchIndividualCount,SSrchIndividualCount),
		SSrchDatesTimes			= ISNULL(@SSrchDatesTimes,SSrchDatesTimes),
		UseProfilesView			= ISNULL(@UseProfilesView,UseProfilesView)
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
			SearchPromptOverride	= nt.SearchPromptOverride,
			KeywordSearchTitle		= nt.KeywordSearchTitle,
			KeywordSearchGlyph		= nt.KeywordSearchGlyph,
			OtherSearchTitle		= nt.OtherSearchTitle,
			OtherSearchGlyph		= nt.OtherSearchGlyph,
			OtherSearchMessage		= nt.OtherSearchMessage,
			PDFBottomMessage		= nt.PDFBottomMessage,
			PDFBottomMargin			= ISNULL(nt.PDFBottomMargin,vwd.PDFBottomMargin),
			HighlightOpportunity	= nt.HighlightOpportunity,
			GoogleTranslateDisclaimer	= nt.GoogleTranslateDisclaimer,
			TagLine					= nt.TagLine,
			NoResultsMsg			= nt.NoResultsMsg
		FROM VOL_View_Description vwd
		INNER JOIN @DescTable nt
			ON vwd.LangID=nt.LangID
		WHERE vwd.ViewType=@ViewType
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg
	
		
		DELETE vr
		FROM VOL_View_Recurse vr
		WHERE vr.ViewType=@ViewType
			AND NOT EXISTS(SELECT * FROM @ViewTable nt WHERE vr.CanSee=nt.ViewType)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg

		INSERT INTO VOL_View_Recurse (
			ViewType,
			CanSee
		) SELECT
			@ViewType,
			nt.ViewType
		FROM @ViewTable nt
		WHERE EXISTS(SELECT * FROM VOL_View WHERE nt.ViewType=ViewType) AND 
			NOT EXISTS (SELECT * FROM VOL_View_Recurse WHERE ViewType=@ViewType AND CanSee=nt.ViewType)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg
				
		DELETE vchk
		FROM VOL_View_ChkField vchk
		WHERE vchk.ViewType=@ViewType
			AND NOT EXISTS(SELECT * FROM @AdvSrchChkTable nt WHERE vchk.FieldID=nt.FieldID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

		
		INSERT INTO VOL_View_ChkField (
			ViewType,
			FieldId
		) SELECT
			@ViewType,
			FieldID
		FROM @AdvSrchChkTable nt
		WHERE EXISTS(SELECT * FROM VOL_FieldOption WHERE nt.FieldID=FieldID) 
			AND NOT EXISTS(SELECT * FROM VOL_View_ChkField WHERE ViewType=@ViewType AND FieldID=nt.FieldID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

	END
	
	IF @Error=0 BEGIN
		EXEC @Error = dbo.sp_GBL_Display_u NULL, @ViewType, 2, @ShowID, @ShowOwner, @ShowAlert, @ShowOrg, @ShowCommunity, @ShowUpdateSchedule, @LinkUpdate, @LinkEmail, @LinkSelect, @LinkWeb, @LinkListAdd, @OrderBy, @OrderByCustom, @OrderByDesc,@TableSort, @GlinkMail, @GLinkPub, @ShowTable, @VShowPosition, @VShowDuties, @DisplayOptFields, @ErrMsg OUTPUT
	END
END

RETURN @Error

SET NOCOUNT OFF





























GO

















GRANT EXECUTE ON  [dbo].[sp_VOL_View_u] TO [cioc_login_role]
GO
