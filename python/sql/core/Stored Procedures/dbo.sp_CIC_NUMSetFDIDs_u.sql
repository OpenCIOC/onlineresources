SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMSetFDIDs_u]
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

DECLARE @tmpFDIDs TABLE(
	FD_ID int NOT NULL PRIMARY KEY
)

INSERT INTO @tmpFDIDs SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN CIC_Funding fd
		ON tm.ItemID = fd.FD_ID

DELETE pr
	FROM CIC_BT_FD pr
	LEFT JOIN @tmpFDIDs tm
		ON pr.FD_ID = tm.FD_ID
WHERE tm.FD_ID IS NULL AND NUM=@NUM

INSERT INTO CIC_BT_FD (NUM, FD_ID) SELECT NUM=@NUM, tm.FD_ID
	FROM @tmpFDIDs tm
WHERE NOT EXISTS(SELECT * FROM CIC_BT_FD pr WHERE NUM=@NUM AND pr.FD_ID=tm.FD_ID)

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMSetFDIDs_u] TO [cioc_login_role]
GO
