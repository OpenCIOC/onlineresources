SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMSetBRIDs_u]
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

DECLARE @tmpBRIDs TABLE(
	BR_ID int NOT NULL PRIMARY KEY
)

INSERT INTO @tmpBRIDs SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN CIC_BusRoute br
		ON tm.ItemID=br.BR_ID

DELETE pr
	FROM CIC_BT_BR pr
	LEFT JOIN @tmpBRIDs tm
		ON pr.BR_ID = tm.BR_ID
WHERE tm.BR_ID IS NULL AND NUM=@NUM

INSERT INTO CIC_BT_BR (NUM, BR_ID) SELECT NUM=@NUM, tm.BR_ID
	FROM @tmpBRIDs tm
WHERE NOT EXISTS(SELECT * FROM CIC_BT_BR pr WHERE NUM=@NUM AND pr.BR_ID=tm.BR_ID)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMSetBRIDs_u] TO [cioc_login_role]
GO
