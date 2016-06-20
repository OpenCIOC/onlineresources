
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Term_Srch_Basic_Info]
	@Code [varchar](21),
	@ViewType [int],
	@NoDeleted [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@CanSeeDeleted bit,
		@HidePastDueBy int,
		@PB_ID int,
		@HasRelated bit,
		@HasChildren bit
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@CanSeeDeleted=CASE WHEN @NoDeleted=1 THEN 0 ELSE CanSeeDeleted END,
		@HidePastDueBy=HidePastDueBy,
		@PB_ID=PB_ID
FROM CIC_View
WHERE ViewType=@ViewType

DECLARE @PotentialRelated TABLE (
	Code varchar(21) PRIMARY KEY
)

INSERT INTO @PotentialRelated (
	Code
)
SELECT DISTINCT tmx2.Code
	FROM TAX_SeeAlso sa
	INNER JOIN TAX_Term tm2
		ON sa.SA_Code=tm2.Code
	INNER JOIN TAX_Term tmx2
		ON tmx2.CdLvl1=tm2.CdLvl1 AND tmx2.CdLvl >= tm2.CdLvl AND tmx2.Code LIKE tm2.Code + '%'
	WHERE sa.Code=@Code
	
SELECT @HasRelated = CASE WHEN EXISTS(SELECT TOP 1 *
				FROM @PotentialRelated pr
				INNER JOIN CIC_BT_TAX_TM tlt
					ON tlt.Code=pr.Code
				INNER JOIN CIC_BT_TAX tl
					ON tlt.BT_TAX_ID=tl.BT_TAX_ID
				INNER JOIN GBL_BaseTable bt
					ON tl.NUM=bt.NUM
				INNER JOIN GBL_BaseTable_Description btd
					ON bt.NUM=btd.NUM AND btd.LangID=@@LANGID
				WHERE (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
					AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
					AND (@CanSeeDeleted=1 OR btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
					AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
					AND (bt.MemberID=@MemberID
					/*
						OR EXISTS(SELECT *
							FROM GBL_BT_SharingProfile pr
							INNER JOIN GBL_SharingProfile shp
								ON pr.ProfileID=shp.ProfileID
									AND shp.Active=1
									AND (
										shp.CanUseAnyView=1
										OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
									)
							WHERE NUM=bt2.NUM AND ShareMemberID_Cache=@MemberID)
								*/
					)
			) THEN 1 ELSE 0 END

SELECT @HasChildren=CAST(CASE WHEN EXISTS(SELECT *
				FROM TAX_Term_ParentList tmpl
				INNER JOIN CIC_BT_TAX_TM tlt2
					ON tlt2.Code=tmpl.Code
				INNER JOIN CIC_BT_TAX tl2
					ON tlt2.BT_TAX_ID=tl2.BT_TAX_ID
				INNER JOIN GBL_BaseTable bt2
					ON tl2.NUM=bt2.NUM
				INNER JOIN GBL_BaseTable_Description btd2
					ON bt2.NUM=btd2.NUM AND btd2.LangID=@@LANGID
				WHERE tmpl.ParentCode=@Code
					AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt2.NUM AND PB_ID=@PB_ID))
					AND (@CanSeeNonPublic=1 OR btd2.NON_PUBLIC=0)
					AND (@CanSeeDeleted=1 OR btd2.DELETION_DATE IS NULL OR btd2.DELETION_DATE > GETDATE())
					AND (@HidePastDueBy IS NULL OR (btd2.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd2.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
					AND (bt2.MemberID=@MemberID
					/*
						OR EXISTS(SELECT *
							FROM GBL_BT_SharingProfile pr
							INNER JOIN GBL_SharingProfile shp
								ON pr.ProfileID=shp.ProfileID
									AND shp.Active=1
									AND (
										shp.CanUseAnyView=1
										OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
									)
							WHERE NUM=bt2.NUM AND ShareMemberID_Cache=@MemberID)
							*/
					) 
			) THEN 1 ELSE 0 END AS bit)


SELECT tm.Code, tm.CdLvl,
		CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID) THEN 1 ELSE 0 END AS bit) AS Active,
		ISNULL(tmd.AltTerm, tmd.Term) AS Term,
		ISNULL(AltDefinition, Definition) AS Definition,
		ParentCode,
		(SELECT ISNULL(tmd2.AltTerm, tmd2.Term)
			FROM TAX_Term tm2
			INNER JOIN TAX_Term_Description tmd2
				ON tm2.Code=tmd2.Code AND LangID=@@LANGID
			WHERE tm2.Code=tm.ParentCode) AS ParentTerm,
		@HasChildren AS HasChildren,
		@HasRelated AS HasRelated
	FROM TAX_Term tm
	LEFT JOIN TAX_Term_Description tmd
		ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID
WHERE tm.Code=@Code
	AND (
		tm.Active=1
		OR EXISTS(SELECT * FROM TAX_Term tmx INNER JOIN TAX_Term_ParentList tmpl ON tmpl.Code=tmx.Code AND tmpl.ParentCode=tm.Code AND tmx.Active=1)
	)
ORDER BY Code

SET NOCOUNT OFF




GO


GRANT EXECUTE ON  [dbo].[sp_TAX_Term_Srch_Basic_Info] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_TAX_Term_Srch_Basic_Info] TO [cioc_login_role]
GO
