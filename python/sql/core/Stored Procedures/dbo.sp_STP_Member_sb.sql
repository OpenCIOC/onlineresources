SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_STP_Member_sb] (
	@MemberID [int],
	@ErrMsg [nvarchar](255) OUTPUT
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked by: KL
	Checked on: 25-Jul-2018
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(60)
SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')

IF @MemberID IS NULL AND NOT EXISTS(SELECT * FROM STP_Member) BEGIN
	/* Ensure there is a at least one entry in STP_Member table */
	EXEC @Error = dbo.sp_STP_Member_Check '(Init)', NULL, NULL, @MemberID OUTPUT, @ErrMsg OUTPUT
END ELSE IF @MemberID IS NULL AND (SELECT COUNT(*) FROM STP_Member)=1 BEGIN
	SELECT TOP 1 @MemberID=MemberID FROM STP_Member
END

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
END

IF @Error <> 0 BEGIN
	SET @MemberID = NULL
END

/* Select fields */
SELECT	MemberID,
		DatabaseCode,
		CAST(CASE WHEN EXISTS(SELECT * FROM STP_Member WHERE MemberID<>mem.MemberID) THEN 1 ELSE 0 END AS bit) AS OtherMembers,
		CAST(CASE WHEN EXISTS(SELECT * FROM STP_Member WHERE MemberID<>mem.MemberID AND Active=1) THEN 1 ELSE 0 END AS bit) AS OtherMembersActive,
		(SELECT Culture FROM STP_Language sln WHERE sln.LangID=DefaultLangID) AS DefaultCulture,
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
		BillingInfoPassword,
		(SELECT FullSSLCompatible_Cache FROM GBL_Template WHERE Template_ID=DefaultTemplate) AS TemplateFullSSLCompatible,
		(SELECT FullSSLCompatible_Cache FROM GBL_Template WHERE Template_ID=DefaultPrintTemplate) AS PrintFullSSLCompatible,
		CAST(ISNULL((SELECT CASE WHEN m.FullSSLCompatible=1 AND t.FullSSLCompatible_Cache=1 THEN 1 ELSE 0 END FROM GBL_View_DomainMap m INNER JOIN CIC_View vw ON vw.ViewType = ISNULL(m.CICViewType, mem.DefaultViewCIC) INNER JOIN GBL_Template t ON t.Template_ID = vw.Template WHERE m.DomainName=mem.BaseURLCIC), 0) AS bit) AS FullSSLCompatibleBaseURLCIC,
		CAST(ISNULL((SELECT CASE WHEN m.FullSSLCompatible=1 AND t.FullSSLCompatible_Cache=1 THEN 1 ELSE 0 END FROM GBL_View_DomainMap m INNER JOIN CIC_View vw ON vw.ViewType = ISNULL(m.VOLViewType, mem.DefaultViewVOL) INNER JOIN GBL_Template t ON t.Template_ID = vw.Template WHERE m.DomainName=mem.BaseURLCIC), 0) AS bit) AS FullSSLCompatibleBaseURLVOL,
		CAST(ISNULL((SELECT m.FullSSLCompatible FROM GBL_View_DomainMap m WHERE m.DomainName=mem.BaseURLCIC), 0) AS bit) AS DomainFullSSLCompatibleBaseURLCIC,
		CAST(ISNULL((SELECT m.FullSSLCompatible FROM GBL_View_DomainMap m WHERE m.DomainName=mem.BaseURLCIC), 0) AS bit) AS DomainFullSSLCompatibleBaseURLVOL
FROM STP_Member mem
WHERE MemberID=@MemberID
	AND Active=1

SELECT	sln.Culture, sln.LangID,
		MemberName,
		MemberNameCIC,
		MemberNameVOL,
		DatabaseNameCIC,
		DatabaseNameVOL,
		FeedbackMsgCIC,
		FeedbackMsgVOL,
		VolProfilePrivacyPolicy,
		VolProfilePrivacyPolicyOrgName		
	FROM STP_Language sln
	LEFT JOIN STP_Member_Description memd
		ON sln.LangID=memd.LangID AND MemberID=@MemberID
WHERE sln.ActiveRecord=1

RETURN @Error

SET NOCOUNT OFF





GO







GRANT EXECUTE ON  [dbo].[sp_STP_Member_sb] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_STP_Member_sb] TO [cioc_login_role]
GO
