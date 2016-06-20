
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_VOL_PopularInterest_Feed]
	@ViewType int,
	@FeedAPIKey uniqueidentifier = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 22-Nov-2015
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

SELECT TOP 9 ai.AI_ID, ain.Name AS InterestName, COUNT(DISTINCT vo.VNUM) AS UsageCount
	FROM VOL_Interest ai
	INNER JOIN VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID
			AND ain.LangID=@@LANGID
	LEFT JOIN VOL_OP_AI pr
		ON ai.AI_ID = pr.AI_ID
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
			AND (vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())
			AND (@HidePastDueBy IS NULL OR (vod.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,vod.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
	INNER JOIN VOL_OP_CommunitySet cs
		ON vo.VNUM=cs.VNUM AND cs.CommunitySetID=@CommunitySetID
	LEFT JOIN (
		SELECT AI_ID, COUNT(*) AS PROFILE_COUNT
		FROM dbo.VOL_Profile_AI
		GROUP BY AI_ID
	) vpai ON vpai.AI_ID = ai.AI_ID
	LEFT JOIN (
		SELECT VNUM, COUNT(*) AS REFERRAL_COUNT_30
		FROM dbo.VOL_OP_Referral
		WHERE CREATED_DATE > DATEADD(d,-30,GETDATE())
		GROUP BY VNUM
	) ref ON ref.VNUM=vod.VNUM
WHERE (@FeedAPIKey IS NULL OR EXISTS(SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey AND Inactive=0 AND VOL=1))
GROUP BY ai.AI_ID, ain.Name
ORDER BY SUM(vpai.PROFILE_COUNT) DESC,
	SUM(ref.REFERRAL_COUNT_30) DESC,
	ain.Name

RETURN CASE WHEN @FeedAPIKey IS NULL OR EXISTS(SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey AND Inactive=0 AND VOL=1) THEN 0 ELSE -1 END
GO



GRANT EXECUTE ON  [dbo].[sp_VOL_PopularInterest_Feed] TO [cioc_vol_search_role]
GO
