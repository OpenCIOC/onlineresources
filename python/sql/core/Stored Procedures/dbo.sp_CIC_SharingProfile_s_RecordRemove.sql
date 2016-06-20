SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[sp_CIC_SharingProfile_s_RecordRemove]
	@MemberID int,
	@ProfileID int,
	@IDList varchar(MAX)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 08-Apr-2012
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

SELECT SUM(CASE WHEN revoked.BT_ShareProfile_ID IS NULL THEN 1 ELSE 0 END) AS WillBeRemoved,
		COUNT(revoked.BT_ShareProfile_ID) AS AlreadyRemoved
FROM dbo.fn_GBL_ParseVarCharIDList(@IDList, ',') ids
INNER JOIN GBL_BaseTable bt
	ON ids.ItemID=bt.NUM COLLATE Latin1_General_100_CI_AI
INNER JOIN GBL_BT_SharingProfile this
	ON bt.NUM=this.NUM AND this.ProfileID=@ProfileID
LEFT JOIN GBL_BT_SharingProfile_Revoked revoked
	ON revoked.BT_ShareProfile_ID = this.BT_ShareProfile_ID

RETURN @Error

SET NOCOUNT OFF








GO
GRANT EXECUTE ON  [dbo].[sp_CIC_SharingProfile_s_RecordRemove] TO [cioc_login_role]
GO
