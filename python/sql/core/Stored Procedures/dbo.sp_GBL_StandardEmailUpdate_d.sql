SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_StandardEmailUpdate_d]
	@EmailID [int],
	@MemberID [int],
	@Domain int,
	@StdForMultipleRecords bit,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 15-May-2011
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@EmailUpdateTextObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @EmailUpdateTextObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Standard Email Update Text')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Email ID given ?
END ELSE IF @EmailID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @EmailUpdateTextObjectName, NULL)
-- Email ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_StandardEmailUpdate WHERE EmailID=@EmailID AND Domain=@Domain AND StdForMultipleRecords=@StdForMultipleRecords) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@EmailID AS varchar), @EmailUpdateTextObjectName)
-- Email ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_StandardEmailUpdate WHERE EmailID=@EmailID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Is the Default Message ?
END ELSE IF EXISTS(SELECT * FROM GBL_StandardEmailUpdate WHERE EmailID=@EmailID AND DefaultMsg=1) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @EmailUpdateTextObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Default Message'))
END ELSE BEGIN
	DELETE GBL_StandardEmailUpdate
		WHERE EmailID=@EmailID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @EmailUpdateTextObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_StandardEmailUpdate_d] TO [cioc_login_role]
GO
