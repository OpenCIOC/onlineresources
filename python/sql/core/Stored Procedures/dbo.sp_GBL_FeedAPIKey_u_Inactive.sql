SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GBL_FeedAPIKey_u_Inactive]
	@FeedAPIKey uniqueidentifier,
	@MemberID int,
	@Inactive bit,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 22-Nov-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@FeedAPIKeyObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @FeedAPIKeyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Basic Data Feed API Key')

-- Feed API Key given ?
IF @FeedAPIKey IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Feed API Key exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@FeedAPIKey AS varchar), @FeedAPIKeyObjectName)
-- Feed API Key belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FeedAPIKeyObjectName, NULL)
END ELSE IF @Inactive IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FeedAPIKeyObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Name'))
END ELSE BEGIN
	UPDATE dbo.GBL_FeedAPIKey
		SET Inactive		= ISNULL(@Inactive,Inactive)
	WHERE FeedAPIKey=@FeedAPIKey
END

RETURN @Error

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_GBL_FeedAPIKey_u_Inactive] TO [cioc_login_role]
GO
