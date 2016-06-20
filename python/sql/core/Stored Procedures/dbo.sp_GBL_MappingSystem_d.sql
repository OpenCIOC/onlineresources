SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_MappingSystem_d]
	@MAP_ID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MappingSystemObjectName nvarchar(60)

SET @MappingSystemObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Mapping System')

IF @MAP_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MappingSystemObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT MAP_ID FROM GBL_MappingSystem WHERE MAP_ID = @MAP_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MAP_ID AS varchar), @MappingSystemObjectName)
END ELSE IF EXISTS(SELECT * FROM GBL_BT_MAP WHERE MAP_ID=@MAP_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MappingSystemObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record'))
END ELSE BEGIN
	DELETE GBL_MappingSystem
	WHERE (MAP_ID = @MAP_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @MappingSystemObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_MappingSystem_d] TO [cioc_login_role]
GO
