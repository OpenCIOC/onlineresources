
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_View_i]
	@MODIFIED_BY [varchar](50),
	@MemberID [int],
	@ViewName [varchar](50),
	@ViewType [int] OUTPUT,
	@ErrMsg [nvarchar](500) OUTPUT
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

DECLARE	@MemberObjectName	nvarchar(100),
		@ViewObjectName nvarchar(100),
		@ViewNameObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @ViewNameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View Name')

DECLARE @DefaultView		int,
		@DefaultTemplate	int,
		@CommunitySetID		int

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

IF @DefaultView IS NULL BEGIN
	SELECT @DefaultView = DefaultViewVOL FROM STP_Member WHERE MemberID=@MemberID
END

/* Identify errors that will prevent the record from being updated */
-- View Name provided ?
IF @ViewName IS NULL OR @ViewName = '' BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewNameObjectName, @ViewObjectName)
-- View Name already in use ?
END ELSE IF EXISTS (SELECT * FROM VOL_View vw INNER JOIN VOL_View_Description vwd ON vw.ViewType=vwd.ViewType WHERE ViewName=@ViewName AND MemberID=@MemberID) BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewName, @ViewNameObjectName)
-- View we are copying exists ?
END ELSE IF @ViewType IS NOT NULL AND NOT EXISTS (SELECT * FROM VOL_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- View we are copying owned by this member ?
END ELSE IF @ViewType IS NOT NULL AND NOT EXISTS(SELECT * FROM VOL_View WHERE ViewType=@ViewType AND MemberID=@MemberID) BEGIN
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
		
		IF NOT EXISTS(SELECT * FROM VOL_CommunitySet WHERE MemberID=@MemberID) BEGIN
			Declare @Culture varchar(5), @csxml xml
			SELECT TOP 1 @Culture=Culture FROM STP_Language WHERE Active=1 ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID
			
			SET @csxml = REPLACE('<DESCS><DESC><Culture>[CULTURE]</Culture><SetName>Default Set</SetName><AreaServed>Our Area</AreaServed></DESC></DESCS>' ,'[CULTURE]',@Culture)
			EXEC @Error = sp_VOL_CommunitySet_i @MODIFIED_BY, @MemberID, @csxml, @ErrMsg OUTPUT
		END
		
		SELECT @CommunitySetID = CommunitySetID FROM VOL_CommunitySet
		INSERT INTO VOL_View (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			Template,
			CommunitySetID
		)
		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@DefaultTemplate,
			@CommunitySetID
		)

		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg
		SELECT @ViewType = SCOPE_IDENTITY()

		IF @Error = 0 BEGIN
			INSERT INTO VOL_View_Description (
				ViewType,
				CREATED_DATE,
				CREATED_BY,
				MODIFIED_DATE,
				MODIFIED_BY,
				ViewName,
				LangID
			)
			VALUES (
				@ViewType,
				GETDATE(),
				@MODIFIED_BY,
				GETDATE(),
				@MODIFIED_BY,
				@ViewName,
				@@LANGID
			)
		END
	END ELSE BEGIN

		INSERT INTO dbo.VOL_View (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			CommunitySetID,
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
			SuggestOpLink,
			BSrchAutoComplete,
			BSrchBrowseAll,
			BSrchBrowseByInterest,
			BSrchBrowseByOrg,
			BSrchKeywords,
			BSrchStepByStep,
			BSrchStudent,
			BSrchWhatsNew,
			BSrchDefaultTab,
			BSrchCommunity,
			BSrchCommitmentLength,
			BSrchSuitableFor,
			ASrchAges,
			ASrchBool,
			ASrchDatesTimes,
			ASrchEmail,
			ASrchLastRequest,
			ASrchOwner,
			ASrchOSSD,
			SSrchIndividualCount,
			SSrchDatesTimes,
			UseProfilesView,
			DataUseAuth,
			DataUseAuthPhone,
			MyList,
			ViewOtherLangs,
			AllowFeedbackNotInView,
			AssignSuggestionsTo,
			AllowPDF,
			GoogleTranslateWidget
		)
		SELECT
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			CommunitySetID,
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
			SuggestOpLink,
			BSrchAutoComplete,
			BSrchBrowseAll,
			BSrchBrowseByInterest,
			BSrchBrowseByOrg,
			BSrchKeywords,
			BSrchStepByStep,
			BSrchStudent,
			BSrchWhatsNew,
			BSrchDefaultTab,
			BSrchCommunity,
			BSrchCommitmentLength,
			BSrchSuitableFor,
			ASrchAges,
			ASrchBool,
			ASrchDatesTimes,
			ASrchEmail,
			ASrchLastRequest,
			ASrchOwner,
			ASrchOSSD,
			SSrchIndividualCount,
			SSrchDatesTimes,
			UseProfilesView,
			DataUseAuth,
			DataUseAuthPhone,
			MyList,
			ViewOtherLangs,
			AllowFeedbackNotInView,
			AssignSuggestionsTo,
			AllowPDF,
			GoogleTranslateWidget
		FROM VOL_View
		WHERE ViewType = @DefaultView

		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg
		SELECT @ViewType = SCOPE_IDENTITY()

		INSERT INTO dbo.VOL_View_Description (
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
			SearchPromptOverride,
			KeywordSearchTitle,
			KeywordSearchGlyph,
			OtherSearchTitle,
			OtherSearchGlyph,
			PDFBottomMessage,
			PDFBottomMargin,
			GoogleTranslateDisclaimer,
			HighlightOpportunity
		)
		SELECT
			@ViewType,
			LangID,
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@ViewName,
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
			SearchAlertMessage,
			SearchPromptOverride,
			KeywordSearchTitle,
			KeywordSearchGlyph,
			OtherSearchTitle,
			OtherSearchGlyph,
			PDFBottomMessage,
			PDFBottomMargin,
			GoogleTranslateDisclaimer,
			HighlightOpportunity
		FROM VOL_View_Description

		WHERE ViewType = @DefaultView
	END

	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg

	IF @Error = 0 AND @DefaultView IS NOT NULL BEGIN
		
		DECLARE @DD_ID int,
				@DD_ID_NEW int

		SELECT @DD_ID = DD_ID FROM GBL_Display WHERE ViewTypeVOL=@DefaultView

		IF @DD_ID IS NOT NULL BEGIN
			INSERT INTO GBL_Display (
				ViewTypeVOL,
				Domain,
				ShowID,
				ShowOwner,
				ShowOrg,
				ShowCommunity,
				ShowUpdateSchedule,
				LinkListAdd,
				OrderBy,
				OrderByCustom,
				VShowTable,
				VShowPosition,
				VShowDuties
			)
			SELECT 
				@ViewType,
				2,
				ShowID,
				ShowOwner,
				ShowOrg,
				ShowCommunity,
				ShowUpdateSchedule,
				LinkListAdd,
				OrderBy,
				OrderByCustom,
				VShowTable,
				VShowPosition,
				VShowDuties
			FROM GBL_Display
			WHERE DD_ID=@DD_ID
			
			SELECT @DD_ID_NEW = SCOPE_IDENTITY()
			IF @DD_ID_NEW IS NOT NULL BEGIN
				INSERT INTO VOL_Display_Fld (DD_ID,FieldID)
					SELECT @DD_ID_NEW, FieldID
						FROM VOL_Display_Fld
					WHERE DD_ID=@DD_ID
			END
		END

		INSERT INTO VOL_View_Recurse (ViewType, CanSee)
			SELECT @ViewType AS ViewType, CanSee
				FROM VOL_View_Recurse
			WHERE ViewType = @DefaultView
		INSERT INTO VOL_View_ChkField (ViewType, FieldID)
			SELECT @ViewType AS ViewType, FieldID
				FROM VOL_View_ChkField
			WHERE ViewType = @DefaultView
		INSERT INTO VOL_View_DisplayField (ViewType, FieldID)
			SELECT @ViewType AS ViewType, FieldID
				FROM VOL_View_DisplayField
			WHERE ViewType = @DefaultView
		INSERT INTO VOL_View_FeedbackField (ViewType, FieldID)
			SELECT @ViewType AS ViewType, FieldID
				FROM VOL_View_FeedbackField
			WHERE ViewType = @DefaultView
		INSERT INTO VOL_View_UpdateField (ViewType, FieldID)
			SELECT @ViewType AS ViewType, FieldID
				FROM VOL_View_UpdateField
			WHERE ViewType = @DefaultView
		INSERT INTO VOL_View_PageMsg (ViewType, PageMsgID)
			SELECT @ViewType AS ViewType, PageMsgID
				FROM VOL_View_PageMsg
			WHERE ViewType = @DefaultView
	END ELSE BEGIN
		INSERT INTO VOL_View_DisplayField (ViewType, FieldID)
			SELECT @ViewType AS ViewType, FieldID
				FROM VOL_FieldOption
			WHERE CanUseDisplay = 1
		INSERT INTO VOL_View_UpdateField (ViewType, FieldID)
			SELECT @ViewType AS ViewType, FieldID
				FROM VOL_FieldOption
			WHERE CanUseUpdate = 1
		INSERT INTO VOL_View_FeedbackField (ViewType, FieldID)
			SELECT @ViewType AS ViewType, FieldID
				FROM VOL_FieldOption
			WHERE CanUseFeedback = 1
	END
END

END

RETURN @Error

SET NOCOUNT OFF










GO














GRANT EXECUTE ON  [dbo].[sp_VOL_View_i] TO [cioc_login_role]
GO
