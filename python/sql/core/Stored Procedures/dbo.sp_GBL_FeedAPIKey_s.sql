SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GBL_FeedAPIKey_s]
	@FeedAPIKey uniqueidentifier,
	@MemberID int,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 22-Nov-2013
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@FeedAPIKeyObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @FeedAPIKeyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Basic Data Feed API Key')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @FeedAPIKeyObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Feed API Key given ?
END ELSE IF @FeedAPIKey IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Feed API Key exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@FeedAPIKey AS varchar), @FeedAPIKeyObjectName)
-- Feed API Key belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FeedAPIKeyObjectName, NULL)
END

IF @Error <> 0 BEGIN
	SET @FeedAPIKey = NULL
END

SELECT FeedAPIKey ,
		CREATED_DATE ,
		CREATED_BY ,
		MODIFIED_DATE ,
		MODIFIED_BY ,
		Owner ,
		CIC ,
		VOL ,
		Inactive
FROM dbo.GBL_FeedAPIKey
WHERE FeedAPIKey=@FeedAPIKey

RETURN @Error


SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_GBL_FeedAPIKey_s] TO [cioc_login_role]
GO
