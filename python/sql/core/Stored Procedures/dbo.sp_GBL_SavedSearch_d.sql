SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_SavedSearch_d]
	@User_ID int,
	@SSRCH_ID int,
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

DECLARE	@SavedSearchObjectName nvarchar(60)

SET @SavedSearchObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Saved Search')

-- Saved Search ID Given ?
IF @SSRCH_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SavedSearchObjectName, NULL)
-- Saved Search ID Exists ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_SavedSearch WHERE SSRCH_ID=@SSRCH_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SSRCH_ID AS varchar), @SavedSearchObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM GBL_SavedSearch WHERE SSRCH_ID=@SSRCH_ID AND User_ID=@User_ID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('User'), NULL)
END ELSE BEGIN
	DELETE FROM CIC_SecurityLevel_SavedSearch
		WHERE SSRCH_ID=@SSRCH_ID
	DELETE FROM VOL_SecurityLevel_SavedSearch
		WHERE SSRCH_ID=@SSRCH_ID
	DELETE FROM GBL_SavedSearch WHERE (SSRCH_ID=@SSRCH_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SavedSearchObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SavedSearch_d] TO [cioc_login_role]
GO
