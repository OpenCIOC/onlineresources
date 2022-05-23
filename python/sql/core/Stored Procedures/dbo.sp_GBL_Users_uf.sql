SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Users_uf]
	@User_ID int OUTPUT,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@Inactive bit,
	@UnlockAccount bit,
	@Agency char(3),
	@SL_ID_CIC int,
	@SL_ID_VOL int,
	@StartModule tinyint,
	@StartLanguage smallint,
	@UserName varchar(50),
	@FirstName varchar(50),
	@LastName varchar(50),
	@Initials varchar(6),
	@Email varchar(100),
	@SavedSearchQuota tinyint,
	@PasswordHash varchar(44),
	@PasswordHashSalt varchar(44),
	@PasswordHashRepeat int,
	@SingleLogin bit,
	@CanUpdateAccount bit,
	@CanUpdatePassword bit,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@AgencyObjectName nvarchar(100),
		@UserAccountObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@UserNameObjectName nvarchar(100),
		@UserTypeObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @UserAccountObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User Account')
SET @AgencyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @UserNameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User Name')
SET @UserTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User Type')

SET @UserName = RTRIM(LTRIM(@UserName))
IF @UserName = '' SET @UserName = NULL
SET @FirstName = RTRIM(LTRIM(@FirstName))
IF @FirstName = '' SET @FirstName = NULL
SET @LastName = RTRIM(LTRIM(@LastName))
IF @LastName = '' SET @LastName = NULL
SET @Initials = RTRIM(LTRIM(@Initials))
IF @Initials = '' SET @Initials = NULL
SET @Email = RTRIM(LTRIM(@Email))
IF @Email = '' SET @Email = NULL
SET @SavedSearchQuota = ISNULL(@SavedSearchQuota,0)
SET @SingleLogin = ISNULL(@SingleLogin,0)

IF @CanUpdateAccount IS NULL BEGIN
	SELECT @CanUpdateAccount = UpdateAccountDefault FROM GBL_Agency WHERE AgencyCode=@Agency
END
IF @CanUpdatePassword IS NULL BEGIN
	SELECT @CanUpdatePassword = UpdatePasswordDefault FROM GBL_Agency WHERE AgencyCode=@Agency
END

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @UserAccountObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- User exists ?
END ELSE IF @User_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_Users WHERE [User_ID]=@User_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@User_ID AS varchar), @UserAccountObjectName)
-- User belongs to member ?
END ELSE IF @User_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_Users WHERE MemberID_Cache=@MemberID AND [User_ID]=@User_ID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- User Name given ?
END ELSE IF @UserName IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserNameObjectName, @UserAccountObjectName)
-- User Name unique ?
END ELSE IF EXISTS(SELECT * FROM GBL_Users WHERE (@User_ID IS NULL OR [User_ID] <> @User_ID) AND UserName=@UserName AND MemberID_Cache=@MemberID) BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserName, @UserAccountObjectName)
-- First Name given ?
END ELSE IF @FirstName IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('First Name'), @UserAccountObjectName)
-- Last Name given ?
END ELSE IF @LastName IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Last Name'), @UserAccountObjectName)
-- Initials given ?
END ELSE IF @Initials IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Initials'), @UserAccountObjectName)
-- Start Module given and correct ?
END ELSE IF @StartModule IS NULL OR (@StartModule <> 1 AND @StartModule <> 2) BEGIN
	SET @Error = 23 -- No Module
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
-- Start Language given ?
END ELSE IF @StartLanguage IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @UserAccountObjectName)
-- Start Language Active ?
END ELSE IF NOT EXISTS (SELECT * FROM STP_Language WHERE LangID=@StartLanguage AND Active=1) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@StartLanguage AS varchar), @LanguageObjectName)
-- User Type exists ?
END ELSE IF NOT (@SL_ID_CIC IS NULL OR EXISTS(SELECT * FROM CIC_SecurityLevel WHERE SL_ID=@SL_ID_CIC)) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SL_ID_CIC AS varchar), @UserTypeObjectName)
-- User Type exists ?
END ELSE IF NOT (@SL_ID_VOL IS NULL OR EXISTS(SELECT * FROM VOL_SecurityLevel WHERE SL_ID=@SL_ID_VOL)) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SL_ID_VOL AS varchar), @UserTypeObjectName)
-- Agency given ?
END ELSE IF @Agency IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyObjectName, @UserAccountObjectName)
-- Agency exists ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Agency WHERE AgencyCode=@Agency) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Agency, @AgencyObjectName)
-- Agency belongs to member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Agency WHERE MemberID=@MemberID AND AgencyCode=@Agency) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE BEGIN
	DECLARE @MODIFIED_DATE datetime
	SET @MODIFIED_DATE = GETDATE()

	DECLARE @User_HST_ID int
	
	-- Initials unique ?
	IF EXISTS(SELECT * FROM GBL_Users WHERE (@User_ID IS NULL OR [User_ID] <> @User_ID) AND Initials=@Initials AND MemberID_Cache=@MemberID) BEGIN
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(6, @Initials, cioc_shared.dbo.fn_SHR_STP_ObjectName('Initials'))
	END

	IF @User_ID IS NOT NULL BEGIN
		EXEC [dbo].[sp_GBL_Users_History_i]
			@User_HST_ID OUTPUT,
			@User_ID,
			@MODIFIED_DATE,
			@MODIFIED_BY,
			@Inactive,
			@Agency,
			@SL_ID_CIC,
			@SL_ID_VOL,
			@StartModule,
			@StartLanguage,
			@UserName,
			@FirstName,
			@LastName,
			@Initials,
			@Email,
			@SavedSearchQuota,
			@PasswordHash,
			@SingleLogin,
			@CanUpdateAccount,
			@CanUpdatePassword,
			1,
			0

		UPDATE GBL_Users
			SET	MODIFIED_DATE		= @MODIFIED_DATE,
				MODIFIED_BY			= @MODIFIED_BY,
				Inactive			= @Inactive,
				LoginAttempts		= CASE WHEN @UnlockAccount=1 THEN NULL ELSE LoginAttempts END,
				LastLoginAttempt	= CASE WHEN @UnlockAccount=1 THEN NULL ELSE LastLoginAttempt END,
				LastLoginAttemptIP	= CASE WHEN @UnlockAccount=1 THEN NULL ELSE LastLoginAttemptIP END,
				ActiveStatusChanged		= CASE WHEN Inactive=@Inactive THEN ActiveStatusChanged ELSE @MODIFIED_DATE END,
				ActiveStatusChangedBy	= CASE WHEN Inactive=@Inactive THEN ActiveStatusChangedBy ELSE @MODIFIED_BY END,
				Agency				= @Agency,
				SL_ID_CIC			= @SL_ID_CIC,
				SL_ID_VOL			= @SL_ID_VOL,
				StartModule			= @StartModule,
				StartLanguage		= @StartLanguage,
				UserName			= @UserName,
				FirstName			= @FirstName,
				LastName			= @LastName,
				Initials			= @Initials,
				Email				= @Email,
				SavedSearchQuota	= @SavedSearchQuota ,
				PasswordHash		= ISNULL(@PasswordHash,PasswordHash),
				PasswordHashSalt	= ISNULL(@PasswordHashSalt,PasswordHashSalt),
				PasswordHashRepeat	= ISNULL(@PasswordHashRepeat,PasswordHashRepeat),
				PasswordChanged		= CASE WHEN @PasswordHash IS NULL THEN PasswordChanged ELSE @MODIFIED_DATE END,
				PasswordChangedBy	= CASE WHEN @PasswordHash IS NULL THEN PasswordChangedBy ELSE @MODIFIED_BY END,
				SingleLogin			= @SingleLogin,
				CanUpdateAccount	= @CanUpdateAccount,
				CanUpdatePassword	= @CanUpdatePassword
		WHERE [User_ID] = @User_ID
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @UserAccountObjectName, @ErrMsg
	END ELSE BEGIN
		INSERT INTO GBL_Users (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID_Cache,
			Inactive,
			ActiveStatusChanged,
			ActiveStatusChangedBy,
			Agency,
			SL_ID_CIC,
			SL_ID_VOL,
			StartModule,
			StartLanguage,
			UserName,
			FirstName,
			LastName,
			Initials,
			Email,
			SavedSearchQuota,
			PasswordHash,
			PasswordHashSalt,
			PasswordHashRepeat,
			PasswordChanged,
			PasswordChangedBy,
			SingleLogin,
			CanUpdateAccount,
			CanUpdatePassword
		)
		VALUES (
			@MODIFIED_DATE,
			@MODIFIED_BY,
			@MODIFIED_DATE,
			@MODIFIED_BY,
			@MemberID,
			@Inactive,
			@MODIFIED_DATE,
			@MODIFIED_BY,
			@Agency,
			@SL_ID_CIC,
			@SL_ID_VOL,
			@StartModule,
			@StartLanguage,
			@UserName,
			@FirstName,
			@LastName,
			@Initials,
			@Email,
			@SavedSearchQuota ,
			@PasswordHash,
			@PasswordHashSalt,
			@PasswordHashRepeat,
			@MODIFIED_DATE,
			@MODIFIED_BY,
			@SingleLogin,
			@CanUpdateAccount,
			@CanUpdatePassword
		)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @UserAccountObjectName, @ErrMsg
		SET @User_ID = SCOPE_IDENTITY()
		IF @Error = 0 BEGIN
			EXEC [dbo].[sp_GBL_Users_History_i]
				@User_HST_ID OUTPUT,
				@User_ID,
				@MODIFIED_DATE,
				@MODIFIED_BY,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				1,
				1,
				1
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @UserAccountObjectName, @ErrMsg
		END
	END
END

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_uf] TO [cioc_login_role]
GO
