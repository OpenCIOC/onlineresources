SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_BrowseBySubj]
	@Letter char(1),
	@ViewType [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 02-Feb-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@HidePastDueBy int,
		@PB_ID int,
		@UseLocalSubjects bit,
		@UseZeroSubjects bit
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@HidePastDueBy=HidePastDueBy,
		@PB_ID=PB_ID,
		@UseLocalSubjects=UseLocalSubjects,
		@UseZeroSubjects=UseZeroSubjects
FROM CIC_View
WHERE ViewType=@ViewType

SELECT sj.Subj_ID, sjn.Name AS SubjectTerm, sj.Used, sj.UseAll, COUNT(btd.NUM) AS UsageCount
	FROM THS_Subject sj
	INNER JOIN THS_Subject_Name sjn
		ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=@@LANGID
	LEFT JOIN CIC_BT_SBJ pr
		ON pr.Subj_ID=sj.Subj_ID
	LEFT JOIN GBL_BaseTable bt
		ON pr.NUM=bt.NUM 
			AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
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
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
			AND btd.LangID=@@LANGID
			AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
			AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
			AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
WHERE (sjn.Name LIKE @Letter + '%')
	AND (@UseLocalSubjects=1 OR Authorized=1)
GROUP BY sj.Subj_ID, sjn.Name, sj.Used, sj.UseAll
HAVING @UseZeroSubjects=1 OR COUNT(btd.NUM) > 0
ORDER BY sjn.Name

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_BrowseBySubj] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_BrowseBySubj] TO [cioc_login_role]
GO
