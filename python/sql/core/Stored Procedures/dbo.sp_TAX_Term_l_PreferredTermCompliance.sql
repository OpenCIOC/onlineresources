
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Term_l_PreferredTermCompliance]
	@MemberID int,
	@SuperUserGlobal bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: KL
	Checked on: 01-May-2015
	Action: NO ACTION REQUIRED
*/

SELECT tm.Code, tmd.Term,
		CASE WHEN (@SuperUserGlobal=1 AND tm.Active=1) OR (@SuperUserGlobal=0 AND am.Code IS NOT NULL) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS Active,
		tm.PreferredTerm,
		CASE WHEN tm.PreferredTerm=0 THEN tmd2.Code ELSE NULL END AS AutoFixCode,
		CASE WHEN tm.PreferredTerm=0 THEN tmd2.Term ELSE NULL END AS AutoFixTerm,
		 CASE WHEN @SuperUserGlobal=1 THEN (SELECT COUNT(DISTINCT bt.NUM) FROM CIC_BT_TAX tl INNER JOIN CIC_BT_TAX_TM tlt ON tl.BT_TAX_ID=tlt.BT_TAX_ID INNER JOIN GBL_BaseTable bt ON tl.NUM=bt.NUM WHERE Code=tm.Code AND MemberID<>@MemberID) ELSE 0 END AS UsageCountOther,
		 (SELECT COUNT(DISTINCT bt.NUM) FROM CIC_BT_TAX tl INNER JOIN CIC_BT_TAX_TM tlt ON tl.BT_TAX_ID=tlt.BT_TAX_ID INNER JOIN GBL_BaseTable bt ON tl.NUM=bt.NUM WHERE Code=tm.Code AND MemberID=@MemberID) AS UsageCountLocal,
		 CASE WHEN NOT EXISTS(SELECT * FROM TAX_Term tm2 WHERE tm2.PreferredTerm=1
					AND (
						(tm2.CdLvl > tm.CdLvl AND tm2.CdLvl1=tm.CdLvl1 AND tm2.Code LIKE tm.Code + '%')
						OR (tm2.CdLvl < tm.CdLvl AND tm2.CdLvl1=tm.CdLvl1 AND tm.Code LIKE tm2.Code + '%')
						)
					) THEN 1 ELSE 0 END AS OrphanWarning
	FROM TAX_Term tm
	INNER JOIN TAX_Term_Description tmd
		ON tm.Code=tmd.Code AND tmd.LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE Code=tmd.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN TAX_Term_Description tmd2
		ON tmd2.Code=(SELECT MAX(Code) FROM TAX_Term tm2 WHERE tm2.PreferredTerm=1 AND tm2.CdLvl < tm.CdLvl AND tm2.CdLvl1=tm.CdLvl1 AND tm.Code LIKE tm2.Code + '%')
			AND tmd2.LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE Code=tmd2.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN TAX_Term_ActivationByMember am
		ON am.Code = tm.Code AND am.MemberID=@MemberID
WHERE (tm.PreferredTerm=0 AND ((@SuperUserGlobal=1 AND tm.Active=1) OR (@SuperUserGlobal=0 AND am.Code IS NOT NULL))
			AND (
				EXISTS(SELECT * FROM TAX_Term tm2 WHERE tm2.PreferredTerm=1
					AND (
						(tm2.CdLvl > tm.CdLvl AND tm2.CdLvl1=tm.CdLvl1 AND tm2.Code LIKE tm.Code + '%')
						OR (tm2.CdLvl < tm.CdLvl AND tm2.CdLvl1=tm.CdLvl1 AND tm.Code LIKE tm2.Code + '%')
						)
					)
				OR EXISTS(SELECT * FROM TAX_Term tm2 WHERE tm2.PreferredTerm=1
					AND tm2.ParentCode=tm.ParentCode
					)
			)
		)
	OR (tm.PreferredTerm=1 AND ((@SuperUserGlobal=1 AND tm.Active=0) OR (@SuperUserGlobal=0 AND am.Code IS NULL)))

ORDER BY Code

SET NOCOUNT OFF


GO


GRANT EXECUTE ON  [dbo].[sp_TAX_Term_l_PreferredTermCompliance] TO [cioc_login_role]
GO
