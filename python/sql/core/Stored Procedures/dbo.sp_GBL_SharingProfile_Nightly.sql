SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_GBL_SharingProfile_Nightly]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 22-Apr-2012
	Action:	NO ACTION REQUIRED
*/

UPDATE GBL_SharingProfile SET Active=0 WHERE RevokedDate IS NOT NULL AND RevokedDate <= GETDATE()

-- CIC Sharing Profiles
DELETE btsp 
FROM GBL_BT_SharingProfile btsp
INNER JOIN GBL_SharingProfile sp
	ON btsp.ProfileID=sp.ProfileID
WHERE sp.Active=0 AND sp.RevokedDate IS NOT NULL

DELETE btsp
FROM GBL_BT_SharingProfile btsp
INNER JOIN GBL_BT_SharingProfile_Revoked btspr
	ON btsp.BT_ShareProfile_ID=btspr.BT_ShareProfile_ID
WHERE btspr.RevokedDate <= GETDATE()

-- VOL Sharing Profiles

-- community set assignments to no longer shared records
DELETE vo
	FROM VOL_OP_CommunitySet vo
	INNER JOIN VOL_CommunitySet cs
		ON vo.CommunitySetID=cs.CommunitySetID
	INNER JOIN VOL_OP_SharingProfile ops
		ON vo.VNUM = ops.VNUM
	INNER JOIN GBL_SharingProfile sp
		ON ops.ProfileID=sp.ProfileID
WHERE cs.MemberID=sp.ShareMemberID AND 
	(sp.Active=0 AND sp.RevokedDate IS NOT NULL)
	OR EXISTS(SELECT * FROM VOL_OP_SharingProfile_Revoked WHERE ops.OP_ShareProfile_ID =OP_ShareProfile_ID AND RevokedDate <= GETDATE())
		
DELETE btsp 
FROM VOL_OP_SharingProfile btsp
INNER JOIN GBL_SharingProfile sp
	ON btsp.ProfileID=sp.ProfileID
WHERE sp.Active=0 AND sp.RevokedDate IS NOT NULL

DELETE btsp
FROM VOL_OP_SharingProfile btsp
INNER JOIN VOL_OP_SharingProfile_Revoked btspr
	ON btsp.OP_ShareProfile_ID=btspr.OP_ShareProfile_ID
WHERE btspr.RevokedDate <= GETDATE()


SET NOCOUNT OFF







GO
