SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[sp_GBL_View_DomainMap_Analytics_u]
	@MemberID int,
	@MODIFIED_BY varchar(50),
	@data xml,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: CL
	Checked on: 21-Aug-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@DomainMapObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @DomainMapObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Domain Name Mapping')

DECLARE @DomainTable TABLE (
	DMAP_ID int NOT NULL,
	GoogleAnalyticsCode nvarchar(50),
	GoogleAnalyticsLanguageDimension tinyint,
	GoogleAnalyticsAgencyDimension tinyint,
	GoogleAnalyticsDomainDimension tinyint,
	GoogleAnalyticsResultsCountMetric tinyint,
	SecondGoogleAnalyticsCode nvarchar(50),
	SecondGoogleAnalyticsLanguageDimension tinyint,
	SecondGoogleAnalyticsAgencyDimension tinyint,
	SecondGoogleAnalyticsDomainDimension tinyint,
	SecondGoogleAnalyticsResultsCountMetric tinyint,
	GoogleAnalytics4Code nvarchar(50),
	GoogleAnalytics4LanguageDimension tinyint,
	GoogleAnalytics4AgencyDimension tinyint,
	GoogleAnalytics4DomainDimension tinyint,
	GoogleAnalytics4ResultsCountMetric tinyint,
	SecondGoogleAnalytics4Code nvarchar(50),
	SecondGoogleAnalytics4LanguageDimension tinyint,
	SecondGoogleAnalytics4AgencyDimension tinyint,
	SecondGoogleAnalytics4DomainDimension tinyint,
	SecondGoogleAnalytics4ResultsCountMetric tinyint
)

INSERT INTO @DomainTable
	( DMAP_ID, 
	GoogleAnalyticsCode,
	GoogleAnalyticsLanguageDimension,
	GoogleAnalyticsAgencyDimension,
	GoogleAnalyticsDomainDimension,
	GoogleAnalyticsResultsCountMetric,
	SecondGoogleAnalyticsCode,
	SecondGoogleAnalyticsAgencyDimension,
	SecondGoogleAnalyticsLanguageDimension,
	SecondGoogleAnalyticsDomainDimension,
	SecondGoogleAnalyticsResultsCountMetric, 
	GoogleAnalytics4Code,
	GoogleAnalytics4LanguageDimension,
	GoogleAnalytics4AgencyDimension,
	GoogleAnalytics4DomainDimension,
	GoogleAnalytics4ResultsCountMetric,
	SecondGoogleAnalytics4Code,
	SecondGoogleAnalytics4AgencyDimension,
	SecondGoogleAnalytics4LanguageDimension,
	SecondGoogleAnalytics4DomainDimension,
	SecondGoogleAnalytics4ResultsCountMetric 
	)
SELECT 
	N.value('DMAP_ID[1]', 'int') AS DMAP_ID,
	N.value('GoogleAnalyticsCode[1]', 'nvarchar(50)') AS GoogleAnalyticsCode,
	N.value('GoogleAnalyticsLanguageDimension[1]', 'tinyint') AS GoogleAnalyticsLanguageDimension,
	N.value('GoogleAnalyticsAgencyDimension[1]', 'tinyint') AS GoogleAnalyticsAgencyDimension,
	N.value('GoogleAnalyticsDomainDimension[1]', 'tinyint') AS GoogleAnalyticsDomainDimension,
	N.value('GoogleAnalyticsResultsCountMetric[1]', 'tinyint') AS GoogleAnalyticsResultsCountMetric,
	N.value('SecondGoogleAnalyticsCode[1]', 'nvarchar(50)') AS SecondGoogleAnalyticsCode,
	N.value('SecondGoogleAnalyticsAgencyDimension[1]', 'tinyint') AS SecondGoogleAnalyticsAgencyDimension,
	N.value('SecondGoogleAnalyticsLanguageDimension[1]', 'tinyint') AS SecondGoogleAnalyticsLanguageDimension,
	N.value('SecondGoogleAnalyticsDomainDimension[1]', 'tinyint') AS SecondGoogleAnalyticsDomainDimension,
	N.value('SecondGoogleAnalyticsResultsCountMetric[1]', 'tinyint') AS SecondGoogleAnalyticsResultsCountMetric,
	N.value('GoogleAnalytics4Code[1]', 'nvarchar(50)') AS GoogleAnalyticsCode,
	N.value('GoogleAnalytics4LanguageDimension[1]', 'tinyint') AS GoogleAnalyticsLanguageDimension,
	N.value('GoogleAnalytics4AgencyDimension[1]', 'tinyint') AS GoogleAnalyticsAgencyDimension,
	N.value('GoogleAnalytics4DomainDimension[1]', 'tinyint') AS GoogleAnalyticsDomainDimension,
	N.value('GoogleAnalytics4ResultsCountMetric[1]', 'tinyint') AS GoogleAnalyticsResultsCountMetric,
	N.value('SecondGoogleAnalytics4Code[1]', 'nvarchar(50)') AS SecondGoogleAnalyticsCode,
	N.value('SecondGoogleAnalytics4AgencyDimension[1]', 'tinyint') AS SecondGoogleAnalyticsAgencyDimension,
	N.value('SecondGoogleAnalytics4LanguageDimension[1]', 'tinyint') AS SecondGoogleAnalyticsLanguageDimension,
	N.value('SecondGoogleAnalytics4DomainDimension[1]', 'tinyint') AS SecondGoogleAnalyticsDomainDimension,
	N.value('SecondGoogleAnalytics4ResultsCountMetric[1]', 'tinyint') AS SecondGoogleAnalyticsResultsCountMetric

FROM @data.nodes('//Domain') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DomainMapObjectName, @ErrMsg


-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
END ELSE BEGIN

UPDATE dst SET 
	MODIFIED_DATE = GETDATE(),
	MODIFIED_BY = @MODIFIED_BY,
	GoogleAnalyticsCode = src.GoogleAnalyticsCode,
	GoogleAnalyticsLanguageDimension = src.GoogleAnalyticsLanguageDimension,
	GoogleAnalyticsAgencyDimension = src.GoogleAnalyticsAgencyDimension,
	GoogleAnalyticsDomainDimension = src.GoogleAnalyticsDomainDimension,
	GoogleAnalyticsResultsCountMetric = src.GoogleAnalyticsResultsCountMetric,
	SecondGoogleAnalyticsCode = src.SecondGoogleAnalyticsCode,
	SecondGoogleAnalyticsLanguageDimension = src.SecondGoogleAnalyticsLanguageDimension,
	SecondGoogleAnalyticsAgencyDimension = src.SecondGoogleAnalyticsAgencyDimension,
	SecondGoogleAnalyticsDomainDimension = src.SecondGoogleAnalyticsDomainDimension,
	SecondGoogleAnalyticsResultsCountMetric = src.SecondGoogleAnalyticsResultsCountMetric,
	GoogleAnalytics4Code = src.GoogleAnalytics4Code,
	GoogleAnalytics4LanguageDimension = src.GoogleAnalytics4LanguageDimension,
	GoogleAnalytics4AgencyDimension = src.GoogleAnalytics4AgencyDimension,
	GoogleAnalytics4DomainDimension = src.GoogleAnalytics4DomainDimension,
	GoogleAnalytics4ResultsCountMetric = src.GoogleAnalytics4ResultsCountMetric,
	SecondGoogleAnalytics4Code = src.SecondGoogleAnalytics4Code,
	SecondGoogleAnalytics4LanguageDimension = src.SecondGoogleAnalytics4LanguageDimension,
	SecondGoogleAnalytics4AgencyDimension = src.SecondGoogleAnalytics4AgencyDimension,
	SecondGoogleAnalytics4DomainDimension = src.SecondGoogleAnalytics4DomainDimension,
	SecondGoogleAnalytics4ResultsCountMetric = src.SecondGoogleAnalytics4ResultsCountMetric
FROM GBL_View_DomainMap dst
INNER JOIN @DomainTable src
	ON dst.DMAP_ID=src.DMAP_ID
WHERE dst.MemberID=@MemberID
	
END

SET NOCOUNT OFF











GO
GRANT EXECUTE ON  [dbo].[sp_GBL_View_DomainMap_Analytics_u] TO [cioc_login_role]
GO
