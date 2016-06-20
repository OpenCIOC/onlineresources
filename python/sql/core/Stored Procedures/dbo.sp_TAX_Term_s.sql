SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Term_s]
	@MemberID int,
	@Code varchar(21)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 04-Jun-2012
	Action: NO ACTION REQUIRED
*/

SET ANSI_WARNINGS OFF

SELECT tm.*,
		CAST(CASE
				WHEN tm.CdLvl>1
				AND (
					EXISTS(SELECT * FROM TAX_Term WHERE Code=tm.ParentCode AND Active=1)
					OR EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code AND Active=1)
					OR (
						NOT EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl>tm.CdLvl AND Code LIKE tm.Code+'%' AND Active=1) 
						AND NOT EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl<tm.CdLvl AND tm.Code LIKE Code+'%' AND Active=1)
					)
				) THEN 1 ELSE 0 END AS bit) AS CAN_ACTIVATE,
		CAST(CASE WHEN NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM WHERE Code=tm.Code)
				AND (
					tm.CdLvl = 6
					OR NOT EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code)
					OR EXISTS(SELECT * FROM TAX_Term WHERE Code=tm.ParentCode AND NOT Active=1)
					OR EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code AND NOT Active=1)
				)
				THEN 1 ELSE 0 END AS bit) AS CAN_DEACTIVATE,
		CAST(CASE
				WHEN NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM WHERE Code=tm.Code)
					AND EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl<tm.CdLvl AND tm.Code LIKE Code+'%' AND Active=1)
					AND NOT EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl>tm.CdLvl AND Code LIKE tm.Code+'%' AND Active=1)
				THEN 1 ELSE 0 END AS bit) AS CAN_ROLLUP,
		ISNULL(x.UsageCountLocal,0) AS UsageCountLocal,
		ISNULL(x.UsageCountOther,0) AS UsageCountOther,
		ISNULL(x.UsageCountShared,0) AS UsageCountShared,
		(SELECT tmd.*, l.Culture 
			FROM TAX_Term_Description tmd
			INNER JOIN STP_Language l
				ON tmd.LangID=l.LangID
			WHERE tmd.Code=tm.Code
			FOR XML PATH('DESC'), TYPE) AS Descriptions
	FROM TAX_Term tm
	LEFT JOIN (
			SELECT
				tlt.Code,
				COUNT(DISTINCT CASE WHEN bt.MemberID=@MemberID THEN bt.NUM ELSE NULL END) AS UsageCountLocal,
				COUNT(DISTINCT CASE WHEN bt.MemberID<>@MemberID THEN bt.NUM ELSE NULL END) AS UsageCountOther,
				COUNT(DISTINCT CASE WHEN shp.BT_ShareProfile_ID IS NOT NULL THEN bt.NUM ELSE NULL END) AS UsageCountShared
			FROM CIC_BT_TAX_TM tlt
			INNER JOIN CIC_BT_TAX tl
				ON tlt.BT_TAX_ID=tl.BT_TAX_ID
			INNER JOIN GBL_BaseTable bt
				ON tl.NUM=bt.NUM
			LEFT JOIN GBL_BT_SharingProfile shp
				ON bt.MemberID<>@MemberID AND shp.NUM=bt.NUM AND shp.ShareMemberID_Cache=@MemberID
			WHERE tlt.Code=@Code
			GROUP BY tlt.Code
		) x
			ON tm.Code=x.Code
WHERE tm.Code=@Code



SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Term_s] TO [cioc_login_role]
GO
