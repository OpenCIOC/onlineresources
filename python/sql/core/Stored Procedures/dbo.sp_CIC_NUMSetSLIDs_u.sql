SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMSetSLIDs_u]
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

DECLARE @tmpSLIDs TABLE(
	SL_ID int NOT NULL PRIMARY KEY
)

INSERT INTO @tmpSLIDs SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN CIC_ServiceLevel sl
		ON tm.ItemID = sl.SL_ID

DELETE pr
	FROM CIC_BT_SL pr
	LEFT JOIN @tmpSLIDs tm
		ON pr.SL_ID = tm.SL_ID
WHERE tm.SL_ID IS NULL AND NUM=@NUM

INSERT INTO CIC_BT_SL (NUM, SL_ID) SELECT NUM=@NUM, tm.SL_ID
	FROM @tmpSLIDs tm
WHERE NOT EXISTS(SELECT * FROM CIC_BT_SL pr WHERE NUM=@NUM AND pr.SL_ID=tm.SL_ID)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMSetSLIDs_u] TO [cioc_login_role]
GO
