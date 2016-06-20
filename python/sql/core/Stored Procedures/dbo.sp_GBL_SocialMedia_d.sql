SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_SocialMedia_d]
	@SM_ID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@SocialMediaObjectName nvarchar(60)

SET @SocialMediaObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Social Media Type')

IF @SM_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SocialMediaObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT SM_ID FROM GBL_SocialMedia WHERE SM_ID = @SM_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SM_ID AS varchar), @SocialMediaObjectName)
END ELSE IF EXISTS(SELECT * FROM GBL_BT_SM WHERE SM_ID=@SM_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SocialMediaObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record'))
END ELSE BEGIN
	DELETE GBL_SocialMedia
		WHERE (SM_ID = @SM_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SocialMediaObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SocialMedia_d] TO [cioc_login_role]
GO
