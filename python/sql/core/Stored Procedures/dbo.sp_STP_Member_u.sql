SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_STP_Member_u]
	@MemberID [int],
	@MODIFIED_BY [varchar](50),
	@AgencyCode [char](3),
	@UseCIC [bit],
	@UseVOL [bit],
	@DefaultViewCIC [int],
	@DefaultViewVOL [int],
	@DefaultTemplate [int],
	@DefaultPrintTemplate [int],
	@PrintModePublic [bit],
	@TrainingMode [bit],
	@UseInitials [bit],
	@SiteCodeLength [tinyint],
	@DaysSinceLastEmail [smallint],
	@DefaultEmailCIC [varchar](100),
	@DefaultEmailVOL [varchar](100),
	@DefaultEmailVOLProfile [varchar](100),
    @DefaultEmailNameCIC nvarchar(100),
	@DefaultEmailNameVOL nvarchar(100),
	@BaseURLCIC [varchar](100),
	@BaseURLVOL [varchar](100),
	@DefaultProvince varchar(2),
	@DefaultGCType [tinyint],
	@CanDeleteRecordNoteCIC [tinyint],
	@CanUpdateRecordNoteCIC [tinyint],
	@CanDeleteRecordNoteVOL [tinyint],
	@CanUpdateRecordNoteVOL [tinyint],
	@RecordNoteTypeOptionalCIC [bit],
	@RecordNoteTypeOptionalVOL [bit],
	@PreventDuplicateOrgNames [tinyint],
	@UseOfflineTools bit,
	@UseLowestNUM [bit],
	@OnlySpecificInterests bit,
	@LoginRetryLimit tinyint,
	@ImportNotificationEmailCIC [varchar](500),
    @ContactOrgCIC bit,
    @ContactPhone1CIC bit,
    @ContactPhone2CIC bit,
    @ContactPhone3CIC bit,
    @ContactFaxCIC bit,
    @ContactEmailCIC bit,
    @ContactOrgVOL bit,
    @ContactPhone1VOL bit,
    @ContactPhone2VOL bit,
    @ContactPhone3VOL bit,
    @ContactFaxVOL bit,
    @ContactEmailVOL bit,
	@Descriptions [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON


DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@GeneralSetupObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@TemplateObjectName nvarchar(100),
		@PrintTemplateObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100)		

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @GeneralSetupObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('General Setup')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @TemplateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Template')
SET @TemplateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Print Template')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	DatabaseNameCIC nvarchar(255) NULL,
	DatabaseNameVOL nvarchar(255) NULL,
	FeedbackMsgCIC nvarchar(max) NULL,
	FeedbackMsgVOL nvarchar(max) NULL,
	VolProfilePrivacyPolicy nvarchar(max) NULL,
	VolProfilePrivacyPolicyOrgName nvarchar(255) NULL,
    SubsidyNamedProgram nvarchar(255) NULL,
    SubsidyNamedProgramDesc nvarchar(1000) NULL,
    SubsidyNamedProgramSearchLabel nvarchar(255) NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	DatabaseNameCIC,
	DatabaseNameVOL,
	FeedbackMsgCIC,
	FeedbackMsgVOL,
	VolProfilePrivacyPolicy,
	VolProfilePrivacyPolicyOrgName,
    SubsidyNamedProgram,
    SubsidyNamedProgramDesc,
    SubsidyNamedProgramSearchLabel
)
SELECT
	N.query('Culture').value('/', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.query('Culture').value('/', 'varchar(5)') AND Active=1) AS LangID,
	CASE WHEN N.exist('DatabaseNameCIC')=1 THEN N.query('DatabaseNameCIC').value('/', 'nvarchar(255)') ELSE NULL END AS DatabaseNameCIC,
	CASE WHEN N.exist('DatabaseNameVOL')=1 THEN N.query('DatabaseNameVOL').value('/', 'nvarchar(255)') ELSE NULL END AS DatabaseNameVOL,
	CASE WHEN N.exist('FeedbackMsgCIC')=1 THEN N.query('FeedbackMsgCIC').value('/', 'nvarchar(max)') ELSE NULL END AS FeedbackMsgCIC,
	CASE WHEN N.exist('FeedbackMsgVOL')=1 THEN N.query('FeedbackMsgVOL').value('/', 'nvarchar(max)') ELSE NULL END AS FeedbackMsgVOL,
	CASE WHEN N.exist('VolProfilePrivacyPolicy')=1 THEN N.query('VolProfilePrivacyPolicy').value('/', 'nvarchar(max)') ELSE NULL END AS VolProfilePrivacyPolicy,
	CASE WHEN N.exist('VolProfilePrivacyPolicyOrgName')=1 THEN N.query('VolProfilePrivacyPolicyOrgName').value('/', 'nvarchar(255)') ELSE NULL END AS VolProfilePrivacyPolicyOrgName,
    N.value('SubsidyNamedProgram[1]', 'nvarchar(255)') AS SubsidyNamedProgram,
    N.value('SubsidyNamedProgramDesc[1]', 'nvarchar(1000)') AS SubsidyNamedProgramDesc,
    N.value('SubsidyNamedProgramSearchLabel[1]', 'nvarchar(255)') AS SubsidyNamedProgramSearchLabel
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Default Template given ?
END ELSE IF @DefaultTemplate IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TemplateObjectName, @GeneralSetupObjectName)
-- Default Template exists ?
END IF NOT EXISTS (SELECT * FROM dbo.GBL_Template WHERE Template_ID=@DefaultTemplate) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@DefaultTemplate AS varchar), @TemplateObjectName)
-- Default Template ownership OK ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Template
		WHERE Template_ID=@DefaultTemplate
			AND (MemberID IS NULL OR MemberID=@MemberID)
			AND (
				EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID AND DefaultTemplate=@DefaultTemplate)
				OR (Owner IS NULL OR Owner=@AgencyCode)
			)
		) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TemplateObjectName, NULL)
-- Default Print Template given ?
END ELSE IF @DefaultPrintTemplate IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PrintTemplateObjectName, @GeneralSetupObjectName)
-- Default Print Template exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Template WHERE Template_ID=@DefaultPrintTemplate) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@DefaultPrintTemplate AS varchar), @PrintTemplateObjectName)
-- Default Print Template ownership OK ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Template
		WHERE Template_ID=@DefaultTemplate
			AND (MemberID IS NULL OR MemberID=@MemberID)
			AND (
				EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID AND DefaultPrintTemplate=@DefaultPrintTemplate)
				OR (Owner IS NULL OR Owner=@AgencyCode)
			)
		) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PrintTemplateObjectName, NULL)
END ELSE IF @UseCIC=1 AND @DefaultViewCIC IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, @GeneralSetupObjectName)
END ELSE IF @UseCIC=1 AND NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@DefaultViewCIC) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@DefaultViewCIC AS varchar), @ViewObjectName)
END ELSE IF @UseCIC=1 AND (SELECT DefaultViewCIC FROM STP_Member WHERE MemberID=@MemberID)<>@DefaultViewCIC AND NOT 
		EXISTS(SELECT * FROM CIC_View WHERE ViewType=@DefaultViewCIC AND Owner IS NULL OR Owner=@AgencyCode) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
END ELSE IF @UseVOL=1 AND @DefaultViewVOL IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, @GeneralSetupObjectName)
END ELSE IF @UseVOL=1 AND NOT EXISTS (SELECT * FROM VOL_View WHERE ViewType=@DefaultViewVOL) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@DefaultViewVOL AS varchar), @ViewObjectName)
END ELSE IF @UseVOL=1 AND (SELECT DefaultViewVOL FROM STP_Member WHERE MemberID=@MemberID)<>@DefaultViewVOL AND NOT 
		EXISTS(SELECT * FROM VOL_View WHERE ViewType=@DefaultViewVOL AND Owner IS NULL OR Owner=@AgencyCode) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
END

IF @Error = 0 BEGIN
	UPDATE dbo.STP_Member
		SET	MODIFIED_DATE = GETDATE(),
			MODIFIED_BY = @MODIFIED_BY,
			DefaultViewCIC = CASE WHEN @UseCIC=1 THEN @DefaultViewCIC ELSE DefaultViewCIC END,
			DefaultViewVOL = CASE WHEN @UseVOL=1 THEN @DefaultViewVOL ELSE DefaultViewVOL END,
			DefaultTemplate = @DefaultTemplate,
			DefaultPrintTemplate = @DefaultPrintTemplate,
			PrintModePublic = @PrintModePublic,
			TrainingMode = @TrainingMode,
			UseInitials = @UseInitials,
			SiteCodeLength = CASE WHEN @UseCIC=1 THEN @SiteCodeLength ELSE SiteCodeLength END,
			DaysSinceLastEmail = @DaysSinceLastEmail,
			DefaultEmailCIC = CASE WHEN @UseCIC=1 THEN @DefaultEmailCIC ELSE DefaultEmailCIC END,
			DefaultEmailVOL = CASE WHEN @UseVOL=1 THEN @DefaultEmailVOL ELSE DefaultEmailVOL END,
			DefaultEmailVOLProfile = CASE WHEN @UseVOL=1 THEN @DefaultEmailVOLProfile ELSE DefaultEmailVOLProfile END,
			DefaultEmailNameCIC = CASE WHEN @UseCIC=1 THEN @DefaultEmailNameCIC ELSE DefaultEmailNameCIC END,
			DefaultEmailNameVOL = CASE WHEN @UseVOL=1 THEN @DefaultEmailNameVOL ELSE DefaultEmailNameVOL END,
			BaseURLCIC = CASE WHEN @UseCIC=1 THEN @BaseURLCIC ELSE BaseURLCIC END,
			BaseURLVOL = CASE WHEN @UseVOL=1 THEN @BaseURLVOL ELSE BaseURLVOL END,
			DefaultProvince = CASE WHEN @UseCIC=1 THEN @DefaultProvince ELSE DefaultProvince END,
			DefaultGCType = CASE WHEN @UseCIC=1 THEN @DefaultGCType ELSE DefaultGCType END,
			CanDeleteRecordNoteCIC = CASE WHEN @UseCIC=1 THEN @CanDeleteRecordNoteCIC ELSE CanDeleteRecordNoteCIC END,
			CanUpdateRecordNoteCIC = CASE WHEN @UseCIC=1 THEN @CanUpdateRecordNoteCIC ELSE CanUpdateRecordNoteCIC END,
			CanDeleteRecordNoteVOL = CASE WHEN @UseVOL=1 THEN @CanDeleteRecordNoteVOL ELSE CanDeleteRecordNoteVOL END,
			CanUpdateRecordNoteVOL = CASE WHEN @UseVOL=1 THEN @CanUpdateRecordNoteVOL ELSE CanUpdateRecordNoteVOL END,
			RecordNoteTypeOptionalCIC = CASE WHEN @UseCIC=1 THEN @RecordNoteTypeOptionalCIC ELSE CanUpdateRecordNoteCIC END,
			RecordNoteTypeOptionalVOL = CASE WHEN @UseVOL=1 THEN @RecordNoteTypeOptionalVOL ELSE RecordNoteTypeOptionalVOL END,
			PreventDuplicateOrgNames = CASE WHEN @UseCIC=1 THEN @PreventDuplicateOrgNames ELSE PreventDuplicateOrgNames END,
			UseLowestNUM = CASE WHEN @UseCIC=1 THEN @UseLowestNUM ELSE UseLowestNUM END,
			UseOfflineTools = CASE WHEN @UseCIC=1 THEN @UseOfflineTools ELSE UseOfflineTools END,
			OnlySpecificInterests = CASE WHEN @UseVOL=1 THEN @OnlySpecificInterests ELSE OnlySpecificInterests END,
			ImportNotificationEmailCIC = CASE WHEN @UseCIC=1 THEN @ImportNotificationEmailCIC ELSE ImportNotificationEmailCIC END,
			LoginRetryLimit = CASE WHEN @LoginRetryLimit = 0 THEN NULL ELSE @LoginRetryLimit END,
            ContactOrgCIC = CASE WHEN @UseCIC=1 THEN @ContactOrgCIC ELSE ContactOrgCIC END,
            ContactPhone1CIC = CASE WHEN @UseCIC=1 THEN @ContactPhone1CIC ELSE ContactPhone1CIC END,
            ContactPhone2CIC = CASE WHEN @UseCIC=1 THEN @ContactPhone2CIC ELSE ContactPhone2CIC END,
            ContactPhone3CIC = CASE WHEN @UseCIC=1 THEN @ContactPhone3CIC ELSE ContactPhone3CIC END,
            ContactFaxCIC = CASE WHEN @UseCIC=1 THEN @ContactFaxCIC ELSE ContactFaxCIC END,
            ContactEmailCIC = CASE WHEN @UseCIC=1 THEN @ContactEmailCIC ELSE ContactEmailCIC END,
            ContactOrgVOL = CASE WHEN @UseVOL=1 THEN @ContactOrgVOL ELSE ContactOrgVOL END,
            ContactPhone1VOL = CASE WHEN @UseVOL=1 THEN @ContactPhone1VOL ELSE ContactPhone1VOL END,
            ContactPhone2VOL = CASE WHEN @UseVOL=1 THEN @ContactPhone2VOL ELSE ContactPhone2VOL END,
            ContactPhone3VOL = CASE WHEN @UseVOL=1 THEN @ContactPhone3VOL ELSE ContactPhone3VOL END,
            ContactFaxVOL = CASE WHEN @UseVOL=1 THEN @ContactFaxVOL ELSE ContactFaxVOL END,
            ContactEmailVOL = CASE WHEN @UseVOL=1 THEN @ContactEmailVOL ELSE ContactEmailVOL END
	WHERE MemberID=@MemberID
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @GeneralSetupObjectName, @ErrMsg

	IF @Error=0 BEGIN
		UPDATE memd SET
			MODIFIED_BY = @MODIFIED_BY,
			MODIFIED_DATE = GETDATE(),
			DatabaseNameCIC = CASE WHEN @UseCIC=1 THEN nt.DatabaseNameCIC ELSE memd.DatabaseNameCIC END,
			DatabaseNameVOL = CASE WHEN @UseVOL=1 THEN nt.DatabaseNameVOL ELSE memd.DatabaseNameVOL END,
			FeedbackMsgCIC = CASE WHEN @UseCIC=1 THEN nt.FeedbackMsgCIC ELSE memd.FeedbackMsgCIC END,
			FeedbackMsgVOL = CASE WHEN @UseVOL=1 THEN nt.FeedbackMsgVOL ELSE memd.FeedbackMsgVOL END,
			VolProfilePrivacyPolicy = CASE WHEN @UseVOL=1 THEN nt.VolProfilePrivacyPolicy ELSE memd.VolProfilePrivacyPolicy END,
			VolProfilePrivacyPolicyOrgName = CASE WHEN @UseVOL=1 THEN nt.VolProfilePrivacyPolicyOrgName ELSE memd.VolProfilePrivacyPolicyOrgName END,
            SubsidyNamedProgram = CASE WHEN @UseCIC=1 THEN nt.SubsidyNamedProgram ELSE memd.SubsidyNamedProgram END,
            SubsidyNamedProgramDesc = CASE WHEN @UseCIC=1 THEN nt.SubsidyNamedProgramDesc ELSE memd.SubsidyNamedProgramDesc END,
            SubsidyNamedProgramSearchLabel = CASE WHEN @UseCIC=1 THEN nt.SubsidyNamedProgramSearchLabel ELSE memd.SubsidyNamedProgramSearchLabel END
		FROM dbo.STP_Member_Description memd
		INNER JOIN @DescTable nt
			ON memd.LangID=nt.LangID
		WHERE memd.MemberID=@MemberID

		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @GeneralSetupObjectName, @ErrMsg
	
		INSERT INTO dbo.STP_Member_Description (
			MemberID,
			LangID,
			CREATED_BY,
			CREATED_DATE,
			MODIFIED_BY,
			MODIFIED_DATE,
			DatabaseNameCIC,
			DatabaseNameVOL,
			FeedbackMsgCIC,
			FeedbackMsgVOL,
			VolProfilePrivacyPolicy,
			VolProfilePrivacyPolicyOrgName,
            SubsidyNamedProgram,
            SubsidyNamedProgramDesc,
            SubsidyNamedProgramSearchLabel
		)
		SELECT
			@MemberID,
			nt.LangID,
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			CASE WHEN @UseCIC=1 THEN nt.DatabaseNameCIC ELSE NULL END,
			CASE WHEN @UseVOL=1 THEN nt.DatabaseNameVOL ELSE NULL END,
			CASE WHEN @UseCIC=1 THEN nt.FeedbackMsgCIC ELSE NULL END,
			CASE WHEN @UseVOL=1 THEN nt.FeedbackMsgVOL ELSE NULL END,
			CASE WHEN @UseVOL=1 THEN nt.VolProfilePrivacyPolicy ELSE NULL END,
			CASE WHEN @UseVOL=1 THEN nt.VolProfilePrivacyPolicyOrgName ELSE NULL END,
            CASE WHEN @UseCIC=1 THEN nt.SubsidyNamedProgram ELSE NULL END,
            CASE WHEN @UseCIC=1 THEN nt.SubsidyNamedProgramDesc ELSE NULL END,
            CASE WHEN @UseCIC=1 THEN nt.SubsidyNamedProgramSearchLabel ELSE NULL END
		FROM @DescTable nt
		WHERE NOT EXISTS(SELECT * FROM dbo.STP_Member_Description WHERE LangID=nt.LangID AND MemberID=@MemberID)
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @GeneralSetupObjectName, @ErrMsg
	END
END

RETURN @Error

SET NOCOUNT OFF














GO

GRANT EXECUTE ON  [dbo].[sp_STP_Member_u] TO [cioc_login_role]
GO
