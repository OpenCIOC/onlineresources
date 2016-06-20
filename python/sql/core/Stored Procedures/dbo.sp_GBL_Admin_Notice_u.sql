SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_GBL_Admin_Notice_u]
	@AdminNoticeID int,
	@Domains varchar(100),
	@MODIFIED_BY nvarchar(50),
	@ActionTaken int,
	@ActionNotes nvarchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 10-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

DECLARE	@AdminAreaObjectName nvarchar(100),
		@UserObjectName nvarchar(100),
		@RequestDetailObjectName nvarchar(100),
		@AdminRequestObjectName nvarchar(100)

SET @AdminAreaObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Admin Area')
SET @UserObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User')
SET @RequestDetailObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Request Detail')
SET @AdminRequestObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Admin Request')

IF @AdminNoticeID IS NULL BEGIN
	SET @Error = 2 -- ID Required
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AdminRequestObjectName, NULL)
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Admin_Notice WHERE AdminNoticeID=@AdminNoticeID) BEGIN
	SET @Error = 3 -- No Record ID
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@AdminNoticeID AS varchar), @AdminRequestObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Admin_Notice an INNER JOIN GBL_Admin_Area aa ON aa.AdminAreaID=an.AdminAreaID INNER JOIN dbo.fn_GBL_ParseIntIDList(@Domains, ',') idl ON aa.Domain=idl.ItemID WHERE AdminNoticeID=@AdminNoticeID) BEGIN
	SET @Error = 8 -- No Record ID
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AdminAreaObjectName, NULL)
END ELSE BEGIN
	UPDATE GBL_Admin_Notice
		SET ActionTaken = @ActionTaken,
			ActionNotes = @ActionNotes,
			PROCESSED_DATE = CASE WHEN PROCESSED_DATE IS NOT NULL THEN PROCESSED_DATE ELSE ( CASE WHEN @ActionTaken IS NOT NULL THEN GETDATE() ELSE NULL END ) END,
			PROCESSED_BY = CASE WHEN PROCESSED_BY IS NOT NULL THEN PROCESSED_BY ELSE (CASE WHEN @ActionTaken IS NOT NULL THEN @MODIFIED_BY ELSE NULL END) END
	WHERE AdminNoticeID=@AdminNoticeID
			
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @AdminRequestObjectName, @ErrMsg
END

SET NOCOUNT OFF


















GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Admin_Notice_u] TO [cioc_login_role]
GO
