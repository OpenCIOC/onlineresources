
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CIC_SharingProfile_s_RecordAdd]
	@MemberID int,
	@ProfileID int,
	@IDList varchar(max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 29-Jul-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

DECLARE @ShareMemberID int

SELECT @ShareMemberID=ShareMemberID FROM GBL_SharingProfile WHERE Domain=1 AND ProfileID=@ProfileID

SELECT 
	-- Can add/restore to the Profile
	SUM(CASE WHEN (this.ProfileID IS NULL AND other.NUM IS NULL) OR thisrvk.BT_ShareProfile_ID IS NOT NULL THEN 1 ELSE 0 END) AS WillBeAdded,
	-- Already in the Profile and not Revoked
	SUM(CASE WHEN this.ProfileID IS NOT NULL AND thisrvk.BT_ShareProfile_ID IS NULL THEN 1 ELSE 0 END) AS AlreadyAdded,
	-- In another Profile and not Revoked
	COUNT(other.NUM) AS OtherProfile
FROM dbo.fn_GBL_ParseVarCharIDList(@IDList, ',') ids
INNER JOIN GBL_BaseTable bt
	ON ids.ItemID=bt.NUM COLLATE Latin1_General_100_CI_AI
LEFT JOIN GBL_BT_SharingProfile this
	ON bt.NUM=this.NUM AND this.ProfileID=@ProfileID
LEFT JOIN dbo.GBL_BT_SharingProfile_Revoked thisrvk
	ON thisrvk.BT_ShareProfile_ID = this.BT_ShareProfile_ID
LEFT JOIN (SELECT DISTINCT spbt.NUM FROM GBL_BT_SharingProfile spbt
			INNER JOIN GBL_SharingProfile sp
				ON spbt.ProfileID=sp.ProfileID AND @ShareMemberID=ShareMemberID
					AND sp.ProfileID<>@ProfileID
			LEFT JOIN GBL_BT_SharingProfile_Revoked spbtr
				ON spbt.BT_ShareProfile_ID=spbtr.BT_ShareProfile_ID
			WHERE spbtr.RevokedDate IS NULL OR spbtr.RevokedDate > GETDATE() 
			) other
	ON bt.NUM=other.NUM

RETURN @Error

SET NOCOUNT OFF







GO

GRANT EXECUTE ON  [dbo].[sp_CIC_SharingProfile_s_RecordAdd] TO [cioc_login_role]
GO
