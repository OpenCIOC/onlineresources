SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrintProfile_Fld_i]
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@Domain tinyint,
	@ProfileID [int],
	@GBLFieldID [int],
	@VOLFieldID [int],
	@FieldTypeID [int],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ProfileObjectName nvarchar(100),
		@FieldObjectName nvarchar(100),
		@TypeObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')
SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')
SET @TypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Type')

IF @Domain = 1 BEGIN
	SET @VOLFieldID = NULL
END ELSE IF @GBLFieldID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_FieldOption WHERE FieldID=@GBLFieldID AND FieldType='GBL') BEGIN
	SET @GBLFieldID = NULL
END

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @ProfileObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND Domain=@Domain) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar(20)), @ProfileObjectName)
-- Profile belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Field Given ?
END ELSE IF @GBLFieldID IS NULL AND @VOLFieldID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FieldObjectName, NULL)
-- Field exists ?
END ELSE IF @GBLFieldID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_FieldOption WHERE FieldID=@GBLFieldID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@GBLFieldID AS varchar), @FieldObjectName)
-- Field exists ?
END ELSE IF @VOLFieldID IS NOT NULL AND NOT EXISTS(SELECT * FROM VOL_FieldOption WHERE FieldID=@VOLFieldID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@VOLFieldID AS varchar), @FieldObjectName)
-- Field Type given ?
END ELSE IF @FieldTypeID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TypeObjectName, NULL)
-- Field Type exists ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_PrintProfile_Fld_Type WHERE FieldTypeID=@FieldTypeID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@FieldTypeID AS varchar), @TypeObjectName)
END

IF @Error = 0 BEGIN
	INSERT INTO GBL_PrintProfile_Fld (
		ProfileID,
		GBLFieldID,
		VOLFieldID,
		FieldTypeID
	) VALUES (
		@ProfileID,
		@GBLFieldID,
		@VOLFieldID,
		@FieldTypeID
	)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg
	
	IF @Error = 0 BEGIN
		UPDATE GBL_PrintProfile
		SET MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY
		WHERE ProfileID=@ProfileID
	END
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrintProfile_Fld_i] TO [cioc_login_role]
GO
