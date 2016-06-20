SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_DownloadURL_d]
	@URL_ID int,
	@MemberID [int],
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Dec-2011
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@DownloadResourceObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @DownloadResourceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Download Resource')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @DownloadResourceObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- URL ID given ?
END ELSE IF @URL_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @DownloadResourceObjectName, NULL)
-- URL ID exists ?
END ELSE IF NOT EXISTS (SELECT URL_ID FROM GBL_DownloadURL WHERE URL_ID=@URL_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@URL_ID AS varchar), @DownloadResourceObjectName)
-- URL ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT URL_ID FROM GBL_DownloadURL WHERE URL_ID=@URL_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE BEGIN
	DELETE GBL_DownloadURL
	WHERE (URL_ID = @URL_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DownloadResourceObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_DownloadURL_d] TO [cioc_login_role]
GO
