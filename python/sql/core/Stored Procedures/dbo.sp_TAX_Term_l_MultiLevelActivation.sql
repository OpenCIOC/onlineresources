SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Term_l_MultiLevelActivation]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 11-May-2012
	Action: NO ACTION REQUIRED
*/

SELECT tm.Code, tmd.Term,
		(SELECT COUNT(DISTINCT bt.NUM)
			FROM CIC_BT_TAX_TM tlt
			INNER JOIN CIC_BT_TAX tl
				ON tlt.BT_TAX_ID=tl.BT_TAX_ID
			INNER JOIN GBL_BaseTable bt
				ON tl.NUM=bt.NUM
					AND (
						bt.MemberID=@MemberID
						OR EXISTS(SELECT * FROM GBL_BT_SharingProfile bts WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
					)
			WHERE Code=tm.Code) AS Usage
	FROM TAX_Term tm
	INNER JOIN TAX_Term_Description tmd
		ON tm.Code=tmd.Code AND LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE Code=tm.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID)
		AND tm.Code NOT LIKE 'Y%'
		AND tm.CdLvl <> 1
		AND (
			EXISTS(SELECT * FROM TAX_Term tm2
				WHERE tm2.Code<>tm.Code AND tm2.Code LIKE tm.Code + '%'
					AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm2.Code AND MemberID=@MemberID))
			OR EXISTS(SELECT * FROM TAX_Term tm2
				WHERE tm2.Code<>tm.Code AND tm.Code LIKE tm2.Code + '%' AND tm2.CdLvl <> 1
					AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm2.Code AND MemberID=@MemberID))
		)
ORDER BY Code

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Term_l_MultiLevelActivation] TO [cioc_login_role]
GO
