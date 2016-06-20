
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CIC_SharingProfile_u_Revoke]
	@ProfileID [int],
	@User_ID [int],
	@RevocationDate date,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 05-Mar-2015
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@SharingProfileObjectName nvarchar(100),
		@FieldObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SharingProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Sharing Profile')

DECLARE @MemberID int
SELECT @MemberID=MemberID 
FROM GBL_Users u 
	INNER JOIN GBL_Agency a
		ON u.Agency=a.AgencyCode
WHERE User_ID=@User_ID

DECLARE @ShareMemberID int, @OwnerMemberID int, @RevocationPeriod int, @OtherMemberID int
SELECT 
	@OwnerMemberID = MemberID,
	@ShareMemberID = ShareMemberID, 
	@RevocationPeriod = RevocationPeriod
FROM GBL_SharingProfile
WHERE ProfileID=@ProfileID

IF @MemberID=@ShareMemberID BEGIN
	SET @RevocationPeriod = 0
	SET @OtherMemberID=@OwnerMemberID
END ELSE BEGIN
	SET @OtherMemberID = @ShareMemberID
END


-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @SharingProfileObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID AND Domain=1) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @SharingProfileObjectName)
-- Profile belongs to member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE (MemberID=@MemberID or ShareMemberID=@MemberID) AND ProfileID=@ProfileID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID AND Active=1 AND RevokedDate IS NULL) BEGIN
	SET @Error = 27 -- Already revoked
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END ELSE IF @RevocationDate < CAST(DATEADD(dd, @RevocationPeriod,GETDATE()) AS date) BEGIN
	SET @Error = 28 -- Revocation Date too soon
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END ELSE BEGIN
	UPDATE GBL_SharingProfile
		SET RevokedBy = @User_ID,
			RevokedDate = @RevocationDate,
			Active = CASE WHEN @RevocationDate <= GETDATE() THEN 0 ELSE Active END
		WHERE ProfileID = @ProfileID	
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SharingProfileObjectName, @ErrMsg
		
	IF @RevocationDate <= GETDATE() BEGIN
		DELETE FROM GBL_BT_SharingProfile WHERE ProfileID=@ProfileID
	END
END

	
SELECT CASE WHEN @MemberID=@ShareMemberID THEN NotifyEmailAddresses ELSE ShareNotifyEmailAddresses END FROM GBL_SharingProfile WHERE ProfileID=@ProfileID


RETURN @Error

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_CIC_SharingProfile_u_Revoke] TO [cioc_login_role]
GO
