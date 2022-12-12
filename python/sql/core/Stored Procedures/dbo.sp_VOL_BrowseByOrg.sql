SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_BrowseByOrg]
	@Letter varchar(1),
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

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
FROM dbo.VOL_View
WHERE ViewType=@ViewType

IF @Letter = '' SET @Letter = NULL

SELECT btd.NUM,
		dbo.fn_GBL_DisplayFullOrgName_2(btd.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		COUNT(vo.VNUM) AS OpCount
	FROM dbo.VOL_Opportunity vo
	INNER JOIN dbo.VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID
			AND (vo.MemberID=@MemberID
					OR EXISTS(SELECT *
						FROM dbo.VOL_OP_SharingProfile pr
						INNER JOIN dbo.GBL_SharingProfile shp
							ON pr.ProfileID=shp.ProfileID
								AND shp.Active=1
								AND (
									shp.CanUseAnyView=1
									OR EXISTS(SELECT * FROM dbo.GBL_SharingProfile_VOL_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
								)
						WHERE pr.VNUM=vo.VNUM AND pr.ShareMemberID_Cache=@MemberID)
				)
			AND (@CanSeeNonPublic=1 OR vod.NON_PUBLIC=0)
			AND (vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE())
			AND (@CanSeeExpired=1 OR vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= GETDATE())
			AND (@HidePastDueBy IS NULL OR (vod.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,vod.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
	INNER JOIN dbo.VOL_OP_CommunitySet cs
		ON vo.VNUM=cs.VNUM AND cs.CommunitySetID=@CommunitySetID
    INNER JOIN dbo.GBL_BaseTable btx
        ON btx.NUM = vo.NUM
	INNER JOIN dbo.GBL_BaseTable bt
		ON bt.NUM = ISNULL(btx.ORG_NUM,btx.NUM)
	INNER JOIN dbo.GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_BaseTable_Description WHERE NUM=vo.NUM ORDER BY CASE WHEN LangID=vod.LangID THEN 0 ELSE 1 END, LangID)
WHERE (
		(@Letter < 'A' AND 
			(((btd.SORT_AS_USELETTER IS NULL OR NOT btd.SORT_AS_USELETTER=1) AND btd.ORG_LEVEL_1 < 'A') OR ((btd.SORT_AS_USELETTER IS NULL OR NOT btd.SORT_AS_USELETTER=0) AND btd.SORT_AS < 'A'))
		)
		OR (((btd.SORT_AS_USELETTER IS NULL OR NOT btd.SORT_AS_USELETTER=1) AND btd.ORG_LEVEL_1 LIKE @Letter + '%') OR ((btd.SORT_AS_USELETTER IS NULL OR NOT btd.SORT_AS_USELETTER=0) AND btd.SORT_AS LIKE @Letter + '%'))
		OR (@Letter IS NULL)
	)
GROUP BY btd.NUM, btd.SORT_AS, btd.SORT_AS_USELETTER, btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, btd.LOCATION_NAME, btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2, bt.DISPLAY_ORG_NAME, bt.DISPLAY_LOCATION_NAME
ORDER BY CASE WHEN btd.SORT_AS_USELETTER IS NULL AND NOT LEFT(btd.SORT_AS,1)=LEFT(btd.ORG_LEVEL_1,1) AND btd.ORG_LEVEL_1 LIKE @Letter + '%' THEN btd.ORG_LEVEL_1 ELSE ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1) END,
		btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
		STUFF(
			CASE WHEN EXISTS(SELECT * FROM dbo.GBL_BT_OLS pr INNER JOIN dbo.GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)
				THEN NULL
				ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')
				 END,
			1, 2, ''
		)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_BrowseByOrg] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_BrowseByOrg] TO [cioc_vol_search_role]
GO
