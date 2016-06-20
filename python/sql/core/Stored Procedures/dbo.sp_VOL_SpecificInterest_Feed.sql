SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_VOL_SpecificInterest_Feed]
	@ViewType int,
	@FeedAPIKey uniqueidentifier = NULL,
	@Code varchar(20),
	@Duties bit = NULL,
	@Location bit = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 24-Nov-2015
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

SELECT TOP 30 vo.VNUM,
		vod.POSITION_TITLE,
		dbo.fn_GBL_DisplayFullOrgName_2(btd.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		cioc_shared.dbo.fn_SHR_GBL_DateString(ISNULL(vod.UPDATE_DATE, vod.CREATED_DATE)) AS LAST_UPDATED,
		CASE WHEN @Duties=1 THEN vod.DUTIES ELSE NULL END AS DUTIES,
		CASE WHEN @Location=1 THEN vod.LOCATION ELSE NULL END AS LOCATION
	FROM VOL_Opportunity vo
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
			AND (vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())
			AND (@HidePastDueBy IS NULL OR (vod.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,vod.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
	INNER JOIN VOL_OP_CommunitySet cs
		ON vo.VNUM=cs.VNUM AND cs.CommunitySetID=@CommunitySetID
	INNER JOIN GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=vo.NUM ORDER BY CASE WHEN LangID=vod.LangID THEN 0 ELSE 1 END, LangID)
	INNER JOIN dbo.VOL_OP_AI pr
		ON pr.VNUM = vo.VNUM
	INNER JOIN dbo.VOL_Interest ai
		ON ai.AI_ID = pr.AI_ID AND ai.Code=@Code
WHERE (@FeedAPIKey IS NULL OR EXISTS(SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey AND Inactive=0 AND VOL=1))
ORDER BY ISNULL(vod.UPDATE_DATE,vod.CREATED_DATE) DESC

RETURN CASE WHEN @FeedAPIKey IS NULL OR EXISTS(SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey AND Inactive=0 AND VOL=1) THEN 0 ELSE -1 END

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_SpecificInterest_Feed] TO [cioc_vol_search_role]
GO
