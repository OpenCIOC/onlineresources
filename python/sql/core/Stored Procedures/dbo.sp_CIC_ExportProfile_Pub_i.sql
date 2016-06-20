SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExportProfile_Pub_i]
	@MODIFIED_BY [varchar](50),
	@MemberID [int],
	@ProfileID [int],
	@PB_ID [int],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ProfileObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @ProfileObjectName)
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_ExportProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Publication given ?
END ELSE IF @PB_ID IS NULL BEGIN
	SET @Error = 2
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, NULL)
-- Publication exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_Publication WHERE PB_ID = @PB_ID) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PB_ID AS varchar), @PublicationObjectName)
END ELSE BEGIN
	IF NOT EXISTS(SELECT * FROM CIC_ExportProfile_Pub WHERE PB_ID=@PB_ID AND ProfileID=@ProfileID) BEGIN
		INSERT INTO CIC_ExportProfile_Pub (
			ProfileID,
			PB_ID
		)
		VALUES (
			@ProfileID,
			@PB_ID
		)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
		
		IF @Error = 0 BEGIN
			UPDATE CIC_ExportProfile
			SET MODIFIED_DATE	= GETDATE(),
				MODIFIED_BY		= @MODIFIED_BY
			WHERE ProfileID=@ProfileID
		END
	END
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ExportProfile_Pub_i] TO [cioc_login_role]
GO
