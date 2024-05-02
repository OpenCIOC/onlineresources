SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_ApplicationSurvey_d] (
	@MemberID [int],
	@APP_ID int,
	@ErrMsg nvarchar(500) OUTPUT
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@SurveyObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SurveyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Survey')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @SurveyObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Page ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM dbo.VOL_ApplicationSurvey WHERE APP_ID=@APP_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@APP_ID AS varchar(20)), @SurveyObjectName)
-- Page belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.VOL_ApplicationSurvey WHERE APP_ID=@APP_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE BEGIN

UPDATE memd
	SET memd.VolunteerApplicationSurvey = NULL
FROM dbo.STP_Member_Description memd
	WHERE memd.MemberID=@MemberID AND memd.VolunteerApplicationSurvey=@APP_ID

DELETE 
	FROM dbo.VOL_ApplicationSurvey
WHERE APP_ID=@APP_ID AND MemberID=@MemberID

END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ApplicationSurvey_d] TO [cioc_login_role]
GO
