SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMSetMTIDs_u]
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
	Notes: For future, incoporate MERGE statement
*/

DECLARE @tmpMTIDs TABLE(
	MT_ID int NOT NULL PRIMARY KEY
)

INSERT INTO @tmpMTIDs SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN CIC_MembershipType mt
		ON tm.ItemID=mt.MT_ID

DELETE pr
	FROM CIC_BT_MT pr
	LEFT JOIN @tmpMTIDs tm
		ON pr.MT_ID = tm.MT_ID
WHERE tm.MT_ID IS NULL AND NUM=@NUM

INSERT INTO CIC_BT_MT (NUM, MT_ID) SELECT NUM=@NUM, tm.MT_ID
	FROM @tmpMTIDs tm
WHERE NOT EXISTS(SELECT * FROM CIC_BT_MT pr WHERE NUM=@NUM AND pr.MT_ID=tm.MT_ID)

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMSetMTIDs_u] TO [cioc_login_role]
GO
