SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Interest_d]
	@AI_ID [int],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@InterestObjectName nvarchar(60)

SET @InterestObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Interest')

IF @AI_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @InterestObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT AI_ID FROM VOL_Interest WHERE AI_ID = @AI_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@AI_ID AS varchar), @InterestObjectName)
END ELSE IF EXISTS(SELECT * FROM VOL_OP_AI WHERE AI_ID=@AI_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @InterestObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Opportunity Record'))
END ELSE BEGIN
	DELETE VOL_Interest
	WHERE (AI_ID = @AI_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @InterestObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_d] TO [cioc_login_role]
GO
