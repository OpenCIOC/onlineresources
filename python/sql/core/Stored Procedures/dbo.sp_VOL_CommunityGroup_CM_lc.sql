
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunityGroup_CM_lc]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.2
	Checked by: CL
	Checked on: 02-Mar-2015
	Action: TESTING REQUIRED
*/

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@CanSeeExpired bit,
		@HidePastDueBy int,
		@CommunitySetID int
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@CanSeeExpired=CanSeeExpired,
		@HidePastDueBy=HidePastDueBy,
		@CommunitySetID=CommunitySetID
FROM VOL_View
WHERE ViewType=@ViewType

DECLARE @CommunityTable TABLE (
	CommunityGroupID int,
	CM_ID int NOT NULL,
	Community nvarchar(200),
	UNIQUE (CommunityGroupID, CM_ID)
)

-- List of Community Group Communities
INSERT INTO @CommunityTable
SELECT vcg.CommunityGroupID, cm.CM_ID, cmn.Name
	FROM VOL_CommunityGroup vcg
	INNER JOIN VOL_CommunityGroup_Name vcgn
		ON vcg.CommunityGroupID=vcgn.CommunityGroupID AND vcgn.LangID=(SELECT TOP 1 LangID FROM VOL_CommunityGroup_Name WHERE CommunityGroupID=vcgn.CommunityGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN  VOL_CommunityGroup_CM vcgc
		ON vcg.CommunityGroupID=vcgc.CommunityGroupID
	INNER JOIN GBL_Community cm
		ON vcgc.CM_ID=cm.CM_ID
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE CommunitySetID = @CommunitySetID
ORDER BY vcgn.CommunityGroupName, cmn.Name

-- Total Positions and Individuals Summary
SELECT	COUNT(DISTINCT(x.VNUM)) AS TOTAL_NUM_POS,
		SUM(ISNULL(x.NUM_NEEDED_TOTAL, x.NUM_NEEDED_TOTAL_BY_POS)) AS TOTAL_NUM_NEEDED
	FROM (SELECT	vo.VNUM,
					vo.NUM_NEEDED_TOTAL,
					CASE WHEN SUM(ISNULL(pr.NUM_NEEDED,0))=0 THEN 1 ELSE SUM(ISNULL(pr.NUM_NEEDED,0)) END AS NUM_NEEDED_TOTAL_BY_POS
			FROM VOL_OP_CM pr
			INNER JOIN VOL_Opportunity vo 
				ON pr.VNUM=vo.VNUM
					AND (vo.MemberID=@MemberID
							OR EXISTS(SELECT *
								FROM VOL_OP_SharingProfile pr
								INNER JOIN GBL_SharingProfile shp
									ON pr.ProfileID=shp.ProfileID
										AND shp.Active=1
										AND (
											shp.CanUseAnyView=1
											OR EXISTS(SELECT * FROM GBL_SharingProfile_VOL_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
										)
								WHERE VNUM=vo.VNUM AND ShareMemberID_Cache=@MemberID)
						)
			INNER JOIN VOL_Opportunity_Description vod
				ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID
					AND (@CanSeeNonPublic=1 OR vod.NON_PUBLIC=0)
					AND (vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE())
					AND (@CanSeeExpired=1 OR vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())
					AND (@HidePastDueBy IS NULL OR (vod.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,vod.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
			INNER JOIN VOL_OP_CommunitySet cs
				ON vo.VNUM=cs.VNUM AND cs.CommunitySetID=@CommunitySetID
		WHERE pr.CM_ID IN (
						-- Given Communities (in the given group(s))
						SELECT ct.CM_ID
							FROM @CommunityTable ct
						-- Children of Given Communities
						UNION SELECT cmpl.CM_ID
							FROM @CommunityTable ct
							INNER JOIN GBL_Community_ParentList cmpl
								ON cmpl.Parent_CM_ID=ct.CM_ID
						-- Parents of Given Communities
						UNION SELECT cmpl.Parent_CM_ID
							FROM @CommunityTable ct
							INNER JOIN GBL_Community_ParentList cmpl
								ON cmpl.CM_ID=ct.CM_ID
						)
	GROUP BY vo.VNUM, vo.NUM_NEEDED_TOTAL) x

-- Position and Individual Summary by Community Group
SELECT	vcg.CommunityGroupID, vcgn.CommunityGroupName, 
		vcg.ImageURL,
		vb.BallFileName,
		COUNT(DISTINCT x.VNUM) AS TOTAL_NUM_POS,
		CASE WHEN SUM(ISNULL(x.NUM_NEEDED_TOTAL_BY_POS,0))=0 THEN 1 ELSE SUM(ISNULL(x.NUM_NEEDED_TOTAL_BY_POS,0)) END AS TOTAL_NUM_NEEDED
	FROM VOL_CommunityGroup vcg
	INNER JOIN VOL_CommunityGroup_Name vcgn
		ON vcg.CommunityGroupID=vcgn.CommunityGroupID AND vcgn.LangID=(SELECT TOP 1 LangID FROM VOL_CommunityGroup_Name WHERE CommunityGroupID=vcgn.CommunityGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_Ball vb
		ON vcg.BallID=vb.BallID
	INNER JOIN (SELECT	vcg.CommunityGroupID,
						vo.VNUM,
						CASE WHEN SUM(ISNULL(pr.NUM_NEEDED,0))=0 THEN 1 ELSE SUM(ISNULL(pr.NUM_NEEDED,0)) END AS NUM_NEEDED_TOTAL_BY_POS
			FROM VOL_CommunityGroup vcg
			INNER JOIN VOL_OP_CommunitySet cs
				ON cs.CommunitySetID=vcg.CommunitySetID
			INNER JOIN VOL_Opportunity vo 
				ON vo.VNUM=cs.VNUM
			INNER JOIN VOL_OP_CM pr
				ON vo.VNUM=pr.VNUM
					AND pr.CM_ID IN (
						-- Given Communities (in the given group(s))
						SELECT ct.CM_ID
							FROM @CommunityTable ct
							WHERE ct.CommunityGroupID=vcg.CommunityGroupID
						-- Children of Given Communities
						UNION SELECT cmpl.CM_ID
							FROM @CommunityTable ct
							INNER JOIN GBL_Community_ParentList cmpl
								ON cmpl.Parent_CM_ID=ct.CM_ID
							WHERE ct.CommunityGroupID=vcg.CommunityGroupID
						-- Parents of Given Communities
						UNION SELECT cmpl.Parent_CM_ID
							FROM @CommunityTable ct
							INNER JOIN GBL_Community_ParentList cmpl
								ON cmpl.CM_ID=ct.CM_ID
							WHERE ct.CommunityGroupID=vcg.CommunityGroupID
						)
			INNER JOIN VOL_Opportunity_Description vod
				ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID
					AND (vo.MemberID=@MemberID
							OR EXISTS(SELECT *
								FROM VOL_OP_SharingProfile pr
								INNER JOIN GBL_SharingProfile shp
									ON pr.ProfileID=shp.ProfileID
										AND shp.Active=1
										AND (
											shp.CanUseAnyView=1
											OR EXISTS(SELECT * FROM GBL_SharingProfile_VOL_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
										)
								WHERE VNUM=vo.VNUM AND ShareMemberID_Cache=@MemberID)
						)
					AND (@CanSeeNonPublic=1 OR vod.NON_PUBLIC=0)
					AND (vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE())
					AND (@CanSeeExpired=1 OR vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())
					AND (@HidePastDueBy IS NULL OR (vod.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,vod.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
		WHERE vcg.CommunitySetID=@CommunitySetID
		GROUP BY vcg.CommunityGroupID, vo.VNUM
	) x
		ON x.CommunityGroupID=vcg.CommunityGroupID
GROUP BY vcg.CommunityGroupID, vcgn.CommunityGroupName, vcg.ImageURL, vb.BallFileName
ORDER BY vcgn.CommunityGroupName

SELECT	x.CommunityGroupID, x.CM_ID, x.Community,
		COUNT(DISTINCT x.VNUM) AS NUM_POS,
		CASE WHEN SUM(ISNULL(x.NUM_NEEDED,0))=0 THEN 1 ELSE SUM(ISNULL(x.NUM_NEEDED,0)) END AS NUM_NEEDED
	FROM (SELECT vcg.CommunityGroupID, ct.CM_ID, ct.Community, vo.VNUM, pr.OP_CM_ID, pr.NUM_NEEDED
		FROM @CommunityTable ct
		INNER JOIN VOL_CommunityGroup vcg
			ON vcg.CommunityGroupID=ct.CommunityGroupID
		INNER JOIN VOL_OP_CM pr
			ON pr.CM_ID IN (
					-- Given Communities (in the given group(s))
					SELECT ct.CM_ID
					-- Children of Given Communities
					UNION SELECT cmpl.CM_ID
						FROM GBL_Community_ParentList cmpl
						WHERE cmpl.Parent_CM_ID=ct.CM_ID
					-- Parents of Given Communities
					UNION SELECT cmpl.Parent_CM_ID
						FROM GBL_Community_ParentList cmpl
						WHERE cmpl.CM_ID=ct.CM_ID
				)
		INNER JOIN VOL_Opportunity vo 
			ON pr.VNUM=vo.VNUM
				AND (vo.MemberID=@MemberID
						OR EXISTS(SELECT *
							FROM VOL_OP_SharingProfile pr
							INNER JOIN GBL_SharingProfile shp
								ON pr.ProfileID=shp.ProfileID
									AND shp.Active=1
									AND (
										shp.CanUseAnyView=1
										OR EXISTS(SELECT * FROM GBL_SharingProfile_VOL_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
									)
							WHERE VNUM=vo.VNUM AND ShareMemberID_Cache=@MemberID)
					)
		INNER JOIN VOL_Opportunity_Description vod
			ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID
				AND (@CanSeeNonPublic=1 OR vod.NON_PUBLIC=0)
				AND (vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE())
				AND (@CanSeeExpired=1 OR vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())
				AND (@HidePastDueBy IS NULL OR (vod.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,vod.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
		INNER JOIN VOL_OP_CommunitySet cs
			ON vo.VNUM=cs.VNUM AND cs.CommunitySetID=@CommunitySetID
		) x
		INNER JOIN VOL_CommunityGroup_Name vcgn
			ON x.CommunityGroupID=vcgn.CommunityGroupID AND vcgn.LangID=(SELECT TOP 1 LangID FROM VOL_CommunityGroup_Name WHERE CommunityGroupID=vcgn.CommunityGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
GROUP BY x.CommunityGroupID, vcgn.CommunityGroupName, x.CM_ID, x.Community
ORDER BY vcgn.CommunityGroupName, x.Community

SET NOCOUNT OFF





GO



GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_CM_lc] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_CM_lc] TO [cioc_vol_search_role]
GO
