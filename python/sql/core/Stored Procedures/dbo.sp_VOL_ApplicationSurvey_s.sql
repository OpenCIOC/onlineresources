SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_ApplicationSurvey_s]
    @MemberID int,
    @APP_ID int
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
END;

SELECT
    vs.APP_ID,
    vs.CREATED_DATE,
    vs.CREATED_BY,
    vs.MODIFIED_DATE,
    vs.MODIFIED_BY,
	CASE WHEN EXISTS(SELECT * FROM dbo.STP_Member_Description memd WHERE memd.VolunteerApplicationSurvey = vs.APP_ID) THEN 1 ELSE 0 END AS IN_USE,
	CASE WHEN vs.ARCHIVED_DATE IS NULL THEN 0 ELSE 1 END AS Archived,
    cioc_shared.dbo.fn_SHR_GBL_DateString(vs.ARCHIVED_DATE) AS ARCHIVED_DATE,
    vs.MemberID,
	l.Culture,
    l.LanguageName,
    vs.Name,
    vs.Title,
    vs.Description,
    vs.TextQuestion1,
    vs.TextQuestion2,
    vs.TextQuestion3,
    vs.TextQuestion1Help,
    vs.TextQuestion2Help,
    vs.TextQuestion3Help,
    vs.DDQuestion1,
    vs.DDQuestion2,
    vs.DDQuestion3,
    vs.DDQuestion1Help,
    vs.DDQuestion2Help,
    vs.DDQuestion3Help,
    vs.DDQuestion1Opt1,
    vs.DDQuestion1Opt2,
    vs.DDQuestion1Opt3,
    vs.DDQuestion1Opt4,
    vs.DDQuestion1Opt5,
    vs.DDQuestion1Opt6,
    vs.DDQuestion1Opt7,
    vs.DDQuestion1Opt8,
    vs.DDQuestion1Opt9,
    vs.DDQuestion1Opt10,
    vs.DDQuestion2Opt1,
    vs.DDQuestion2Opt2,
    vs.DDQuestion2Opt3,
    vs.DDQuestion2Opt4,
    vs.DDQuestion2Opt5,
    vs.DDQuestion2Opt6,
    vs.DDQuestion2Opt7,
    vs.DDQuestion2Opt8,
    vs.DDQuestion2Opt9,
    vs.DDQuestion2Opt10,
    vs.DDQuestion3Opt1,
    vs.DDQuestion3Opt2,
    vs.DDQuestion3Opt3,
    vs.DDQuestion3Opt4,
    vs.DDQuestion3Opt5,
    vs.DDQuestion3Opt6,
    vs.DDQuestion3Opt7,
    vs.DDQuestion3Opt8,
    vs.DDQuestion3Opt9,
    vs.DDQuestion3Opt10,
	vsri.COMPLETED,
	cioc_shared.dbo.fn_SHR_GBL_DateString(vsri.FIRST_DATE) AS FIRST_DATE,
	cioc_shared.dbo.fn_SHR_GBL_DateString(vsri.LAST_DATE) AS LAST_DATE,
	vsri.T1QC,
	vsri.T2QC,
	vsri.T3QC,
	vsri.DD1QC,
	vsri.DD2QC,
	vsri.DD3QC
FROM    dbo.VOL_ApplicationSurvey vs
INNER JOIN dbo.STP_Language l
	ON l.LangID = vs.LangID,
(
	SELECT COUNT(*) AS COMPLETED,
		MIN(vsr.SURVEY_DATE) AS FIRST_DATE,
		MAX(vsr.SURVEY_DATE) AS LAST_DATE,
		COUNT(vsr.TextQuestion1Answer) AS T1QC,
		COUNT(vsr.TextQuestion2Answer) AS T2QC,
		COUNT(vsr.TextQuestion3Answer) AS T3QC,
		COUNT(vsr.DDQuestion1Answer) AS DD1QC,
		COUNT(vsr.DDQuestion2Answer) AS DD2QC,
		COUNT(vsr.DDQuestion3Answer) AS DD3QC
		FROM dbo.VOL_ApplicationSurvey_Referral vsr
	WHERE vsr.APP_ID=@APP_ID
) vsri
WHERE   vs.MemberID = @MemberID AND vs.APP_ID = @APP_ID;

RETURN @Error;

SET NOCOUNT OFF;



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ApplicationSurvey_s] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ApplicationSurvey_s] TO [cioc_vol_search_role]
GO
