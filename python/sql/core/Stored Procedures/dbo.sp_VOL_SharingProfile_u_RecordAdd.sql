
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_SharingProfile_u_RecordAdd]
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
	Checked on: 29-Apr-2012
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
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID AND Domain=2) BEGIN
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
	
	INSERT INTO VOL_OP_SharingProfile (VNUM, ProfileID, ShareMemberID_Cache)
	SELECT bt.VNUM, @ProfileID, @ShareMemberID 
	FROM dbo.fn_GBL_ParseVarCharIDList(@IDList, ',') ids
	INNER JOIN VOL_Opportunity bt
		ON ids.ItemID=bt.VNUM COLLATE Latin1_General_100_CI_AI
	WHERE NOT EXISTS(SELECT * FROM VOL_OP_SharingProfile this
		WHERE bt.VNUM=this.VNUM AND this.ProfileID=@ProfileID) 
		AND NOT EXISTS(SELECT * FROM VOL_OP_SharingProfile spbt
				INNER JOIN GBL_SharingProfile sp
					ON spbt.ProfileID=sp.ProfileID AND @ShareMemberID=ShareMemberID AND bt.VNUM=spbt.VNUM
				LEFT JOIN VOL_OP_SharingProfile_Revoked spbtr
					ON spbt.OP_ShareProfile_ID=spbtr.OP_ShareProfile_ID
				WHERE spbtr.RevokedDate IS NULL OR spbtr.RevokedDate > GETDATE() ) 
		AND dbo.fn_VOL_VNUMToMemberID(bt.VNUM)=@MemberID
	SET @RecordsAdded = @@ROWCOUNT
	DELETE shpr
	FROM dbo.VOL_OP_SharingProfile_Revoked shpr
	INNER JOIN dbo.VOL_OP_SharingProfile shp
		ON shp.OP_ShareProfile_ID = shpr.OP_ShareProfile_ID
	INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@IDList, ',') ids
		ON shp.VNUM=ids.ItemID COLLATE Latin1_General_100_CI_AI AND shp.ProfileID=@ProfileID
	WHERE dbo.fn_VOL_VNUMToMemberID(shp.VNUM)=@MemberID

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


GRANT EXECUTE ON  [dbo].[sp_VOL_SharingProfile_u_RecordAdd] TO [cioc_login_role]
GO
