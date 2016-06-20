SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Agency_d]
	@MemberID int,
	@AgencyID [int],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: CL
	Checked on: 26-Nov-2013
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@AgencyObjectName nvarchar(60)

SET @AgencyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency')

IF @AgencyID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM GBL_Agency WHERE AgencyID = @AgencyID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@AgencyID AS varchar), @AgencyObjectName)
END ELSE IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Agency WHERE AgencyID=@AgencyID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyObjectName, NULL)
END ELSE IF EXISTS (SELECT * FROM GBL_Users u INNER JOIN GBL_Agency a ON u.Agency=a.AgencyCode WHERE AgencyID=@AgencyID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('User'))
END ELSE IF EXISTS (SELECT * FROM CIC_View vw INNER JOIN GBL_Agency a ON vw.Owner=a.AgencyCode WHERE AgencyID=@AgencyID) 
		OR EXISTS (SELECT * FROM VOL_View vw INNER JOIN GBL_Agency a ON vw.Owner=a.AgencyCode WHERE AgencyID=@AgencyID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('View'))
END ELSE BEGIN
	DELETE FROM GBL_Reminder_Agency WHERE AgencyID=@AgencyID
	DELETE GBL_Agency WHERE AgencyID = @AgencyID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @AgencyObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Agency_d] TO [cioc_login_role]
GO
