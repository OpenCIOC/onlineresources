SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Admin_Notice_i]
	@MODIFIED_BY varchar(50),
	@User_ID int,
	@AdminAreaID int,
	@RequestDetail nvarchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@AdminAreaObjectName nvarchar(100),
		@UserObjectName nvarchar(100),
		@RequestDetailObjectName nvarchar(100),
		@AdminRequestObjectName nvarchar(100)

SET @AdminAreaObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Admin Area')
SET @UserObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User')
SET @RequestDetailObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Request Detail')
SET @AdminRequestObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Admin Request')

SET @RequestDetail = RTRIM(LTRIM(@RequestDetail))
IF @RequestDetail = '' SET @RequestDetail = NULL

IF @RequestDetail IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @RequestDetailObjectName, @AdminRequestObjectName)
END ELSE IF @User_ID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserObjectName, @AdminRequestObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Users WHERE [User_ID]=@User_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@User_ID AS varchar), @UserObjectName)
END ELSE IF @AdminAreaID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AdminAreaObjectName, @AdminRequestObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Admin_Area WHERE AdminAreaID=@AdminAreaID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@AdminAreaID AS varchar), @AdminAreaObjectName)
END ELSE BEGIN
	INSERT GBL_Admin_Notice (
		CREATED_DATE,
		CREATED_BY,
		[User_ID],
		AdminAreaID,
		RequestDetail
	)
	VALUES (
		GETDATE(),
		@MODIFIED_BY,
		@User_ID,
		@AdminAreaID,
		@RequestDetail
	)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @AdminRequestObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Admin_Notice_i] TO [cioc_login_role]
GO
