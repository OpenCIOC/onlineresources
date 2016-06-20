SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_NAICS_d]
	@Code [varchar](6),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@NAICSCodeObjectName nvarchar(100)

SET @NAICSCodeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('NAICS')

IF @Code IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NAICSCodeObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM NAICS WHERE Code = @Code) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Code, @NAICSCodeObjectName)
END ELSE IF EXISTS (SELECT * FROM CIC_BT_NC WHERE Code=@Code) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NAICSCodeObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record'))
END ELSE BEGIN
	DELETE nxu FROM NAICS_Exclusion_Use nxu WHERE EXISTS(SELECT * FROM NAICS_Exclusion WHERE Code=@Code AND nxu.Exclusion_ID=Exclusion_ID)
	DELETE NAICS WHERE Code = @Code
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @NAICSCodeObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_NAICS_d] TO [cioc_login_role]
GO
