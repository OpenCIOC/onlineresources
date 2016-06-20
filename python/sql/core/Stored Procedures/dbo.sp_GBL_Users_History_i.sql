SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Users_History_i]
	@User_HST_ID [int] OUTPUT,
	@User_ID [int],
	@MODIFIED_DATE [datetime],
	@MODIFIED_BY [varchar](50),
	@Inactive [bit],
	@Agency [char](3),
	@SL_ID_CIC [int],
	@SL_ID_VOL [int],
	@StartModule [tinyint],
	@StartLanguage [smallint],
	@UserName [varchar](50),
	@FirstName [varchar](50),
	@LastName [varchar](50),
	@Initials [varchar](6),
	@Email [varchar](50),
	@SavedSearchQuota [tinyint],
	@PasswordHash [char](44),
	@SingleLogin [bit],
	@CanUpdateAccount [bit],
	@CanUpdatePassword [bit],
	@FullUpdate [bit],
	@NewAccount [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/

IF @NewAccount=1 BEGIN
	INSERT INTO GBL_Users_History (
		[User_ID],
		MODIFIED_DATE,
		MODIFIED_BY,
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
		PasswordChange,
		SavedSearchQuota,
		SingleLogin,
		CanUpdateAccount,
		CanUpdatePassword,
		Inactive,
		NewAccount
	)
	SELECT
		User_ID,
		@MODIFIED_DATE,
		@MODIFIED_BY,
		Agency,
		(SELECT TOP 1 SecurityLevel FROM CIC_SecurityLevel_Name WHERE SL_ID=SL_ID_CIC ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID),
		(SELECT TOP 1 SecurityLevel FROM VOL_SecurityLevel_Name WHERE SL_ID=SL_ID_VOL ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID),
		StartModule,
		StartLanguage,
		UserName,
		FirstName,
		LastName,
		Initials,
		Email,
		1,
		SavedSearchQuota,
		SingleLogin,
		CanUpdateAccount,
		CanUpdatePassword,
		Inactive,
		1
	FROM GBL_Users WHERE [User_ID]=@User_ID
END ELSE BEGIN
	INSERT INTO GBL_Users_History (
		[User_ID],
		MODIFIED_DATE,
		MODIFIED_BY,
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
		PasswordChange,
		SavedSearchQuota,
		SingleLogin,
		CanUpdateAccount,
		CanUpdatePassword,
		Inactive
	)
	SELECT
		@User_ID,
		@MODIFIED_DATE,
		@MODIFIED_BY,
		CASE WHEN Agency=@Agency OR @FullUpdate=0 THEN NULL ELSE @Agency END,
		CASE WHEN SL_ID_CIC=@SL_ID_CIC OR @FullUpdate=0 THEN NULL ELSE (SELECT TOP 1 SecurityLevel FROM CIC_SecurityLevel_Name WHERE SL_ID=@SL_ID_CIC ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) END,
		CASE WHEN SL_ID_VOL=@SL_ID_VOL OR @FullUpdate=0 THEN NULL ELSE (SELECT TOP 1 SecurityLevel FROM VOL_SecurityLevel_Name WHERE SL_ID=@SL_ID_VOL ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) END,
		CASE WHEN StartModule=@StartModule OR @FullUpdate=0 THEN NULL ELSE @StartModule END,
		CASE WHEN StartLanguage=@StartLanguage THEN NULL ELSE @StartLanguage END,
		CASE WHEN UserName=@UserName OR @FullUpdate=0 THEN NULL ELSE @UserName END,
		CASE WHEN FirstName=@FirstName THEN NULL ELSE @FirstName END,
		CASE WHEN LastName=@LastName THEN NULL ELSE @LastName END,
		CASE WHEN Initials=@Initials THEN NULL ELSE @Initials END,
		CASE WHEN Email=@Email OR (Email IS NULL AND @Email IS NULL) THEN NULL ELSE ISNULL(@Email,'') END,
		CASE WHEN @PasswordHash IS NULL THEN 0 ELSE 1 END,
		CASE WHEN SavedSearchQuota=@SavedSearchQuota OR @FullUpdate=0 THEN NULL ELSE @SavedSearchQuota END,
		CASE WHEN SingleLogin=@SingleLogin THEN NULL ELSE @SingleLogin END,
		CASE WHEN CanUpdateAccount=@CanUpdateAccount THEN NULL ELSE @CanUpdateAccount END,
		CASE WHEN CanUpdatePassword=@CanUpdatePassword THEN NULL ELSE @CanUpdatePassword END,
		CASE WHEN Inactive=@Inactive THEN NULL ELSE @Inactive END
	FROM GBL_Users WHERE [User_ID]=@User_ID
END

SET @User_HST_ID=SCOPE_IDENTITY()

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_History_i] TO [cioc_login_role]
GO
