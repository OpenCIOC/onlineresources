SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_FieldOption_d_Extra]
	@SuperUSerGlobal bit,
	@OwnerMemberID int,
	@FieldID int,
	@ExtraFieldType char(1),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 23-Feb-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@FieldObjectName nvarchar(100)

SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')

DECLARE @FieldName varchar(100)
SELECT @FieldName = FieldName FROM VOL_FieldOption WHERE FieldID=@FieldID

/* Identify errors that will prevent the record from being deleted */
IF NOT EXISTS (SELECT * FROM VOL_FieldOption WHERE FieldID=@FieldID AND ExtraFieldType=@ExtraFieldType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@FieldID AS varchar), @FieldObjectName)
END ELSE IF @SuperUSerGlobal=0 AND @FieldID IS NOT NULL AND NOT EXISTS(SELECT * FROM VOL_FieldOption WHERE FieldID=@FieldID AND MemberID=@OwnerMemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FieldObjectName, NULL)
END ELSE IF EXISTS(SELECT * FROM VOL_OP_EXTRA_DATE WHERE FieldName=@FieldName)
		OR EXISTS(SELECT * FROM VOL_OP_EXTRA_EMAIL WHERE FieldName=@FieldName)
		OR EXISTS(SELECT * FROM VOL_OP_EXTRA_RADIO WHERE FieldName=@FieldName)
		OR EXISTS(SELECT * FROM VOL_OP_EXTRA_TEXT WHERE FieldName=@FieldName)
		OR EXISTS(SELECT * FROM VOL_OP_EXTRA_WWW WHERE FieldName=@FieldName)
		OR EXISTS(SELECT * FROM VOL_OP_EXC WHERE FieldName_Cache=@FieldName)
		OR EXISTS(SELECT * FROM VOL_OP_EXD WHERE FieldName_Cache=@FieldName) BEGIN
	SET @Error = 7 -- Can't Delete Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FieldObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Opportunity Record'))
/* No issues exist that prevent the update */
END ELSE BEGIN
	DELETE FROM VOL_FieldOption WHERE FieldID=@FieldID AND ExtraFieldType=@ExtraFieldType
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_VOL_FieldOption_d_Extra] TO [cioc_login_role]
GO
