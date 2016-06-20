SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMSetSubjIDs_u]
	@NUM varchar(8),
	@IdList varchar(max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 06-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @tmpSubjIDs TABLE(
	Subj_ID int NOT NULL PRIMARY KEY
)

INSERT INTO @tmpSubjIDs SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN THS_Subject sj ON tm.ItemID = sj.Subj_ID
	WHERE EXISTS(SELECT * FROM STP_Member mem WHERE NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE Subj_ID=sj.Subj_ID AND MemberID=mem.MemberID))

DELETE pr
	FROM CIC_BT_SBJ pr
	LEFT JOIN @tmpSubjIDs tm
		ON pr.Subj_ID = tm.Subj_ID
WHERE tm.Subj_ID IS NULL AND NUM=@NUM
INSERT INTO CIC_BT_SBJ (NUM, Subj_ID) SELECT NUM=@NUM, tm.Subj_ID
	FROM @tmpSubjIDs tm
WHERE NOT EXISTS(SELECT * FROM CIC_BT_SBJ pr WHERE NUM=@NUM AND pr.Subj_ID=tm.Subj_ID)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMSetSubjIDs_u] TO [cioc_login_role]
GO
