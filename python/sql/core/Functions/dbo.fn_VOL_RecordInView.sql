SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_RecordInView](
	@VNUM varchar(10),
	@ViewType [int],
	@LangID [smallint],
	@NoDeleted [bit],
	@Today [smalldatetime]
)
RETURNS [bit] WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@InView bit

SELECT @InView = CASE
		WHEN (
				vod.NON_PUBLIC=1
				AND vw.CanSeeNonPublic=0
			) 
			OR (
				(vw.CanSeeDeleted=0 OR @NoDeleted=1)
				AND vod.DELETION_DATE <= @Today
			)
			OR (
				vw.HidePastDueBy IS NOT NULL
				AND (vod.UPDATE_SCHEDULE IS NULL OR (DATEDIFF(d,vod.UPDATE_SCHEDULE,@Today) >= vw.HidePastDueBy))
			)
			OR (
				NOT EXISTS(SELECT * FROM VOL_OP_CommunitySet WHERE VNUM=@VNUM AND CommunitySetID=vw.CommunitySetID)
			) 
			OR NOT (
				EXISTS(SELECT * FROM VOL_View_Description vwd WHERE ViewType=vw.ViewType AND LangID=vod.LangID)
				OR (
					vw.ViewOtherLangs=1
					AND EXISTS(SELECT * FROM STP_Language WHERE LangID=vod.LangID AND Active=0 AND ActiveRecord=1)
				)
			)
			OR (
				vo.MemberID<>vw.MemberID
				AND NOT EXISTS(SELECT *
						FROM VOL_OP_SharingProfile pr
						INNER JOIN GBL_SharingProfile shp
							ON pr.ProfileID=shp.ProfileID
								AND shp.Active=1
								AND (
									shp.CanUseAnyView=1
									OR EXISTS(SELECT * FROM GBL_SharingProfile_VOL_View WHERE ProfileID=shp.ProfileID AND ViewType=vw.ViewType)
								)
						WHERE VNUM=vo.VNUM AND ShareMemberID_Cache=vw.MemberID)
			) THEN 0
		ELSE 1 END
	FROM VOL_View vw, VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=@LangID
WHERE vod.VNUM=@VNUM
	AND vw.ViewType=@ViewType
	
RETURN ISNULL(@InView,0)
	
END




GO
GRANT EXECUTE ON  [dbo].[fn_VOL_RecordInView] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_RecordInView] TO [cioc_vol_search_role]
GO
