SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_InterestGroup_d]
	@IG_ID int,
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

DECLARE @Error	int
SET @Error = 0

DECLARE	@GeneralInterestObjectName nvarchar(60)

SET @GeneralInterestObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('General Area of Interest')

IF @IG_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @GeneralInterestObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM VOL_InterestGroup WHERE IG_ID = @IG_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@IG_ID AS varchar), @GeneralInterestObjectName)
END ELSE BEGIN
	DELETE VOL_InterestGroup WHERE (IG_ID = @IG_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @GeneralInterestObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_InterestGroup_d] TO [cioc_login_role]
GO
