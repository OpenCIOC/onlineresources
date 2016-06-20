SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[sp_VOL_SharingProfile_s_RecordRemove]
	@MemberID int,
	@ProfileID int,
	@IDList varchar(MAX)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
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

SELECT @ShareMemberID=ShareMemberID FROM GBL_SharingProfile WHERE Domain=2 AND ProfileID=@ProfileID

SELECT SUM(CASE WHEN revoked.OP_ShareProfile_ID IS NULL THEN 1 ELSE 0 END) AS WillBeRemoved,
		COUNT(revoked.OP_ShareProfile_ID) AS AlreadyRemoved
FROM dbo.fn_GBL_ParseVarCharIDList(@IDList, ',') ids
INNER JOIN VOL_Opportunity vo
	ON ids.ItemID=vo.VNUM COLLATE Latin1_General_100_CI_AI
INNER JOIN VOL_OP_SharingProfile this
	ON vo.VNUM=this.VNUM AND this.ProfileID=@ProfileID
LEFT JOIN VOL_OP_SharingProfile_Revoked revoked
	ON revoked.OP_ShareProfile_ID = this.OP_ShareProfile_ID


RETURN @Error

SET NOCOUNT OFF











GO
GRANT EXECUTE ON  [dbo].[sp_VOL_SharingProfile_s_RecordRemove] TO [cioc_login_role]
GO
