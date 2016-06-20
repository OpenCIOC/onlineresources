
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_SharingProfile_s_RecordAdd]
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

SELECT
	-- Can add/restore to the Profile
	SUM(CASE WHEN (this.ProfileID IS NULL AND other.VNUM IS NULL) OR thisrvk.OP_ShareProfile_ID IS NOT NULL THEN 1 ELSE 0 END) AS WillBeAdded,
	-- Already in the Profile and not Revoked
	SUM(CASE WHEN this.ProfileID IS NOT NULL AND thisrvk.OP_ShareProfile_ID IS NULL THEN 1 ELSE 0 END) AS AlreadyAdded,
	-- In another Profile and not Revoked
	COUNT(other.VNUM) AS OtherProfile
FROM dbo.fn_GBL_ParseVarCharIDList(@IDList, ',') ids
INNER JOIN VOL_Opportunity vo
	ON ids.ItemID=vo.VNUM COLLATE Latin1_General_100_CI_AI
LEFT JOIN VOL_OP_SharingProfile this
	ON vo.VNUM=this.VNUM AND this.ProfileID=@ProfileID
LEFT JOIN dbo.VOL_OP_SharingProfile_Revoked thisrvk
	ON thisrvk.OP_ShareProfile_ID = this.OP_ShareProfile_ID
LEFT JOIN (SELECT DISTINCT spvo.VNUM FROM VOL_OP_SharingProfile spvo
			INNER JOIN GBL_SharingProfile sp
				ON spvo.ProfileID=sp.ProfileID AND @ShareMemberID=ShareMemberID
					AND sp.ProfileID<>@ProfileID
			LEFT JOIN VOL_OP_SharingProfile_Revoked spvor
				ON spvo.OP_ShareProfile_ID=spvor.OP_ShareProfile_ID
			WHERE spvor.RevokedDate IS NULL OR spvor.RevokedDate > GETDATE() 
			) other
	ON vo.VNUM=other.VNUM


RETURN @Error

SET NOCOUNT OFF










GO


GRANT EXECUTE ON  [dbo].[sp_VOL_SharingProfile_s_RecordAdd] TO [cioc_login_role]
GO
