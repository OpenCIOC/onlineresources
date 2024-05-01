SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_ApplicationSurvey_u]
	@APP_ID int OUTPUT,
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@Culture varchar(5),
	@Archived bit,
	@Name nvarchar(255),
	@Title nvarchar(500),
	@Description nvarchar(max),
	@TextQuestion1 nvarchar(500),
	@TextQuestion2 nvarchar(500),
	@TextQuestion3 nvarchar(500),
	@TextQuestion1Help nvarchar(max),
	@TextQuestion2Help nvarchar(max),
	@TextQuestion3Help nvarchar(max),
	@DDQuestion1 nvarchar(500),
	@DDQuestion2 nvarchar(500),
	@DDQuestion3 nvarchar(500),
	@DDQuestion1Help nvarchar(max),
	@DDQuestion2Help nvarchar(max),
	@DDQuestion3Help nvarchar(max),
	@DDQuestion1Opt1 nvarchar(150),
	@DDQuestion1Opt2 nvarchar(150),
	@DDQuestion1Opt3 nvarchar(150),
	@DDQuestion1Opt4 nvarchar(150),
	@DDQuestion1Opt5 nvarchar(150),
	@DDQuestion1Opt6 nvarchar(150),
	@DDQuestion1Opt7 nvarchar(150),
	@DDQuestion1Opt8 nvarchar(150),
	@DDQuestion1Opt9 nvarchar(150),
	@DDQuestion1Opt10 nvarchar(150),
	@DDQuestion2Opt1 nvarchar(150),
	@DDQuestion2Opt2 nvarchar(150),
	@DDQuestion2Opt3 nvarchar(150),
	@DDQuestion2Opt4 nvarchar(150),
	@DDQuestion2Opt5 nvarchar(150),
	@DDQuestion2Opt6 nvarchar(150),
	@DDQuestion2Opt7 nvarchar(150),
	@DDQuestion2Opt8 nvarchar(150),
	@DDQuestion2Opt9 nvarchar(150),
	@DDQuestion2Opt10 nvarchar(150),
	@DDQuestion3Opt1 nvarchar(150),
	@DDQuestion3Opt2 nvarchar(150),
	@DDQuestion3Opt3 nvarchar(150),
	@DDQuestion3Opt4 nvarchar(150),
	@DDQuestion3Opt5 nvarchar(150),
	@DDQuestion3Opt6 nvarchar(150),
	@DDQuestion3Opt7 nvarchar(150),
	@DDQuestion3Opt8 nvarchar(150),
	@DDQuestion3Opt9 nvarchar(150),
	@DDQuestion3Opt10 nvarchar(150),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		int 	
SET @Error = 0

DECLARE @LangID smallint,
	@ARCHIVED_DATE smalldatetime

SELECT @LangID = LangID FROM dbo.STP_Language WHERE Culture=@Culture AND Active=1
IF @LangID IS NULL SET @LangID=@@LANGID

IF @Archived = 1 BEGIN
	SELECT @ARCHIVED_DATE = ARCHIVED_DATE FROM dbo.VOL_ApplicationSurvey vs WHERE vs.APP_ID=@APP_ID
	SET @ARCHIVED_DATE = ISNULL(@ARCHIVED_DATE,GETDATE())
END

SET @Name = TRIM(@Name)
IF @Name = '' SET @Name = NULL

DECLARE	@MemberObjectName nvarchar(100),
		@SurveyObjectName nvarchar(100),
		@NameObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SurveyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Survey')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')


IF @APP_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.VOL_ApplicationSurvey WHERE APP_ID=@APP_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@APP_ID AS varchar), @SurveyObjectName)
END ELSE IF @APP_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.VOL_ApplicationSurvey WHERE APP_ID=@APP_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE IF @Name IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @SurveyObjectName)
END ELSE IF EXISTS(SELECT *
		FROM dbo.VOL_ApplicationSurvey
		WHERE Name=@Name
			AND MemberID=@MemberID
			AND (@APP_ID IS NULL OR APP_ID<>@APP_ID)
		) BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Name, @NameObjectName)
-- Survey ID Exists ?
END ELSE IF @APP_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.VOL_ApplicationSurvey WHERE APP_ID=@APP_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@APP_ID AS varchar), @SurveyObjectName)
END ELSE BEGIN
	IF @APP_ID IS NULL BEGIN
		INSERT INTO dbo.VOL_ApplicationSurvey (
		    CREATED_DATE,
		    CREATED_BY,
		    MODIFIED_DATE,
		    MODIFIED_BY,
		    ARCHIVED_DATE,
		    MemberID,
		    LangID,
		    Name,
		    Title,
		    Description,
		    TextQuestion1,
		    TextQuestion2,
		    TextQuestion3,
		    TextQuestion1Help,
		    TextQuestion2Help,
		    TextQuestion3Help,
		    DDQuestion1,
		    DDQuestion2,
		    DDQuestion3,
		    DDQuestion1Help,
		    DDQuestion2Help,
		    DDQuestion3Help,
		    DDQuestion1Opt1,
		    DDQuestion1Opt2,
		    DDQuestion1Opt3,
		    DDQuestion1Opt4,
		    DDQuestion1Opt5,
		    DDQuestion1Opt6,
			DDQuestion1Opt7,
		    DDQuestion1Opt8,
		    DDQuestion1Opt9,
		    DDQuestion1Opt10,
		    DDQuestion2Opt1,
		    DDQuestion2Opt2,
		    DDQuestion2Opt3,
		    DDQuestion2Opt4,
		    DDQuestion2Opt5,
		    DDQuestion2Opt6,
			DDQuestion2Opt7,
		    DDQuestion2Opt8,
		    DDQuestion2Opt9,
		    DDQuestion2Opt10,
		    DDQuestion3Opt1,
		    DDQuestion3Opt2,
		    DDQuestion3Opt3,
		    DDQuestion3Opt4,
		    DDQuestion3Opt5,
		    DDQuestion3Opt6,
			DDQuestion3Opt7,
		    DDQuestion3Opt8,
		    DDQuestion3Opt9,
		    DDQuestion3Opt10
		)
		VALUES
		(   GETDATE(),
		    @MODIFIED_BY,
		    GETDATE(),
		    @MODIFIED_BY,
		    @ARCHIVED_DATE,
		    @MemberID,
		    @LangID,
		    @Name,
		    @Title,
		    @Description,
		    @TextQuestion1,
		    @TextQuestion2,
		    @TextQuestion3,
		    @TextQuestion1Help,
		    @TextQuestion2Help,
		    @TextQuestion3Help,
		    @DDQuestion1,
		    @DDQuestion2,
		    @DDQuestion3,
		    @DDQuestion1Help,
		    @DDQuestion2Help,
		    @DDQuestion3Help,
		    @DDQuestion1Opt1,
		    @DDQuestion1Opt2,
		    @DDQuestion1Opt3,
		    @DDQuestion1Opt4,
		    @DDQuestion1Opt5,
		    @DDQuestion1Opt6,
			@DDQuestion1Opt7,
		    @DDQuestion1Opt8,
		    @DDQuestion1Opt9,
		    @DDQuestion1Opt10,
		    @DDQuestion2Opt1,
		    @DDQuestion2Opt2,
		    @DDQuestion2Opt3,
		    @DDQuestion2Opt4,
		    @DDQuestion2Opt5,
		    @DDQuestion2Opt6,
			@DDQuestion2Opt7,
		    @DDQuestion2Opt8,
		    @DDQuestion2Opt9,
		    @DDQuestion2Opt10,
		    @DDQuestion3Opt1,
		    @DDQuestion3Opt2,
		    @DDQuestion3Opt3,
		    @DDQuestion3Opt4,
		    @DDQuestion3Opt5,
		    @DDQuestion3Opt6,
			@DDQuestion3Opt7,
		    @DDQuestion3Opt8,
		    @DDQuestion3Opt9,
		    @DDQuestion3Opt10
		    )
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SurveyObjectName, @ErrMsg
		SET @APP_ID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE VOL_ApplicationSurvey  SET
			MODIFIED_DATE	= GETDATE(),
		    MODIFIED_BY		= @MODIFIED_BY,
		    ARCHIVED_DATE	= @ARCHIVED_DATE,
		    Name			= @Name,
		    Title			= @Title,
		    Description		= @Description,
		    TextQuestion1	= @TextQuestion1,
		    TextQuestion2	= @TextQuestion2,
		    TextQuestion3	= @TextQuestion3,
		    TextQuestion1Help	= @TextQuestion1Help,
		    TextQuestion2Help	= @TextQuestion2Help,
		    TextQuestion3Help	= @TextQuestion3Help,
		    DDQuestion1		= @DDQuestion1,
		    DDQuestion2		= @DDQuestion2,
		    DDQuestion3		= @DDQuestion3,
		    DDQuestion1Help	= @DDQuestion1Help,
		    DDQuestion2Help	= @DDQuestion2Help,
		    DDQuestion3Help	= @DDQuestion3Help,
		    DDQuestion1Opt1	= @DDQuestion1Opt1,
		    DDQuestion1Opt2	= @DDQuestion1Opt2,
		    DDQuestion1Opt3	= @DDQuestion1Opt3,
		    DDQuestion1Opt4	= @DDQuestion1Opt4,
		    DDQuestion1Opt5	= @DDQuestion1Opt5,
		    DDQuestion1Opt6	= @DDQuestion1Opt6,
			DDQuestion1Opt7	= @DDQuestion1Opt7,
		    DDQuestion1Opt8	= @DDQuestion1Opt8,
		    DDQuestion1Opt9	= @DDQuestion1Opt9,
		    DDQuestion1Opt10	= @DDQuestion1Opt10,
		    DDQuestion2Opt1	= @DDQuestion2Opt1,
		    DDQuestion2Opt2	= @DDQuestion2Opt2,
		    DDQuestion2Opt3	= @DDQuestion2Opt3,
		    DDQuestion2Opt4	= @DDQuestion2Opt4,
		    DDQuestion2Opt5	= @DDQuestion2Opt5,
		    DDQuestion2Opt6	= @DDQuestion2Opt6,
			DDQuestion2Opt7	= @DDQuestion2Opt7,
		    DDQuestion2Opt8	= @DDQuestion2Opt8,
		    DDQuestion2Opt9	= @DDQuestion2Opt9,
		    DDQuestion2Opt10	= @DDQuestion2Opt10,
		    DDQuestion3Opt1	= @DDQuestion3Opt1,
		    DDQuestion3Opt2	= @DDQuestion3Opt2,
		    DDQuestion3Opt3	= @DDQuestion3Opt3,
		    DDQuestion3Opt4	= @DDQuestion3Opt4,
		    DDQuestion3Opt5	= @DDQuestion3Opt5,
		    DDQuestion3Opt6	= @DDQuestion3Opt6,
			DDQuestion3Opt7	= @DDQuestion3Opt7,
		    DDQuestion3Opt8	= @DDQuestion3Opt8,
		    DDQuestion3Opt9	= @DDQuestion3Opt9,
		    DDQuestion3Opt10	= @DDQuestion3Opt10
		WHERE APP_ID = @APP_ID
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SurveyObjectName, @ErrMsg
	END

	IF @Error = 0 AND @Archived = 1 BEGIN
		UPDATE memd
			SET memd.VolunteerApplicationSurvey = NULL
		FROM dbo.STP_Member_Description memd
			WHERE memd.MemberID=@MemberID
				AND memd.VolunteerApplicationSurvey=@APP_ID
	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ApplicationSurvey_u] TO [cioc_login_role]
GO
