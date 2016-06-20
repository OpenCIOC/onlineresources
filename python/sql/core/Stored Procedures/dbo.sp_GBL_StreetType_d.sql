SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_StreetType_d]
	@SType_ID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@StreetTypeObjectName nvarchar(60)

SET @StreetTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Street Type')

IF @SType_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @StreetTypeObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM GBL_StreetType WHERE SType_ID = @SType_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SType_ID AS varchar), @StreetTypeObjectName)
END ELSE BEGIN
	DELETE GBL_StreetType
	WHERE (SType_ID = @SType_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @StreetTypeObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetType_d] TO [cioc_login_role]
GO
