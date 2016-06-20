SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMSetLNIDs_u]
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

DECLARE @tmpLNIDs TABLE(
	LN_ID int NOT NULL PRIMARY KEY
)

INSERT INTO @tmpLNIDs SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN GBL_Language ln
		ON tm.ItemID=ln.LN_ID

DELETE pr
	FROM CIC_BT_LN pr
	LEFT JOIN @tmpLNIDs tm
		ON pr.LN_ID = tm.LN_ID
WHERE tm.LN_ID IS NULL AND NUM=@NUM

INSERT INTO CIC_BT_LN (NUM, LN_ID) SELECT NUM=@NUM, tm.LN_ID
	FROM @tmpLNIDs tm
WHERE NOT EXISTS(SELECT * FROM CIC_BT_LN pr WHERE NUM=@NUM AND pr.LN_ID=tm.LN_ID)

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMSetLNIDs_u] TO [cioc_login_role]
GO
