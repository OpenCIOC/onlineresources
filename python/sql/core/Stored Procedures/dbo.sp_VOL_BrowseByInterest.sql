SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_BrowseByInterest]
	@Letter varchar(1),
	@ViewType int,
	@Exclude0 bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
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

SELECT ai.AI_ID, ain.Name AS InterestName, COUNT(vo.VNUM) AS UsageCount
	FROM VOL_Interest ai
	INNER JOIN VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID
			AND ain.LangID=@@LANGID
			AND (@Letter IS NULL OR ain.Name LIKE @Letter + '%')
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
			AND (@CanSeeExpired=1 OR vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())
			AND (@HidePastDueBy IS NULL OR (vod.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,vod.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
	INNER JOIN VOL_OP_CommunitySet cs
		ON vo.VNUM=cs.VNUM AND cs.CommunitySetID=@CommunitySetID
GROUP BY ai.AI_ID, ain.Name
HAVING (@Exclude0=0 OR COUNT(cs.VNUM) > 0)

ORDER BY ain.Name



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_BrowseByInterest] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_BrowseByInterest] TO [cioc_vol_search_role]
GO
