SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Users_APICreds_d]
	@MemberID int,
	@AgencyCode char(3),
	@User_ID int,
	@CredID uniqueidentifier,
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
		@CredentialObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @UserObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User')
SET @CredentialObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Credential')

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
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Users_APICreds c WHERE c.USER_ID=@User_ID AND c.CredID=@CredID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CredID AS varchar(50)), @MemberObjectName)
END ELSE BEGIN

DELETE FROM GBL_Users_APICreds WHERE CredID=@CredID

END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Users_APICreds_d] TO [cioc_login_role]
GO
