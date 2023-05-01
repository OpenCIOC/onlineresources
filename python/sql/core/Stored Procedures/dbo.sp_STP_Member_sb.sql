SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_Member_sb] (@MemberID [int], @ErrMsg [nvarchar](255) OUTPUT)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON;

DECLARE @Error int;
SET @Error = 0;

DECLARE @MemberObjectName nvarchar(60);
SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership');

IF @MemberID IS NULL AND NOT EXISTS (SELECT * FROM  STP_Member) BEGIN
    /* Ensure there is a at least one entry in STP_Member table */
    EXEC @Error = dbo.sp_STP_Member_Check '(Init)', NULL, NULL, @MemberID OUTPUT, @ErrMsg OUTPUT;
END;
ELSE IF @MemberID IS NULL AND   (SELECT COUNT(*)FROM    dbo.STP_Member) = 1 BEGIN
    SELECT  TOP 1   @MemberID = MemberID FROM   dbo.STP_Member;
END;

-- Member ID given ?
IF @MemberID IS NULL BEGIN
    SET @Error = 2; -- No ID Given
    SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL);
-- Member ID exists ?
END;
ELSE IF NOT EXISTS (SELECT  * FROM  dbo.STP_Member WHERE MemberID = @MemberID) BEGIN
    SET @Error = 3; -- No Such Record
    SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName);
END;

IF @Error <> 0 BEGIN
    SET @MemberID = NULL;
END;

/* Select fields */
SELECT
    MemberID,
    DatabaseCode,
    CAST(CASE WHEN EXISTS (SELECT * FROM dbo.STP_Member WHERE MemberID <> mem.MemberID) THEN 1 ELSE 0 END AS bit) AS OtherMembers,
    CAST(CASE WHEN EXISTS (SELECT * FROM dbo.STP_Member WHERE MemberID <> mem.MemberID AND Active = 1) THEN 1 ELSE 0 END AS bit) AS OtherMembersActive,
    (SELECT Culture FROM dbo.STP_Language sln WHERE sln.LangID = DefaultLangID) AS DefaultCulture,
    AllowPublicAccess,
    DefaultPrintTemplate,
    PrintModePublic,
    TrainingMode,
    UseInitials,
    DaysSinceLastEmail,
    DefaultEmailTech,
    ClientTrackerIP,
    ClientTrackerRpcURL,
    DefaultGCType,
    DefaultProvince,
    DefaultCountry,
    NoEmail,
    DownloadUncompressed,
    UseCIC,
    DefaultViewCIC,
    BaseURLCIC,
    DefaultEmailCIC,
    DefaultEmailNameCIC,
    SiteCodeLength,
    UseTaxonomy,
    VacancyFundedCapacity,
    VacancyServiceHours,
    VacancyServiceDays,
    VacancyServiceWeeks,
    VacancyServiceFTE,
    CanDeleteRecordNoteCIC,
    CanUpdateRecordNoteCIC,
    RecordNoteTypeOptionalCIC,
    PreventDuplicateOrgNames,
    UseOfflineTools,
    UseVOL,
    DefaultViewVOL,
    BaseURLVOL,
    DefaultEmailVOL,
    DefaultEmailNameVOL,
    UseVolunteerProfiles,
    CanDeleteRecordNoteVOL,
    CanUpdateRecordNoteVOL,
    RecordNoteTypeOptionalVOL,
    OnlySpecificInterests,
    LoginRetryLimit,
    GlobalGoogleAnalyticsCode,
    GlobalGoogleAnalyticsAgencyDimension,
    GlobalGoogleAnalyticsLanguageDimension,
    GlobalGoogleAnalyticsDomainDimension,
    GlobalGoogleAnalyticsResultsCountMetric,
    GlobalGoogleAnalytics4Code,
    GlobalGoogleAnalytics4AgencyDimension,
    GlobalGoogleAnalytics4LanguageDimension,
    GlobalGoogleAnalytics4DomainDimension,
    GlobalGoogleAnalytics4ResultsCountMetric,
    BillingInfoPassword
FROM    dbo.STP_Member mem
WHERE   MemberID = @MemberID AND Active = 1;

SELECT
    sln.Culture,
    sln.LangID,
    memd.MemberName,
    memd.MemberNameCIC,
    memd.MemberNameVOL,
    memd.DatabaseNameCIC,
    memd.DatabaseNameVOL,
    memd.FeedbackMsgCIC,
    memd.FeedbackMsgVOL,
    memd.VolProfilePrivacyPolicy,
    memd.VolProfilePrivacyPolicyOrgName,
    memd.SubsidyNamedProgram
FROM    dbo.STP_Language sln
    LEFT JOIN dbo.STP_Member_Description memd
        ON sln.LangID = memd.LangID AND memd.MemberID = @MemberID
WHERE   sln.ActiveRecord = 1;

RETURN @Error;

SET NOCOUNT OFF;





GO







GRANT EXECUTE ON  [dbo].[sp_STP_Member_sb] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_STP_Member_sb] TO [cioc_login_role]
GO
