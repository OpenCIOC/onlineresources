SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Users_u_MyAccount]
	@User_ID int,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@FirstName varchar(50),
	@LastName varchar(50),
	@Initials varchar(6),
	@Email varchar(60),
	@StartModule tinyint,
	@StartLanguage smallint,
	@PasswordHash varchar(44),
	@PasswordHashSalt varchar(44),
	@PasswordHashRepeat int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 18-Mar-2013
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@UserAccountObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @UserAccountObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User Account')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @CanUpdateAccount bit,
		@CanUpdatePassword bit

SELECT @CanUpdateAccount=CanUpdateAccount, @CanUpdatePassword=CanUpdatePassword FROM GBL_Users WHERE [User_ID]=@User_ID

IF @CanUpdateAccount=1 BEGIN
	SET @FirstName = RTRIM(LTRIM(@FirstName))
	IF @FirstName = '' SET @FirstName = NULL
	SET @LastName = RTRIM(LTRIM(@LastName))
	IF @LastName = '' SET @LastName = NULL
	SET @Initials = RTRIM(LTRIM(@Initials))
	IF @Initials = '' SET @Initials = NULL
	SET @Email = RTRIM(LTRIM(@Email))
	IF @Email = '' SET @Email = NULL
END ELSE BEGIN
	SELECT @Email=Email FROM GBL_Users WHERE [User_ID]=@User_ID
END


-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @UserAccountObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- User ID given ?
END ELSE IF @User_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserAccountObjectName, NULL)
-- User exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Users WHERE [User_ID]=@User_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@User_ID AS varchar), @UserAccountObjectName)
-- User belongs to member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Users WHERE MemberID_Cache=@MemberID AND [User_ID]=@User_ID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE IF NOT (@CanUpdateAccount=1 OR @CanUpdatePassword=1) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserAccountObjectName, NULL)
END ELSE IF @PasswordHash IS NOT NULL AND @CanUpdatePassword=0 BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserAccountObjectName, NULL)
END ELSE IF @CanUpdateAccount=1 AND @FirstName IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('First Name'), @UserAccountObjectName)
END ELSE IF @CanUpdateAccount=1 AND @LastName IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Last Name'), @UserAccountObjectName)
END ELSE IF @CanUpdateAccount=1 AND @Initials IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Initials'), @UserAccountObjectName)
END ELSE IF @CanUpdateAccount=1 AND @Email IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Email'), @UserAccountObjectName)
-- Start Module given and correct ?
END ELSE IF @CanUpdateAccount=1 AND @StartModule <> 1 AND @StartModule <> 2 BEGIN
	SET @Error = 23 -- No Module
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END ELSE IF @CanUpdateAccount=1 AND @StartLanguage IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @UserAccountObjectName)
END ELSE IF @CanUpdateAccount=1 AND NOT EXISTS (SELECT * FROM STP_Language WHERE LangID = @StartLanguage) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@StartLanguage AS varchar), @LanguageObjectName)
END ELSE BEGIN
	DECLARE @MODIFIED_DATE datetime
	SET @MODIFIED_DATE = GETDATE()

	DECLARE @User_HST_ID int
	
	-- Initials unique ?
	IF @CanUpdateAccount=1 AND EXISTS(SELECT * FROM GBL_Users WHERE (@User_ID IS NULL OR [User_ID] <> @User_ID) AND Initials=@Initials AND MemberID_Cache=@MemberID) BEGIN
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(6, @Initials, cioc_shared.dbo.fn_SHR_STP_ObjectName('Initials'))
	END

	EXEC [dbo].[sp_GBL_Users_History_i]
		@User_HST_ID OUTPUT,
		@User_ID,
		@MODIFIED_DATE,
		@MODIFIED_BY,
		NULL,
		NULL,
		NULL,
		NULL,
		@StartModule,
		@StartLanguage,
		NULL,
		@FirstName,
		@LastName,
		@Initials,
		@Email,
		NULL,
		@PasswordHash,
		NULL,
		NULL,
		NULL,
		0,
		0
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @UserAccountObjectName, @ErrMsg

	UPDATE GBL_Users
		SET	MODIFIED_DATE		= @MODIFIED_DATE,
			MODIFIED_BY			= @MODIFIED_BY,
			FirstName			= CASE WHEN @CanUpdateAccount=1 THEN @FirstName ELSE FirstName END,
			LastName			= CASE WHEN @CanUpdateAccount=1 THEN @LastName ELSE LastName END,
			Initials			= CASE WHEN @CanUpdateAccount=1 THEN @Initials ELSE Initials END,
			Email				= CASE WHEN @CanUpdateAccount=1 THEN @Email ELSE Email END,
			StartModule			= CASE WHEN @CanUpdateAccount=1 THEN @StartModule ELSE StartModule END,
			StartLanguage		= CASE WHEN @CanUpdateAccount=1 THEN @StartLanguage ELSE StartLanguage END,
			PasswordHash		= ISNULL(@PasswordHash,PasswordHash),
			PasswordHashSalt	= ISNULL(@PasswordHashSalt,PasswordHashSalt),
			PasswordHashRepeat	= ISNULL(@PasswordHashRepeat, PasswordHashRepeat),
			PasswordChanged		= CASE WHEN @PasswordHash IS NULL THEN PasswordChanged ELSE @MODIFIED_DATE END,
			PasswordChangedBy	= CASE WHEN @PasswordHash IS NULL THEN PasswordChangedBy ELSE @MODIFIED_BY END
	WHERE [User_ID] = @User_ID
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @UserAccountObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF







GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_u_MyAccount] TO [cioc_login_role]
GO
