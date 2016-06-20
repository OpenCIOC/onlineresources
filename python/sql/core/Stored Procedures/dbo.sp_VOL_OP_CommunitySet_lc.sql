SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_CommunitySet_lc]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SET ANSI_WARNINGS OFF

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

SELECT	COUNT(CASE WHEN vo.MemberID=@MemberID AND (vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE()) AND (vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL > GETDATE()) THEN vo.VNUM ELSE NULL END) AS TOTAL_IN_ACTIVE,
		COUNT(CASE WHEN vo.MemberID=@MemberID AND (vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE()) AND vo.DISPLAY_UNTIL <= GETDATE() THEN vo.VNUM ELSE NULL END) AS TOTAL_IN_EXPIRED,
		COUNT(CASE WHEN vo.MemberID=@MemberID AND vod.DELETION_DATE <= GETDATE() THEN vo.VNUM ELSE NULL END) AS TOTAL_IN_DELETED,
		COUNT(CASE WHEN vo.MemberID<>@MemberID AND (vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE()) AND (vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL > GETDATE()) THEN vo.VNUM ELSE NULL END) AS TOTAL_SHARED_ACTIVE,
		COUNT(CASE WHEN vo.MemberID<>@MemberID AND (vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE()) AND vo.DISPLAY_UNTIL <= GETDATE() THEN vo.VNUM ELSE NULL END) AS TOTAL_SHARED_EXPIRED,
		COUNT(CASE WHEN vo.MemberID<>@MemberID AND vod.DELETION_DATE <= GETDATE() THEN vo.VNUM ELSE NULL END) AS TOTAL_SHARED_DELETED
	FROM VOL_Opportunity vo
	LEFT JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vo.VNUM ORDER BY CASE WHEN vod.DELETION_DATE IS NULL THEN 0 ELSE 1 END, CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE (vo.MemberID=@MemberID OR EXISTS(SELECT * FROM VOL_OP_SharingProfile vos INNER JOIN GBL_SharingProfile shp ON vos.ProfileID=shp.ProfileID AND shp.Active=1 WHERE vos.VNUM=vo.VNUM AND vos.ShareMemberID_Cache=@MemberID))

SELECT cs.CommunitySetID, csn.SetName,
	COUNT(CASE WHEN cx.DELETED=0 AND EXPIRED=0 AND cx.MemberID=@MemberID THEN VNUM ELSE NULL END) AS OPPS_IN_ACTIVE,
	COUNT(CASE WHEN cx.EXPIRED=1 AND DELETED=0 AND cx.MemberID=@MemberID THEN VNUM ELSE NULL END) AS OPPS_IN_EXPIRED,
	COUNT(CASE WHEN cx.DELETED=1 AND cx.MemberID=@MemberID THEN VNUM ELSE NULL END) AS OPPS_IN_DELETED,
	COUNT(CASE WHEN cx.DELETED=0 AND EXPIRED=0 AND cx.MemberID<>@MemberID THEN VNUM ELSE NULL END) AS OPPS_SHARED_ACTIVE,
	COUNT(CASE WHEN cx.EXPIRED=1 AND DELETED=0 AND cx.MemberID<>@MemberID THEN VNUM ELSE NULL END) AS OPPS_SHARED_EXPIRED,
	COUNT(CASE WHEN cx.DELETED=1 AND cx.MemberID<>@MemberID THEN VNUM ELSE NULL END) AS OPPS_SHARED_DELETED
FROM VOL_CommunitySet cs
INNER JOIN VOL_CommunitySet_Name csn
	ON cs.CommunitySetID=csn.CommunitySetID AND LangID=(SELECT TOP 1 LangID FROM VOL_CommunitySet_Name WHERE csn.CommunitySetID=CommunitySetID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
RIGHT JOIN (SELECT cs.CommunitySetID, vod.VNUM, vo.MemberID,
			CAST(CASE WHEN vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE() THEN 0 ELSE 1 END AS bit) AS DELETED,
			CAST(CASE WHEN vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL > GETDATE() THEN 0 ELSE 1 END AS bit) AS EXPIRED
		FROM VOL_CommunitySet cs
		LEFT JOIN VOL_OP_CommunitySet vcs
			ON cs.CommunitySetID=vcs.CommunitySetID
		LEFT JOIN VOL_Opportunity vo
			ON vcs.VNUM=vo.VNUM
		LEFT JOIN VOL_Opportunity_Description vod
			ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vo.VNUM ORDER BY CASE WHEN vod.DELETION_DATE IS NULL THEN 0 ELSE 1 END, CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		WHERE cs.MemberID=@MemberID
	UNION SELECT NULL, vod.VNUM, vo.MemberID,
			CAST(CASE WHEN vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE() THEN 0 ELSE 1 END AS bit) AS DELETED,
			CAST(CASE WHEN vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL > GETDATE() THEN 0 ELSE 1 END AS bit) AS EXPIRED
		FROM VOL_Opportunity vo
		LEFT JOIN VOL_Opportunity_Description vod
			ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vo.VNUM ORDER BY CASE WHEN vod.DELETION_DATE IS NULL THEN 0 ELSE 1 END, CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE NOT EXISTS(SELECT * FROM VOL_OP_CommunitySet vcs INNER JOIN VOL_CommunitySet cs ON vcs.CommunitySetID=cs.CommunitySetID AND cs.MemberID=@MemberID WHERE vcs.VNUM=vod.VNUM)
		AND (vo.MemberID=@MemberID OR EXISTS(SELECT * FROM VOL_OP_SharingProfile vos INNER JOIN GBL_SharingProfile shp ON vos.ProfileID=shp.ProfileID AND shp.Active=1 WHERE vos.VNUM=vo.VNUM AND vos.ShareMemberID_Cache=@MemberID))
	) cx
	ON cs.CommunitySetID=cx.CommunitySetID
WHERE cs.MemberID=@MemberID OR cs.CommunitySetID IS NULL
GROUP BY cs.CommunitySetID, SetName
ORDER BY CASE WHEN SetName IS NULL THEN 1 ELSE 0 END, SetName

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_CommunitySet_lc] TO [cioc_login_role]
GO
