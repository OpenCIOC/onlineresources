
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GBL_FeedAPIKey_i]
	@FeedAPIKey uniqueidentifier OUTPUT,
	@MODIFIED_BY varchar(50),
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
	Checked on: 16-Nov-2013
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
END ELSE BEGIN
	SET @FeedAPIKey = NEWID()

	INSERT INTO dbo.GBL_FeedAPIKey (
		FeedAPIKey,
		MemberID,
		Owner,
		CIC,
		VOL
	)
	VALUES (
		@FeedAPIKey,
		@MemberID,
		ISNULL(@Owner, cioc_shared.dbo.fn_SHR_GBL_DateTimeString(GETDATE())),
		ISNULL(@CIC,0),
		ISNULL(@VOL,0)
	)

END

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_GBL_FeedAPIKey_i] TO [cioc_login_role]
GO
