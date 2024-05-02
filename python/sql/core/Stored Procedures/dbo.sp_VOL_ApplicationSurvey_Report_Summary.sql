SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_ApplicationSurvey_Report_Summary]
    @MemberID int,
    @APP_ID int,
	@StartDate date,
	@EndDate date
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON;


DECLARE @Error int;
SET @Error = 0;

-- Member ID given ?
IF @MemberID IS NULL BEGIN
    SET @Error = 2; -- No ID Given
 -- Member ID exists ?
END ELSE IF NOT EXISTS (SELECT  * FROM  dbo.STP_Member WHERE MemberID = @MemberID) BEGIN
    SET @Error = 3; -- No Such Record
-- Profile ID given ?
END ELSE IF @APP_ID IS NULL BEGIN
    SET @Error = 2; -- No ID Given
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT  * FROM  dbo.VOL_ApplicationSurvey WHERE APP_ID = @APP_ID) BEGIN
    SET @Error = 3; -- No Such Record
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (
         SELECT *
         FROM   dbo.VOL_ApplicationSurvey
         WHERE  APP_ID = @APP_ID AND MemberID = @MemberID
     ) BEGIN
    SET @Error = 8; -- Security Failure
END

SELECT
	vs.Name AS SurveyName,
	l.LanguageName,
	COUNT(*) AS SurveyCount,
	cioc_shared.dbo.fn_SHR_GBL_DateString(MIN(vsr.SURVEY_DATE)) AS FirstSubmissionInRange,
	cioc_shared.dbo.fn_SHR_GBL_DateString(MAX(vsr.SURVEY_DATE)) AS LastSubmissionInRange
FROM    dbo.VOL_ApplicationSurvey vs
INNER JOIN dbo.STP_Language l
	ON l.LangID = vs.LangID
INNER JOIN dbo.VOL_ApplicationSurvey_Referral vsr
	ON vsr.APP_ID = vs.APP_ID
WHERE   vs.MemberID = @MemberID
	AND (@APP_ID IS NULL OR vs.APP_ID = @APP_ID)
	AND (@StartDate IS NULL OR vsr.SURVEY_DATE >= @StartDate)
	AND (@EndDate IS NULL OR vsr.SURVEY_DATE < @EndDate)
GROUP BY vs.Name, l.LanguageName

SELECT
	vsr.ApplicantCity,
	COUNT(*) AS CityCount
FROM    dbo.VOL_ApplicationSurvey vs
INNER JOIN dbo.VOL_ApplicationSurvey_Referral vsr
	ON vsr.APP_ID = vs.APP_ID
WHERE   vs.MemberID = @MemberID
	AND (@APP_ID IS NULL OR vs.APP_ID = @APP_ID)
	AND (@StartDate IS NULL OR vsr.SURVEY_DATE >= @StartDate)
	AND (@EndDate IS NULL OR vsr.SURVEY_DATE < @EndDate)
GROUP BY vs.Name, vsr.ApplicantCity
ORDER BY vsr.ApplicantCity

SELECT
	vs.TextQuestion1 AS Question,
	vsr.TextQuestion1Answer AS Answer,
	COUNT(*) AS AnswerCount
FROM    dbo.VOL_ApplicationSurvey vs
INNER JOIN dbo.VOL_ApplicationSurvey_Referral vsr
	ON vsr.APP_ID = vs.APP_ID
WHERE   vs.MemberID = @MemberID
	AND (@APP_ID IS NULL OR vs.APP_ID = @APP_ID)
	AND (@StartDate IS NULL OR vsr.SURVEY_DATE >= @StartDate)
	AND (@EndDate IS NULL OR vsr.SURVEY_DATE < @EndDate)
	AND vsr.TextQuestion1Answer IS NOT NULL
GROUP BY vs.TextQuestion1, vsr.TextQuestion1Answer
UNION SELECT
	vs.TextQuestion2 AS Question,
	vsr.TextQuestion2Answer AS Answer,
	COUNT(*) AS AnswerCount
FROM    dbo.VOL_ApplicationSurvey vs
INNER JOIN dbo.VOL_ApplicationSurvey_Referral vsr
	ON vsr.APP_ID = vs.APP_ID
WHERE   vs.MemberID = @MemberID
	AND (@APP_ID IS NULL OR vs.APP_ID = @APP_ID)
	AND (@StartDate IS NULL OR vsr.SURVEY_DATE >= @StartDate)
	AND (@EndDate IS NULL OR vsr.SURVEY_DATE < @EndDate)
	AND vsr.TextQuestion2Answer IS NOT NULL
GROUP BY vs.TextQuestion2, vsr.TextQuestion2Answer
UNION SELECT
	vs.TextQuestion3 AS Question,
	vsr.TextQuestion3Answer AS Answer,
	COUNT(*) AS AnswerCount
FROM    dbo.VOL_ApplicationSurvey vs
INNER JOIN dbo.VOL_ApplicationSurvey_Referral vsr
	ON vsr.APP_ID = vs.APP_ID
WHERE   vs.MemberID = @MemberID
	AND (@APP_ID IS NULL OR vs.APP_ID = @APP_ID)
	AND (@StartDate IS NULL OR vsr.SURVEY_DATE >= @StartDate)
	AND (@EndDate IS NULL OR vsr.SURVEY_DATE < @EndDate)
	AND vsr.TextQuestion3Answer IS NOT NULL
GROUP BY vs.TextQuestion3, vsr.TextQuestion3Answer
UNION SELECT
	vs.DDQuestion1 AS Question,
	vsr.DDQuestion1Answer AS Answer,
	COUNT(*) AS AnswerCount
FROM    dbo.VOL_ApplicationSurvey vs
INNER JOIN dbo.VOL_ApplicationSurvey_Referral vsr
	ON vsr.APP_ID = vs.APP_ID
WHERE   vs.MemberID = @MemberID
	AND (@APP_ID IS NULL OR vs.APP_ID = @APP_ID)
	AND (@StartDate IS NULL OR vsr.SURVEY_DATE >= @StartDate)
	AND (@EndDate IS NULL OR vsr.SURVEY_DATE < @EndDate)
	AND vsr.DDQuestion1Answer IS NOT NULL
GROUP BY vs.DDQuestion1, vsr.DDQuestion1Answer
UNION SELECT
	vs.DDQuestion2 AS Question,
	vsr.DDQuestion2Answer AS Answer,
	COUNT(*) AS AnswerCount
FROM    dbo.VOL_ApplicationSurvey vs
INNER JOIN dbo.VOL_ApplicationSurvey_Referral vsr
	ON vsr.APP_ID = vs.APP_ID
WHERE   vs.MemberID = @MemberID
	AND (@APP_ID IS NULL OR vs.APP_ID = @APP_ID)
	AND (@StartDate IS NULL OR vsr.SURVEY_DATE >= @StartDate)
	AND (@EndDate IS NULL OR vsr.SURVEY_DATE < @EndDate)
	AND vsr.DDQuestion2Answer IS NOT NULL
GROUP BY vs.DDQuestion2, vsr.DDQuestion2Answer
UNION SELECT
	vs.DDQuestion3 AS Question,
	vsr.DDQuestion3Answer AS Answer,
	COUNT(*) AS AnswerCount
FROM    dbo.VOL_ApplicationSurvey vs
INNER JOIN dbo.VOL_ApplicationSurvey_Referral vsr
	ON vsr.APP_ID = vs.APP_ID
WHERE   vs.MemberID = @MemberID
	AND (@APP_ID IS NULL OR vs.APP_ID = @APP_ID)
	AND (@StartDate IS NULL OR vsr.SURVEY_DATE >= @StartDate)
	AND (@EndDate IS NULL OR vsr.SURVEY_DATE < @EndDate)
	AND vsr.DDQuestion3Answer IS NOT NULL
GROUP BY vs.Name, vs.DDQuestion3, vsr.DDQuestion3Answer
ORDER BY Question, AnswerCount DESC

RETURN @Error;

SET NOCOUNT OFF;

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ApplicationSurvey_Report_Summary] TO [cioc_login_role]
GO
