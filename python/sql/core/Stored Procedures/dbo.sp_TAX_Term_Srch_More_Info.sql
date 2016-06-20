SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Term_Srch_More_Info]
	@Code [varchar](21),
	@ViewType [int],
	@Inactive [bit],
	@NoDeleted [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SET ANSI_WARNINGS OFF

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 11-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@CanSeeDeleted bit,
		@HidePastDueBy int,
		@PB_ID int
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@CanSeeDeleted=CASE WHEN @NoDeleted=1 THEN 0 ELSE CanSeeDeleted END,
		@HidePastDueBy=HidePastDueBy,
		@PB_ID=PB_ID
FROM CIC_View
WHERE ViewType=@ViewType

/* Select data management info, Definition, Parent Term info, Usage count for the given View */
SELECT tm.CREATED_DATE, tm.MODIFIED_DATE, 
		ISNULL(tmd.AltDefinition, tmd.Definition) AS Definition,
		tm.ParentCode,
		CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=ptm.Code AND MemberID=@MemberID) THEN 1 ELSE 0 END AS bit) AS ParentActive,
		ISNULL(ptmd.AltTerm, ptmd.Term) AS ParentTerm,
		COUNT(DISTINCT tl.NUM) AS ParentCountRecords
	FROM TAX_Term tm
	LEFT JOIN TAX_Term_Description tmd
		ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID
	LEFT JOIN TAX_Term ptm
		ON tm.ParentCode=ptm.Code
	LEFT JOIN TAX_Term_Description ptmd
		ON ptm.Code=ptmd.Code AND ptmd.LangID=@@LANGID
	LEFT JOIN CIC_BT_TAX_TM tlt
		ON tlt.Code=ptm.Code
	LEFT JOIN CIC_BT_TAX tl
		ON tlt.BT_TAX_ID=tl.BT_TAX_ID
			AND EXISTS(SELECT *
				FROM GBL_BaseTable bt
				INNER JOIN GBL_BaseTable_Description btd
					ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID
				WHERE bt.NUM=tl.NUM
					AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
					AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
					AND (@CanSeeDeleted=1 OR btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
					AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
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
				)
WHERE tm.Code=@Code
GROUP BY tm.CREATED_DATE, tm.MODIFIED_DATE, ISNULL(tmd.AltDefinition, tmd.Definition), tm.ParentCode, ptm.Code, ISNULL(ptmd.AltTerm, ptmd.Term)

/* Select Term name, Code info and record counts for Sub-Topics (child Terms) */
SELECT tm.Code, ISNULL(tmd.AltTerm, tmd.Term) AS Term,
		CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID) THEN 1 ELSE 0 END AS bit) AS Active,
		COUNT(DISTINCT tl.NUM) AS CountRecords
	FROM TAX_Term tm
	INNER JOIN TAX_Term_Description tmd
		ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID
	LEFT JOIN CIC_BT_TAX_TM tlt
		ON tlt.Code=tm.Code
	LEFT JOIN CIC_BT_TAX tl
		ON tlt.BT_TAX_ID=tl.BT_TAX_ID
			AND EXISTS(SELECT *
				FROM GBL_BaseTable bt
				INNER JOIN GBL_BaseTable_Description btd
					ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID
				WHERE bt.NUM=tl.NUM
					AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
					AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
					AND (@CanSeeDeleted=1 OR btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
					AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
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
				)
WHERE tm.ParentCode = @Code
	AND (@Inactive=1 OR EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID))
GROUP BY tm.Code, ISNULL(tmd.AltTerm, tmd.Term)
ORDER BY ISNULL(tmd.AltTerm, tmd.Term)

/* Select Term name, Code info and record counts for Related Terms ("See Also") */
SELECT tm.Code, ISNULL(tmd.AltTerm, tmd.Term) AS Term,
		CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID) THEN 1 ELSE 0 END AS bit) AS Active,
		COUNT(DISTINCT tl.NUM) AS CountRecords
	FROM TAX_Term tm
	INNER JOIN TAX_Term_Description tmd
		ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID
	LEFT JOIN CIC_BT_TAX_TM tlt
		ON tlt.Code=tm.Code
	LEFT JOIN CIC_BT_TAX tl
		ON tlt.BT_TAX_ID=tl.BT_TAX_ID
			AND EXISTS(SELECT *
				FROM GBL_BaseTable bt
				INNER JOIN GBL_BaseTable_Description btd
					ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID
				WHERE bt.NUM=tl.NUM
					AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
					AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
					AND (@CanSeeDeleted=1 OR btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
					AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
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
				)
WHERE EXISTS(SELECT * FROM TAX_SeeAlso sa WHERE sa.SA_Code=tm.Code AND sa.Code=@Code)
	AND (@Inactive=1 OR EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID))
GROUP BY tm.Code, ISNULL(tmd.AltTerm, tmd.Term)
ORDER BY ISNULL(tmd.AltTerm, tmd.Term)

/* Return Term name for Use References ("Used For"), including rolled-up terms */
SELECT Term, ut.Active, NULL AS Code
	FROM TAX_Unused ut	
	WHERE ut.Code=@Code
		AND ut.LangID=@@LANGID
		AND (@Inactive=1 OR ut.Active=1)
UNION SELECT ISNULL(tmd.AltTerm,tmd.Term) AS Term, NULL AS Active, tm.Code
		FROM TAX_Term tm2
		INNER JOIN TAX_Term tm
			ON tm.Code LIKE tm2.Code + '%'
				AND tm.CdLvl1 = tm2.CdLvl1
				AND tm.CdLvl2 = tm2.CdLvl2
				AND tm.CdLvl > tm2.CdLvl
		INNER JOIN TAX_Term_Description tmd
			ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID
	WHERE tm2.Code=@Code
		AND (
				(
					tm.Active IS NULL
					AND NOT EXISTS(SELECT * FROM TAX_Term tmx
						WHERE tmx.Code LIKE tm2.Code + '%'
							AND tmx.CdLvl1 = tm2.CdLvl1
							AND tmx.CdLvl2 = tm2.CdLvl2
							AND tmx.CdLvl > tm.CdLvl
							AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tmx.Code AND MemberID=@MemberID))
				)
			OR (
				tm.Active=1
				AND NOT EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID)
			)
		)

/* Return Related Concept Info */
SELECT rc.RC_ID, ConceptName
	FROM TAX_RelatedConcept rc
	INNER JOIN TAX_RelatedConcept_Name rcn
		ON rc.RC_ID=rcn.RC_ID AND LangID=@@LANGID
	INNER JOIN TAX_TM_RC trc
		ON rc.RC_ID=trc.RC_ID
WHERE trc.Code = @Code
ORDER BY ConceptName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Term_Srch_More_Info] TO [cioc_login_role]
GO
