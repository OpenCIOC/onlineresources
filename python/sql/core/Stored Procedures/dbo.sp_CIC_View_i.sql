SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_View_i]
	@MODIFIED_BY [varchar](50),
	@MemberID [int],
	@ViewName [varchar](100),
	@ViewType [int] OUTPUT,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 12-May-2016
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@ViewObjectName nvarchar(100),
		@ViewNameObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @ViewNameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View Name')

DECLARE
	@DefaultView int,
	@DefaultTemplate int,
	@DisplayFieldGroupID int,
	@DisplayFieldGroupDisplayOrder tinyint,
	@NewDisplayFieldGroupID int

SET @ViewName = RTRIM(LTRIM(@ViewName))
SET @DefaultView = @ViewType

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @ViewObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
END

IF @Error = 0 BEGIN

/* If we were not given a View to copy, take the default View instead */
IF @DefaultView IS NULL BEGIN
	SELECT @DefaultView = DefaultViewCIC FROM STP_Member WHERE MemberID=@MemberID
END

/* Identify errors that will prevent the record from being updated */
-- View Name provided ?
IF @ViewName IS NULL OR @ViewName = '' BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewNameObjectName, @ViewObjectName)
-- View Name already in use ?
END ELSE IF EXISTS (SELECT * FROM CIC_View vw INNER JOIN CIC_View_Description vwd ON vw.ViewType=vwd.ViewType WHERE ViewName=@ViewName AND MemberID=@MemberID) BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewName, @ViewNameObjectName)
-- View we are copying exists ?
END ELSE IF @ViewType IS NOT NULL AND NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- View we are copying owned by this member ?
END ELSE IF @ViewType IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE BEGIN
	/* if we don't have a default View for whatever reason, create a new basic one */

	IF @DefaultView IS NULL BEGIN
		/* Get a template - any template! */
		SELECT @DefaultTemplate = Template_ID FROM GBL_Template
		/* If there's no template in the system, create a new template */
		IF @DefaultTemplate IS NULL BEGIN
			EXEC @Error = sp_GBL_Template_Default_Check @DefaultTemplate OUTPUT, @ErrMsg OUTPUT
		END
		
		INSERT INTO CIC_View (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			Template
		)
		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@DefaultTemplate
		)

		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg
		SELECT @ViewType = SCOPE_IDENTITY()

		IF @Error = 0 BEGIN
			INSERT INTO CIC_View_Description (
				ViewType,
				CREATED_DATE,
				CREATED_BY,
				MODIFIED_DATE,
				MODIFIED_BY,
				ViewName,
				LangID
			)
			SELECT 
				@ViewType,
				GETDATE(),
				@MODIFIED_BY,
				GETDATE(),
				@MODIFIED_BY,
				cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(@ViewName,LangID),
				LangID
			FROM STP_Language
			WHERE Active=1
		END
	/*copy over all fields from the selected CIC_View except the View the name*/
	END ELSE BEGIN
		INSERT INTO dbo.CIC_View (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
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
			SrchCommunityDefault,
			ASrchAddress,
			ASrchAges,
			ASrchBool,
			ASrchDist,
			ASrchEmail,
			ASrchEmployee,
			ASrchLastRequest,
			ASrchNear,
			ASrchOwner,
			ASrchVacancy,
			ASrchVOL,
			BSrchAutoComplete,
			BSrchAges,
			BSrchBrowseByOrg,
			BSrchLanguage,
			BSrchNUM,
			BSrchOCG,
			BSrchKeywords,
			BSrchVacancy,
			BSrchVOL,
			BSrchWWW,
			BSrchDefaultTab,
			BSrchNear2,
			BSrchNear5,
			BSrchNear10,
			BSrchNear15,
			BSrchNear25,
			BSrchNear50,
			CSrch,
			CSrchBusRoute,
			CSrchKeywords,
			CSrchLanguages,
			CSrchNear,
			CSrchSchoolEscort,
			CSrchSchoolsInArea,
			CSrchSpaceAvailable,
			CSrchSubsidy,
			CSrchTypeOfProgram,
			CCRFields,
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
			NoProcessNotify,
			UseSubmitChangesTo,
			DataUseAuth,
			DataUseAuthPhone,
			MapSearchResults,
			MyList,
			ViewOtherLangs,
			AllowFeedbackNotInView,
			AssignSuggestionsTo,
			ResultsPageSize,
			AllowPDF,
			ShowRecordDetailsSidebar,
			GoogleTranslateWidget
		)
		SELECT
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
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
			SrchCommunityDefault,
			ASrchAddress,
			ASrchAges,
			ASrchBool,
			ASrchDist,
			ASrchEmail,
			ASrchEmployee,
			ASrchLastRequest,
			ASrchNear,
			ASrchOwner,
			ASrchVacancy,
			ASrchVOL,
			BSrchAutoComplete,
			BSrchAges,
			BSrchBrowseByOrg,
			BSrchLanguage,
			BSrchNUM,
			BSrchOCG,
			BSrchKeywords,
			BSrchVacancy,
			BSrchVOL,
			BSrchWWW,
			BSrchDefaultTab,
			BSrchNear2,
			BSrchNear5,
			BSrchNear10,
			BSrchNear15,
			BSrchNear25,
			BSrchNear50,
			CSrch,
			CSrchBusRoute,
			CSrchKeywords,
			CSrchLanguages,
			CSrchNear,
			CSrchSchoolEscort,
			CSrchSchoolsInArea,
			CSrchSpaceAvailable,
			CSrchSubsidy,
			CSrchTypeOfProgram,
			CCRFields,
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
			NoProcessNotify,
			UseSubmitChangesTo,
			DataUseAuth,
			DataUseAuthPhone,
			MapSearchResults,
			MyList,
			ViewOtherLangs,
			AllowFeedbackNotInView,
			AssignSuggestionsTo,
			ResultsPageSize,
			AllowPDF,
			ShowRecordDetailsSidebar,
			GoogleTranslateWidget
		FROM CIC_View
		WHERE ViewType = @DefaultView

		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg
		SELECT @ViewType = SCOPE_IDENTITY()

		INSERT INTO dbo.CIC_View_Description (
			ViewType,
			LangID,
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			ViewName,
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
			GoogleTranslateDisclaimer
		)
		SELECT
			@ViewType,
			LangID,
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@ViewName AS ViewName,
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
			GoogleTranslateDisclaimer
		FROM CIC_View_Description
		WHERE ViewType = @DefaultView
	END

	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg

	IF @Error = 0 AND @DefaultView IS NOT NULL BEGIN
		/* copy related View data including fields, "Can See" information, etc */

		DECLARE @DD_ID int,
				@DD_ID_NEW int

		SELECT @DD_ID = DD_ID FROM GBL_Display WHERE ViewTypeCIC=@DefaultView

		IF @DD_ID IS NOT NULL BEGIN
			INSERT INTO GBL_Display (
				ViewTypeCIC,
				Domain,
				ShowID,
				ShowOwner,
				ShowOrg,
				ShowCommunity,
				ShowUpdateSchedule,
				LinkWeb,
				LinkListAdd,
				ShowTable,
				OrderBy,
				OrderByCustom,
				OrderByDesc
			)
			SELECT 
				@ViewType,
				1,
				ShowID,
				ShowOwner,
				ShowOrg,
				ShowCommunity,
				ShowUpdateSchedule,
				LinkWeb,
				LinkListAdd,
				ShowTable,
				OrderBy,
				OrderByCustom,
				OrderByDesc
			FROM GBL_Display WHERE DD_ID=@DD_ID
			
			SELECT @DD_ID_NEW = SCOPE_IDENTITY()
			IF @DD_ID_NEW IS NOT NULL BEGIN
				INSERT INTO GBL_Display_Fld (DD_ID,FieldID)
					SELECT @DD_ID_NEW, FieldID
						FROM GBL_Display_Fld
					WHERE DD_ID=@DD_ID
			END
		END

		DECLARE FieldGroupCursor CURSOR LOCAL FOR
			SELECT DisplayFieldGroupID, DisplayOrder
				FROM CIC_View_DisplayFieldGroup
			WHERE ViewType = @DefaultView
		OPEN FieldGroupCursor

		FETCH NEXT FROM FieldGroupCursor INTO @DisplayFieldGroupID, @DisplayFieldGroupDisplayOrder
		WHILE @@FETCH_STATUS = 0 BEGIN
			INSERT INTO CIC_View_DisplayFieldGroup (
				ViewType,
				DisplayOrder
			)
			VALUES (
				@ViewType,
				@DisplayFieldGroupDisplayOrder
			)
			SET @NewDisplayFieldGroupID = SCOPE_IDENTITY()
			INSERT INTO CIC_View_DisplayFieldGroup_Name (
				DisplayFieldGroupID,
				LangID,
				[Name]
			)
			SELECT 
				@NewDisplayFieldGroupID,
				LangID,
				[Name]
			FROM CIC_View_DisplayFieldGroup_Name
				WHERE DisplayFieldGroupID=@DisplayFieldGroupID

			INSERT INTO CIC_View_DisplayField (DisplayFieldGroupID, FieldID)
				SELECT @NewDisplayFieldGroupID, FieldID
					FROM  CIC_View_DisplayField
				WHERE DisplayFieldGroupID=@DisplayFieldGroupID

			INSERT INTO CIC_View_UpdateField (DisplayFieldGroupID, FieldID, RT_ID)
				SELECT @NewDisplayFieldGroupID, FieldID, RT_ID
					FROM  CIC_View_UpdateField
				WHERE DisplayFieldGroupID=@DisplayFieldGroupID

			INSERT INTO CIC_View_FeedbackField (DisplayFieldGroupID, FieldID, RT_ID)
				SELECT @NewDisplayFieldGroupID, FieldID, RT_ID
					FROM  CIC_View_FeedbackField
				WHERE DisplayFieldGroupID=@DisplayFieldGroupID

			INSERT INTO CIC_View_MailFormField (DisplayFieldGroupID, FieldID)
				SELECT @NewDisplayFieldGroupID, FieldID
					FROM  CIC_View_MailFormField
				WHERE DisplayFieldGroupID=@DisplayFieldGroupID

			FETCH NEXT FROM FieldGroupCursor INTO @DisplayFieldGroupID, @DisplayFieldGroupDisplayOrder
		END
		
		CLOSE FieldGroupCursor

		DEALLOCATE FieldGroupCursor

		INSERT INTO CIC_View_Recurse (ViewType, CanSee)
			SELECT @ViewType AS ViewType, CanSee
				FROM CIC_View_Recurse
			WHERE ViewType = @DefaultView

		INSERT INTO CIC_View_Community (CM_ID, ViewType, DisplayOrder)
			SELECT CM_ID, @ViewType AS ViewType, DisplayOrder
				FROM CIC_View_Community
			WHERE ViewType = @DefaultView

		INSERT INTO CIC_View_ChkField (ViewType, FieldID)
			SELECT @ViewType AS ViewType, FieldID
				FROM CIC_View_ChkField
			WHERE ViewType = @DefaultView

		INSERT INTO CIC_View_PageMsg (ViewType, PageMsgID)
			SELECT @ViewType AS ViewType, PageMsgID
				FROM CIC_View_PageMsg
			WHERE ViewType = @DefaultView
	END ELSE BEGIN
		/* we don't have a View to copy from; insert all available fields */
		INSERT INTO CIC_View_DisplayFieldGroup (
			ViewType,
			DisplayOrder
		) VALUES (
			@ViewType, 
			1
		)
		SET @DisplayFieldGroupID = SCOPE_IDENTITY()
		INSERT INTO CIC_View_DisplayFieldGroup_Name (
			DisplayFieldGroupID,
			LangID,
			[Name]
		) VALUES (
			@DisplayFieldGroupID,
			@@LANGID,
			cioc_shared.dbo.fn_SHR_STP_ObjectName('Record Details')
		)
		INSERT INTO CIC_View_DisplayField (DisplayFieldGroupID, FieldID)
			SELECT @DisplayFieldGroupID AS DisplayFieldGroupID, FieldID
				FROM GBL_FieldOption
			WHERE CanUseDisplay=1
		INSERT INTO CIC_View_UpdateField (DisplayFieldGroupID, FieldID)
			SELECT @DisplayFieldGroupID AS DisplayFieldGroupID, FieldID
				FROM GBL_FieldOption
			WHERE CanUseDisplay=1
		INSERT INTO CIC_View_FeedbackField (DisplayFieldGroupID, FieldID)
			SELECT @DisplayFieldGroupID AS DisplayFieldGroupID, FieldID
				FROM GBL_FieldOption
			WHERE CanUseDisplay=1
		INSERT INTO CIC_View_MailFormField (DisplayFieldGroupID, FieldID)
			SELECT @DisplayFieldGroupID AS DisplayFieldGroupID, FieldID
				FROM GBL_FieldOption
			WHERE CanUseDisplay=1
	END
END

END

RETURN @Error

SET NOCOUNT OFF













GO

















GRANT EXECUTE ON  [dbo].[sp_CIC_View_i] TO [cioc_login_role]
GO
