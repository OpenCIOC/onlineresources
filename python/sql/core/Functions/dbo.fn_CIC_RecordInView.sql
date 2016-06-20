SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_RecordInView](
	@NUM [varchar](8),
	@ViewType [int],
	@LangID [smallint],
	@NoDeleted [bit],
	@Today [smalldatetime]
)
RETURNS [bit] WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 01-Feb-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@InView bit

SELECT @InView = CASE
		WHEN (
				btd.NON_PUBLIC=1
				AND vw.CanSeeNonPublic=0
			) 
			OR (
				(vw.CanSeeDeleted=0 OR @NoDeleted=1)
				AND btd.DELETION_DATE <= @Today
			)
			OR (
				vw.HidePastDueBy IS NOT NULL
				AND (btd.UPDATE_SCHEDULE IS NULL OR (DATEDIFF(d,btd.UPDATE_SCHEDULE,@Today) >= vw.HidePastDueBy))
			)
			OR (
				vw.PB_ID IS NOT NULL
				AND NOT EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=vw.PB_ID)
			) 
			OR NOT (
				EXISTS(SELECT * FROM CIC_View_Description vwd WHERE ViewType=vw.ViewType AND LangID=btd.LangID)
				OR (
					vw.ViewOtherLangs=1
					AND EXISTS(SELECT * FROM STP_Language WHERE LangID=btd.LangID AND Active=0 AND ActiveRecord=1)
				)
			)
			OR (
				bt.MemberID<>vw.MemberID
				AND NOT EXISTS(SELECT *
						FROM GBL_BT_SharingProfile pr
						INNER JOIN GBL_SharingProfile shp
							ON pr.ProfileID=shp.ProfileID
								AND shp.Active=1
								AND (
									shp.CanUseAnyView=1
									OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=vw.ViewType)
								)
						WHERE NUM=bt.NUM AND ShareMemberID_Cache=vw.MemberID)
			) THEN 0
		ELSE 1 END
	FROM CIC_View vw, GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=@LangID
WHERE bt.NUM=@NUM
	AND vw.ViewType=@ViewType
	
RETURN ISNULL(@InView,0)

END



GO
GRANT EXECUTE ON  [dbo].[fn_CIC_RecordInView] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_RecordInView] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_RecordInView] TO [cioc_vol_search_role]
GO
