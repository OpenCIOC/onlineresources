SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_ApplicationSurvey_s]
	@MemberID int,
	@APP_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON


DECLARE 	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- Profile ID given ?
END ELSE IF @APP_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM dbo.VOL_ApplicationSurvey WHERE APP_ID=@APP_ID) BEGIN
	SET @Error = 3 -- No Such Record
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM dbo.VOL_ApplicationSurvey WHERE APP_ID=@APP_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT vs.APP_ID,
       vs.CREATED_DATE,
       vs.CREATED_BY,
       vs.MODIFIED_DATE,
       vs.MODIFIED_BY,
       vs.ARCHIVED_DATE,
       vs.MemberID,
       vs.LangID,
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
       vs.DDQuestion2Opt1,
       vs.DDQuestion2Opt2,
       vs.DDQuestion2Opt3,
       vs.DDQuestion2Opt4,
       vs.DDQuestion2Opt5,
       vs.DDQuestion2Opt6,
       vs.DDQuestion3Opt1,
       vs.DDQuestion3Opt2,
       vs.DDQuestion3Opt3,
       vs.DDQuestion3Opt4,
       vs.DDQuestion3Opt5,
       vs.DDQuestion3Opt6
	FROM dbo.VOL_ApplicationSurvey vs
WHERE MemberID = @MemberID
	AND APP_ID = @APP_ID

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ApplicationSurvey_s] TO [cioc_login_role]
GO
