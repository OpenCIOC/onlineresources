SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Term_ActiveUsed_l]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 06-May-2013
	Action: NO ACTION REQUIRED
*/

SET ANSI_WARNINGS OFF

SELECT tm.Code, tmd.Term,
	(SELECT COUNT(*) FROM CIC_BT_TAX_TM tt
		INNER JOIN CIC_BT_TAX tl
			ON tt.BT_TAX_ID=tl.BT_TAX_ID
		INNER JOIN GBL_BaseTable bt
			ON tl.NUM=bt.NUM AND bt.MemberID=@MemberID
		WHERE Code=tm.Code) AS Usage,
		(SELECT COUNT(*) FROM CIC_BT_TAX_TM tt
		INNER JOIN CIC_BT_TAX tl
			ON tt.BT_TAX_ID=tl.BT_TAX_ID
		INNER JOIN GBL_BaseTable bt
			ON tl.NUM=bt.NUM AND (bt.MemberID<>@MemberID
					AND EXISTS(SELECT *
						FROM GBL_BT_SharingProfile pr
						INNER JOIN GBL_SharingProfile shp
							ON pr.ProfileID=shp.ProfileID
								AND shp.Active=1
						WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
				)
		WHERE Code=tm.Code) AS UsageShared
FROM TAX_Term tm
INNER JOIN TAX_Term_Description tmd
	ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID
WHERE tm.Active=1
ORDER BY tm.Code

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Term_ActiveUsed_l] TO [cioc_login_role]
GO
