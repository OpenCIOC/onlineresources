SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Users_s_View]
	@MemberID [int],
	@User_ID [int],
	@PageName [varchar](255),
	@UseViewCIC [int],
	@UseViewVOL [int],
	@ServerName [varchar](255),
	@IsDefaultCulture [bit],
	@IPAddress varchar(20) = NULL,
	@ErrMsg [nvarchar](255) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 6-Dec-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(60),
		@UserObjectName		nvarchar(60)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @UserObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User')

DECLARE	@CurrentIDCIC int,
		@CurrentIDVOL int,
		@LangID smallint,
		@DefaultViewCIC int,
		@DefaultViewVOL int, 
		@DefaultLangID smallint,
		@DefaultCulture nvarchar(5)

SET @DefaultViewCIC = NULL
SET @DefaultViewVOL = NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
	SET @MemberID = NULL
-- User belongs to Membership ?
END ELSE IF @User_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Users u WHERE [User_ID]=@User_ID AND u.MemberID_Cache=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
	SET @User_ID = NULL
END

IF @UseViewCIC IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_View WHERE ViewType=@UseViewCIC) BEGIN
	SET @UseViewCIC = NULL
END

IF @UseViewVOL IS NOT NULL AND NOT EXISTS(SELECT * FROM VOL_View WHERE ViewType=@UseViewVOL) BEGIN
	SET @UseViewVOL = NULL
END

SELECT @DefaultLangID=sln.LangID, @DefaultCulture=Culture
	FROM GBL_View_DomainMap dmp
	INNER JOIN STP_Language sln
		ON dmp.DefaultLangID=sln.LangID
WHERE sln.Active=1
	AND DomainName = @ServerName

SET @LangID=@@LANGID

IF @IsDefaultCulture=1 BEGIN
	SET @LangID=ISNULL(@DefaultLangID,@@LANGID)
END

SELECT @DefaultCulture AS Culture

IF NOT EXISTS(SELECT * FROM STP_Language sln WHERE LangID=@LangID AND Active=1) BEGIN
	SELECT TOP 1 @LangID=LangID FROM STP_Language WHERE Active=1 ORDER BY LangID
END

IF @User_ID IS NULL BEGIN
	SELECT	@UseViewCIC=ISNULL(@UseViewCIC, CICViewType), 
			@UseViewVOL=ISNULL(@UseViewVOL, VOLViewType)
	FROM GBL_View_DomainMap
	WHERE MemberID=@MemberID
		AND DomainName=@ServerName
END ELSE IF EXISTS (SELECT * FROM GBL_Users WHERE [User_ID]=@User_ID) BEGIN
	SELECT @DefaultViewCIC = ViewType
		FROM CIC_SecurityLevel sl
		INNER JOIN GBL_Users u
			ON sl.SL_ID = u.SL_ID_CIC
	WHERE [User_ID]=@User_ID
	SELECT @DefaultViewVOL = ViewType
		FROM VOL_SecurityLevel sl
		INNER JOIN GBL_Users u
			ON sl.SL_ID = u.SL_ID_VOL
	WHERE [User_ID]=@User_ID
END

SELECT	@DefaultViewCIC = ISNULL(@DefaultViewCIC,DefaultViewCIC),
		@DefaultViewVOL = ISNULL(@DefaultViewVOL,DefaultViewVOL)
	FROM STP_Member
WHERE MemberID=@MemberID

IF @UseViewCIC=@DefaultViewCIC BEGIN
	SET @UseViewCIC = NULL
END
IF @UseViewVOL=@DefaultViewVOL BEGIN
	SET @UseViewVOL = NULL
END

IF @UseViewCIC IS NOT NULL BEGIN
	SELECT @CurrentIDCIC = vw.ViewType
		FROM CIC_View vw
		INNER JOIN CIC_View_Recurse vr
			ON vw.ViewType = vr.CanSee
		WHERE MemberID=@MemberID
			AND vr.ViewType = @DefaultViewCIC AND vw.ViewType = @UseViewCIC
			AND (
				NOT EXISTS(SELECT * FROM dbo.CIC_View_Whitelist wl WHERE wl.ViewType=vw.ViewType)
				OR EXISTS(SELECT * FROM dbo.CIC_View_Whitelist wl WHERE wl.ViewType=vw.ViewType
					AND wl.IPAddress=@IPAddress)
				OR @User_ID IS NOT NULL
				)
END

IF @CurrentIDCIC IS NULL BEGIN
	SET @CurrentIDCIC = @DefaultViewCIC
END

IF @UseViewVOL IS NOT NULL BEGIN
	SELECT @CurrentIDVOL = vw.ViewType
		FROM VOL_View vw
		INNER JOIN VOL_View_Recurse vr
			ON vw.ViewType = vr.CanSee
		WHERE MemberID=@MemberID
			AND vr.ViewType = @DefaultViewVOL AND vw.ViewType = @UseViewVOL
END

IF @CurrentIDVOL IS NULL BEGIN
	SET @CurrentIDVOL = @DefaultViewVOL
END

SELECT	vw.ViewType,
		(SELECT Culture FROM STP_Language sln WHERE sln.LangID=vwd.LangID) AS Culture,
		ViewName,
		CanSeeNonPublic,
		CanSeeDeleted,
		HidePastDueBy,
		AlertColumn,
		Template,
		PrintTemplate,
		PrintVersionResults,
		DataMgmtFields,
		LastModifiedDate,
		SocialMediaShare,
		CommSrchWrapAt,
		CommSrchDropDown,
		OtherCommunity,
		RespectPrivacyProfile,
		PB_ID,
		LimitedView,
		VolunteerLink,
		QuickListName,
		QuickListDropDown,
		QuickListWrapAt,
		QuickListMatchAll,
		QuickListSearchGroups,
		QuickListPubHeadings,
		LinkOrgLevels,
		CanSeeNonPublicPub,
		UsePubNamesOnly,
		UseNAICSView,
		UseTaxonomyView,
		TaxDefnLevel,
		UseThesaurusView,
		UseLocalSubjects,
		UseZeroSubjects,
		AlsoNotify,
		Title,
		BottomMessage,
		MapSearchResults,
		AutoMapSearchResults,
		ResultsPageSize,
		UseSubmitChangesTo,
		CAST(CASE WHEN EXISTS(SELECT * FROM CIC_View_ExcelProfile vep WHERE vep.ViewType=vw.ViewType) THEN 1 ELSE 0 END AS bit) AS HasExcelProfile,
		CAST(CASE WHEN EXISTS(SELECT * FROM CIC_View_ExportProfile vep WHERE vep.ViewType=vw.ViewType) THEN 1 ELSE 0 END AS bit) AS HasExportProfile,
		MyList,
		ViewOtherLangs,
		AllowFeedbackNotInView,
		AssignSuggestionsTo,
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
		PDFBottomMessage,
		PDFBottomMargin,
		AllowPDF,
		ShowRecordDetailsSidebar,
		GoogleTranslateWidget,
		GoogleTranslateDisclaimer,
		NoResultsMsg,
		TagLine,
		DefaultPrintProfile,
		(SELECT pp.[Public] FROM GBL_PrintProfile pp WHERE ProfileID=DefaultPrintProfile AND Domain=1) AS DefaultPrintProfilePublic
	FROM CIC_View vw
	LEFT JOIN CIC_View_Description vwd
		ON vw.ViewType = vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
WHERE vw.ViewType=@CurrentIDCIC

SELECT Culture, LanguageName, sln.LangID
	FROM CIC_View_Description vwd
	INNER JOIN STP_Language sln
		ON vwd.LangID=sln.LangID
WHERE vwd.ViewType=@CurrentIDCIC
	AND sln.Active=1

SELECT 	vcsn.AreaServed,
		vcs.CommunitySetID,
		vw.ViewType,
		(SELECT Culture FROM STP_Language sln WHERE sln.LangID=vwd.LangID) AS Culture,
		ViewName,
		Title,
		CanSeeNonPublic,
		CanSeeDeleted,
		CanSeeExpired,
		HidePastDueBy,
		AlertColumn,
		Template,
		PrintTemplate,
		PrintVersionResults,
		DataMgmtFields,
		LastModifiedDate,
		SocialMediaShare,
		CommSrchWrapAt,
		BottomMessage,
		ASrchOSSD,
		SSrchIndividualCount,
		SSrchDatesTimes,
		SuggestOpLink,
		UseProfilesView,
		MyList,
		ViewOtherLangs,
		AllowFeedbackNotInView,
		AssignSuggestionsTo,
		PDFBottomMessage,
		PDFBottomMargin,
		AllowPDF,
		GoogleTranslateWidget,
		GoogleTranslateDisclaimer,
		NoResultsMsg,
		TagLine,
		DefaultPrintProfile,
		(SELECT pp.[Public] FROM GBL_PrintProfile pp WHERE ProfileID=DefaultPrintProfile AND Domain=2) AS DefaultPrintProfilePublic
	FROM VOL_View vw
	LEFT JOIN VOL_View_Description vwd
		ON vw.ViewType = vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_CommunitySet vcs
		ON vw.CommunitySetID=vcs.CommunitySetID
	LEFT JOIN VOL_CommunitySet_Name vcsn
		ON vcs.CommunitySetID=vcsn.CommunitySetID AND vcsn.LangID=(SELECT TOP 1 LangID FROM VOL_CommunitySet_Name WHERE CommunitySetID=vcsn.CommunitySetID ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
WHERE vw.ViewType=@CurrentIDVOL

SELECT Culture, LanguageName, sln.LangID
	FROM VOL_View_Description vwd
	INNER JOIN STP_Language sln
		ON vwd.LangID=sln.LangID
WHERE vwd.ViewType=@CurrentIDVOL
	AND sln.Active=1

SELECT DISTINCT msg.PageMsgID, msg.PageMsg, msg.VisiblePrintMode, msg.DisplayOrder
	FROM dbo.GBL_PageMsg msg
	INNER JOIN dbo.GBL_PageMsg_PageInfo mpg
		ON msg.PageMsgID=mpg.PageMsgID
	INNER JOIN dbo.GBL_PageInfo pg
		ON mpg.PageName=pg.PageName
	LEFT JOIN (SELECT PageMsgID FROM dbo.CIC_View_PageMsg WHERE ViewType=@CurrentIDCIC) cvm
		ON msg.PageMsgID=cvm.PageMsgID
	LEFT JOIN (SELECT PageMsgID FROM dbo.VOL_View_PageMsg WHERE ViewType=@CurrentIDVOL) vvm
		ON msg.PageMsgID=vvm.PageMsgID
WHERE @PageName LIKE pg.PageName
	AND ((pg.CIC=1 AND cvm.PageMsgID IS NOT NULL) OR (pg.VOL=1 AND vvm.PageMsgID IS NOT NULL))
	AND msg.LangID=@LangID
	AND (msg.LoginOnly=0 OR	@User_ID IS NOT NULL)
ORDER BY msg.DisplayOrder

RETURN @Error
	
SET NOCOUNT OFF


GO



















GRANT EXECUTE ON  [dbo].[sp_GBL_Users_s_View] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_s_View] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_s_View] TO [cioc_vol_search_role]
GO
