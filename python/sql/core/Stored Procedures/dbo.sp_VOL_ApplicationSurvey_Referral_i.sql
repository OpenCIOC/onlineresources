SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_ApplicationSurvey_Referral_i]
	@APP_ID int OUTPUT,
	@ApplicantCity nvarchar(100),
	@TextQuestion1 nvarchar(500),
	@TextQuestion2 nvarchar(500),
	@TextQuestion3 nvarchar(500),
	@DDQuestion1 nvarchar(500),
	@DDQuestion2 nvarchar(500),
	@DDQuestion3 nvarchar(500),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		int 	
SET @Error = 0

DECLARE	@SurveyObjectName nvarchar(100)
SET @SurveyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Survey')


IF @APP_ID IS NULL OR NOT EXISTS(SELECT * FROM dbo.VOL_ApplicationSurvey WHERE APP_ID=@APP_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@APP_ID AS varchar), @SurveyObjectName)
END ELSE BEGIN
	INSERT INTO dbo.VOL_ApplicationSurvey_Referral (
		SURVEY_DATE,
		APP_ID,
		ApplicantCity,
		TextQuestion1Answer,
		TextQuestion2Answer,
		TextQuestion3Answer,
		DDQuestion1Answer,
		DDQuestion2Answer,
		DDQuestion3Answer
	)
	VALUES
	(   GETDATE(),   -- SURVEY_DATE - smalldatetime
		@APP_ID,      -- APP_ID - int
		@ApplicantCity,   -- ApplicantCity - nvarchar(150)
		@TextQuestion1,   -- TextQuestion1Answer - nvarchar(max)
		@TextQuestion2,   -- TextQuestion2Answer - nvarchar(max)
		@TextQuestion3,   -- TextQuestion3Answer - nvarchar(max)
		@DDQuestion1,   -- DDQuestion1Answer - nvarchar(max)
		@DDQuestion2,   -- DDQuestion2Answer - nvarchar(max)
		@DDQuestion3    -- DDQuestion3Answer - nvarchar(max)
		) 
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SurveyObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ApplicationSurvey_Referral_i] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ApplicationSurvey_Referral_i] TO [cioc_vol_search_role]
GO
