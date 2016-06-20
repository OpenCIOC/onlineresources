
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Spotlight_Feed]
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
		@CommunitySetID int,
		@HighlightOpportunity varchar(10)
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@CanSeeExpired=CanSeeExpired,
		@HidePastDueBy=HidePastDueBy,
		@CommunitySetID=CommunitySetID,
		@HighlightOpportunity=HighlightOpportunity
FROM VOL_View vw
INNER JOIN dbo.VOL_View_Description vwd
	ON vwd.ViewType = vw.ViewType AND vwd.LangID=@@LANGID
WHERE vw.ViewType=@ViewType

SELECT TOP 1 vo.VNUM,
		cioc_shared.dbo.fn_SHR_GBL_DateString(ISNULL(vod.UPDATE_DATE, vod.CREATED_DATE)) AS LAST_UPDATED,
		vod.POSITION_TITLE,
		dbo.fn_GBL_DisplayFullOrgName_2(btd.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		vod.DUTIES,
		vod.LOCATION
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
	LEFT JOIN (
		SELECT VNUM, COUNT(*) AS REFERRAL_COUNT_30
		FROM dbo.VOL_OP_Referral
		WHERE CREATED_DATE > DATEADD(d,-30,GETDATE())
		GROUP BY VNUM
	) ref ON ref.VNUM=vod.VNUM
WHERE (@FeedAPIKey IS NULL OR EXISTS(SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey AND Inactive=0 AND VOL=1))
ORDER BY CASE WHEN vo.VNUM=@HighlightOpportunity THEN 0 ELSE 1 END, NEWID()

RETURN CASE WHEN @FeedAPIKey IS NULL OR EXISTS(SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey AND Inactive=0 AND VOL=1) THEN 0 ELSE -1 END

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Spotlight_Feed] TO [cioc_vol_search_role]
GO
