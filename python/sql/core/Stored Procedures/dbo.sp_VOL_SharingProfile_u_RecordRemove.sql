SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_SharingProfile_u_RecordRemove]
	@ProfileID [int],
	@User_ID [int],
	@IDList varchar(max),
	@RevocationDate date,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 29-Jul-2015
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@SharingProfileObjectName nvarchar(100),
		@DateObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SharingProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Sharing Profile')
SET @DateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Date')

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
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID AND Domain=2) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @SharingProfileObjectName)
-- Profile belongs to member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE (MemberID=@MemberID OR ShareMemberID=@MemberID) AND ProfileID=@ProfileID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName + 'B', NULL)
END ELSE IF EXISTS (SELECT * FROM GBL_SharingProfile WHERE ShareMemberID=@MemberID AND Active=0 AND ProfileID=@ProfileID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName + 'A', NULL)
END ELSE IF EXISTS (SELECT * FROM GBL_SharingProfile WHERE MemberID=@MemberID AND ProfileID=@ProfileID AND RevokedDate IS NOT NULL AND RevokedDate < GETDATE()) BEGIN
	SET @Error = 27 -- Revoked
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END ELSE IF @RevocationDate IS NULL AND EXISTS(SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID AND Active=1) BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @DateObjectName, NULL)
END ELSE IF @RevocationDate IS NOT NULL AND @RevocationDate < CAST(DATEADD(dd, @RevocationPeriod,GETDATE()) AS date) BEGIN
	SET @Error = 28 -- Revocation date too soon.
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END

IF @Error = 0 BEGIN
	DECLARE @VNUMSTable table (
		OP_ShareProfile_ID int,
		VNUM varchar(10) COLLATE Latin1_General_100_CI_AI
	)
	
	INSERT INTO @VNUMSTable (OP_ShareProfile_ID, VNUM)
	SELECT vo.OP_ShareProfile_ID, vo.VNUM
			FROM VOL_OP_SharingProfile vo
			INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@IDList, ',') ops
				ON vo.VNUM=ops.ItemID COLLATE Latin1_General_100_CI_AI AND ProfileID=@ProfileID
			LEFT JOIN VOL_OP_SharingProfile_Revoked revoked
				ON vo.OP_ShareProfile_ID=revoked.OP_ShareProfile_ID
			WHERE revoked.OP_ShareProfile_ID IS NULL OR (@MemberID=@ShareMemberID AND revoked.RevokedDate > @RevocationDate)

	IF @RevocationDate IS NULL OR @RevocationDate <= GETDATE() BEGIN
		DELETE vo 
			FROM VOL_OP_SharingProfile vo
			INNER JOIN @VNUMSTable vt
				ON vo.OP_ShareProfile_ID=vt.OP_ShareProfile_ID 
		DELETE vo
			FROM VOL_OP_CommunitySet vo
			INNER JOIN VOL_CommunitySet cs
				ON vo.CommunitySetID=cs.CommunitySetID AND cs.MemberID=@ShareMemberID
			INNER JOIN @VNUMSTable vt
				ON vo.VNUM = vt.VNUM 
	END ELSE BEGIN
		INSERT INTO VOL_OP_SharingProfile_Revoked (OP_ShareProfile_ID, RevokedDate, RevokedBy)
		SELECT vt.OP_ShareProfile_ID, @RevocationDate, @User_ID
			FROM VOL_OP_SharingProfile vo
			INNER JOIN @VNUMSTable vt
				ON vo.OP_ShareProfile_ID=vt.OP_ShareProfile_ID
	END
END
	
SELECT CASE WHEN @MemberID=@ShareMemberID THEN NotifyEmailAddresses ELSE ShareNotifyEmailAddresses END FROM GBL_SharingProfile WHERE ProfileID=@ProfileID

SELECT 'https://' + BaseURLVOL
FROM STP_Member m
WHERE m.MemberID=@OtherMemberID

SELECT vo.VNUM, vod.POSITION_TITLE
FROM @VNUMSTable vt
INNER JOIN VOL_Opportunity vo
	ON vt.VNUM=vo.VNUM
INNER JOIN VOL_Opportunity_Description vod
	ON vo.VNUM=vod.VNUM AND LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vo.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)


RETURN @Error

SET NOCOUNT OFF








GO





GRANT EXECUTE ON  [dbo].[sp_VOL_SharingProfile_u_RecordRemove] TO [cioc_login_role]
GO
