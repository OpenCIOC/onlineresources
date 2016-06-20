SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Users_APICreds_i]
	@MemberID int,
	@AgencyCode char(3),
	@Mod varchar(50),
	@User_ID int,
	@CredID uniqueidentifier,
	@PasswordHashSalt char(44),
	@PasswordHashRepeat int,
	@PasswordHash char(44),
	@UsageNotes nvarchar(150),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: CL
	Checked on: 15-May-2016
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@UserObjectName nvarchar(100),
		@NameObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @UserObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- User ID given ?
END ELSE IF @User_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserObjectName, NULL)
-- User ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Users WHERE [User_ID]=@User_ID)  BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@User_ID AS varchar), @UserObjectName)
-- User belongs to member ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Users WHERE [User_ID]=@User_ID AND MemberID_Cache=@MemberID AND (@AgencyCode IS NULL OR Agency=@AgencyCode))  BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserObjectName, NULL)
END ELSE BEGIN

INSERT INTO GBL_Users_APICreds
		(CredID,
		 CREATED_DATE,
		 CREATED_BY,
		 User_ID,
		 PasswordHashRepeat,
		 PasswordHashSalt,
		 PasswordHash,
		 UsageNotes
		)
VALUES	(@CredID, -- CredID - uniqueidentifier
		 GETDATE(), -- CREATED_DATE - smalldatetime
		 @Mod, -- CREATED_BY - varchar(50)
		 @User_ID, -- User_ID - int
		 @PasswordHashRepeat, -- PasswordHashRepeat - int
		 @PasswordHashSalt, -- PasswordHashSalt - char(44)
		 @PasswordHash, -- PasswordHash - char(44)
		 @UsageNotes  -- UsageNotes - nvarchar(150)
		)
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_APICreds_i] TO [cioc_login_role]
GO
