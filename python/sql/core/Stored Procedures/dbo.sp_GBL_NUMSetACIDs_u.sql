SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_NUMSetACIDs_u]
	@NUM varchar(8),
	@IdList varchar(max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 23-Dec-2011
	Action: NO ACTION REQUIRED
	Notes: For future, incoporate MERGE statement
*/

DECLARE @tmpACIDs TABLE(AC_ID int)

INSERT INTO @tmpACIDs SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN GBL_Accessibility ac
		ON tm.ItemID=ac.AC_ID

DELETE pr
	FROM GBL_BT_AC pr
	LEFT JOIN @tmpACIDs tm
		ON pr.AC_ID = tm.AC_ID
WHERE tm.AC_ID IS NULL AND NUM=@NUM

INSERT INTO GBL_BT_AC (NUM, AC_ID) SELECT NUM=@NUM, tm.AC_ID
	FROM @tmpACIDs tm
WHERE NOT EXISTS(SELECT * FROM GBL_BT_AC pr WHERE NUM=@NUM AND pr.AC_ID=tm.AC_ID)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_NUMSetACIDs_u] TO [cioc_login_role]
GO
