
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_SharingProfile_u_RecordRemove]
	@ProfileID [int],
	@User_ID [int],
	@IDList varchar(max),
	@RevocationDate date,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: CL
	Checked on: 05-Mar-2015
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
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID AND Domain=1) BEGIN
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
	DECLARE @NUMSTable table (
		BT_ShareProfile_ID int,
		NUM varchar(8) COLLATE Latin1_General_100_CI_AI
	)
	
	INSERT INTO @NUMSTable (BT_ShareProfile_ID, NUM)
	SELECT bt.BT_ShareProfile_ID, bt.NUM
			FROM GBL_BT_SharingProfile bt
			INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@IDList, ',') nums
				ON bt.NUM=nums.ItemID COLLATE Latin1_General_100_CI_AI AND ProfileID=@ProfileID
			LEFT JOIN GBL_BT_SharingProfile_Revoked revoked
				ON bt.BT_ShareProfile_ID=revoked.BT_ShareProfile_ID
			WHERE revoked.BT_ShareProfile_ID IS NULL OR (@MemberID=@ShareMemberID AND revoked.RevokedDate > @RevocationDate)

	IF @RevocationDate IS NULL OR @RevocationDate <= GETDATE() BEGIN
		DELETE bt 
			FROM GBL_BT_SharingProfile bt
			INNER JOIN @NUMSTable nt
				ON bt.BT_ShareProfile_ID=nt.BT_ShareProfile_ID
	END ELSE BEGIN
		INSERT INTO GBL_BT_SharingProfile_Revoked (BT_ShareProfile_ID, RevokedDate, RevokedBy)
		SELECT bt.BT_ShareProfile_ID, @RevocationDate, @User_ID
			FROM GBL_BT_SharingProfile bt
			INNER JOIN @NUMSTable nt 
				ON bt.BT_ShareProfile_ID=nt.BT_ShareProfile_ID
	END
END
	
SELECT CASE WHEN @MemberID=@ShareMemberID THEN NotifyEmailAddresses ELSE ShareNotifyEmailAddresses END FROM GBL_SharingProfile WHERE ProfileID=@ProfileID

SELECT CASE WHEN t.FullSSLCompatible=1 AND dm.FullSSLCompatible = 1 THEN 'https://' ELSE 'http://' END + BaseURLCIC 
FROM STP_Member m
INNER JOIN GBL_View_DomainMap dm
	ON BaseURLCIC = dm.DomainName
INNER JOIN GBL_Template t
	ON m.DefaultTemplate=t.Template_ID
WHERE m.MemberID=@OtherMemberID

SELECT bt.NUM, dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM, btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, btd.LOCATION_NAME, btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2, bt.DISPLAY_LOCATION_NAME, bt.DISPLAY_ORG_NAME)
FROM @NUMSTable nt
INNER JOIN GBL_BaseTable bt
	ON bt.NUM=nt.NUM
INNER JOIN GBL_BaseTable_Description btd
	ON bt.NUM=btd.NUM AND LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE bt.NUM=NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)

RETURN @Error

SET NOCOUNT OFF





GO




GRANT EXECUTE ON  [dbo].[sp_CIC_SharingProfile_u_RecordRemove] TO [cioc_login_role]
GO
