
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_SharingProfile_u_RecordAdd]
	@MemberID [int],
	@ProfileID [int],
	@MODIFIED_BY nvarchar(50),
	@IDList varchar(max),
	@RecordsAdded int OUTPUT,
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
		@SharingProfileObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SharingProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Sharing Profile')

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
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE MemberID=@MemberID AND ProfileID=@ProfileID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE IF EXISTS (SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID AND RevokedDate IS NOT NULL AND RevokedDate < GETDATE()) BEGIN
	SET @Error = 27 -- Revoked
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END

IF @Error = 0 BEGIN
	DECLARE @ShareMemberID int
	SELECT @ShareMemberID=ShareMemberID FROM GBL_SharingProfile WHERE ProfileID=@ProfileID
	
	INSERT INTO GBL_BT_SharingProfile (NUM, ProfileID, ShareMemberID_Cache)
	SELECT bt.NUM, @ProfileID, @ShareMemberID 
	FROM dbo.fn_GBL_ParseVarCharIDList(@IDList, ',') ids
	INNER JOIN GBL_BaseTable bt
		ON ids.ItemID=bt.NUM COLLATE Latin1_General_100_CI_AI
	WHERE NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile this
		WHERE bt.NUM=this.NUM AND this.ProfileID=@ProfileID) 
		AND NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile spbt
				INNER JOIN GBL_SharingProfile sp
					ON spbt.ProfileID=sp.ProfileID AND @ShareMemberID=ShareMemberID AND bt.NUM=spbt.NUM
				LEFT JOIN GBL_BT_SharingProfile_Revoked spbtr
					ON spbt.BT_ShareProfile_ID=spbtr.BT_ShareProfile_ID
				WHERE spbtr.RevokedDate IS NULL OR spbtr.RevokedDate > GETDATE() ) 
		AND dbo.fn_GBL_NUMToMemberID(bt.NUM)=@MemberID
	SET @RecordsAdded = @@ROWCOUNT

	DELETE shpr
	FROM dbo.GBL_BT_SharingProfile_Revoked shpr
	INNER JOIN dbo.GBL_BT_SharingProfile shp
		ON shp.BT_ShareProfile_ID = shpr.BT_ShareProfile_ID
	INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@IDList, ',') ids
		ON shp.NUM=ids.ItemID COLLATE Latin1_General_100_CI_AI AND shp.ProfileID=@ProfileID
	WHERE dbo.fn_GBL_NUMToMemberID(shp.NUM)=@MemberID

	SET @RecordsAdded = @RecordsAdded + @@ROWCOUNT
	
	UPDATE GBL_SharingProfile
	SET	MODIFIED_BY=@MODIFIED_BY,
		MODIFIED_DATE=GETDATE()
	WHERE ProfileID = @ProfileID	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SharingProfileObjectName, @ErrMsg
END
	
RETURN @Error

SET NOCOUNT OFF




















GO

GRANT EXECUTE ON  [dbo].[sp_CIC_SharingProfile_u_RecordAdd] TO [cioc_login_role]
GO
