SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_ApplicationSurvey_Report_Detail]
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
	cioc_shared.dbo.fn_SHR_GBL_DateString(vsr.SURVEY_DATE) AS SurveyDate,
	vsr.ApplicantCity,
	vs.TextQuestion1,
	vsr.TextQuestion1Answer,
	vs.TextQuestion2,
	vsr.TextQuestion2Answer,
	vs.TextQuestion3,
	vsr.TextQuestion3Answer,
	vs.DDQuestion1,
	vsr.DDQuestion1Answer,
	vs.DDQuestion2,
	vsr.DDQuestion2Answer,
	vs.DDQuestion3,
	vsr.DDQuestion3Answer
FROM    dbo.VOL_ApplicationSurvey vs
INNER JOIN dbo.STP_Language l
	ON l.LangID = vs.LangID
INNER JOIN dbo.VOL_ApplicationSurvey_Referral vsr
	ON vsr.APP_ID = vs.APP_ID
WHERE   vs.MemberID = @MemberID
	AND (@APP_ID IS NULL OR vs.APP_ID = @APP_ID)
	AND (@StartDate IS NULL OR vsr.SURVEY_DATE >= @StartDate)
	AND (@EndDate IS NULL OR vsr.SURVEY_DATE < @EndDate)

RETURN @Error;

SET NOCOUNT OFF;

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ApplicationSurvey_Report_Detail] TO [cioc_login_role]
GO
