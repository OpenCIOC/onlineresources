SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMSetCommunitySetIDs_u]
	@MemberID int,
	@VNUM varchar(10),
	@IdList varchar(max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Apr-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE @OPMemberID int
SELECT @OPMemberID=MemberID
	FROM VOL_Opportunity vo
WHERE vo.VNUM=@VNUM

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- Opportunity exists ?
END ELSE IF @OPMemberID IS NULL BEGIN
	SET @Error = 3 -- No Such Record
END

DECLARE @tmpCommunitySetIDs TABLE (
	CommunitySetID int NOT NULL PRIMARY KEY
)

INSERT INTO @tmpCommunitySetIDs
	SELECT DISTINCT cs.CommunitySetID
		FROM VOL_CommunitySet cs
		LEFT JOIN VOL_OP_CommunitySet vcs
			ON cs.CommunitySetID=vcs.CommunitySetID AND vcs.VNUM=@VNUM
	WHERE (cs.MemberID=@OPMemberID
			OR EXISTS(SELECT *
				FROM VOL_OP_SharingProfile vos
				INNER JOIN GBL_SharingProfile shp
					ON vos.ProfileID=shp.ProfileID AND shp.Active=1
				WHERE vos.VNUM=@VNUM AND vos.ShareMemberID_Cache=cs.MemberID)
			)
		AND (
			EXISTS(SELECT * FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm WHERE tm.ItemID=cs.CommunitySetID)
			OR (cs.MemberID<>@MemberID AND vcs.CommunitySetID IS NOT NULL)
		)

IF @Error=0 BEGIN
	MERGE INTO VOL_OP_CommunitySet pr
	USING @tmpCommunitySetIDs nt
		ON pr.CommunitySetID=nt.CommunitySetID AND pr.VNUM=@VNUM
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (VNUM, CommunitySetID) VALUES (@VNUM, nt.CommunitySetID)
	WHEN NOT MATCHED BY SOURCE AND pr.VNUM=@VNUM THEN
		DELETE
		; 
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMSetCommunitySetIDs_u] TO [cioc_login_role]
GO
