SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExportProfile_Pub_d]
	@ExportPubID int,
	@MODIFIED_BY varchar(50),
	@MemberID [int],
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ProfileObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')

DECLARE @ProfileID int
SELECT @ProfileID = ProfileID FROM CIC_ExportProfile_Pub WHERE ExportPubID = @ExportPubID

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Export Publication ID given ?
END ELSE IF @ExportPubID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, NULL)
END ELSE IF @ProfileID IS NULL BEGIN
-- Export Publication ID exists ?
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ExportPubID AS varchar), @PublicationObjectName)
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE BEGIN
	DELETE CIC_ExportProfile_Pub
	WHERE (ExportPubID = @ExportPubID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
	
	IF @Error = 0 BEGIN
		UPDATE CIC_ExportProfile
		SET MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY
		WHERE ProfileID=@ProfileID
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ExportProfile_Pub_d] TO [cioc_login_role]
GO
