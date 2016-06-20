
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_c_Records]
	@ViewType [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 26-May-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@HidePastDueBy int,
		@PB_ID int
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@HidePastDueBy=HidePastDueBy,
		@PB_ID=PB_ID
FROM CIC_View
WHERE ViewType=@ViewType

SELECT COUNT(*) AS RecordsInView
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
			AND btd.LangID=@@LANGID
			AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
			AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
			AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
WHERE (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
		AND (bt.MemberID=@MemberID
				OR EXISTS(SELECT *
					FROM GBL_BT_SharingProfile pr
					INNER JOIN GBL_SharingProfile shp
						ON pr.ProfileID=shp.ProfileID
							AND shp.Active=1
							AND (
								shp.CanUseAnyView=1
								OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
							)
					WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
			)

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_View_c_Records] TO [cioc_cic_search_role]
GO
