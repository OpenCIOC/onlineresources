
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GBL_FeedAPIKey_u]
	@FeedAPIKey uniqueidentifier,
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@Owner nvarchar(100),
	@CIC bit,
	@VOL bit,
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
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FeedAPIKeyObjectName, NULL)
-- Feed API Key exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@FeedAPIKey AS varchar), @FeedAPIKeyObjectName)
-- Feed API Key belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FeedAPIKeyObjectName, NULL)
END ELSE IF @Owner IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FeedAPIKeyObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Name'))
END ELSE BEGIN
	UPDATE dbo.GBL_FeedAPIKey
		SET MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			[Owner]				= @Owner,
			CIC					= ISNULL(@CIC,CIC),
			VOL					= ISNULL(@VOL,VOL)
	WHERE FeedAPIKey=@FeedAPIKey
END

RETURN @Error

SET NOCOUNT OFF

GO

GRANT EXECUTE ON  [dbo].[sp_GBL_FeedAPIKey_u] TO [cioc_login_role]
GO
