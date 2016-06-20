SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMSetNAICSCodes_u]
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

DECLARE @tmpNAICSCodes TABLE(
	Code varchar(6) COLLATE Latin1_General_100_CI_AI NOT NULL PRIMARY KEY
)

INSERT INTO @tmpNAICSCodes SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseVarCharIDList(@IdList,';') tm
	INNER JOIN NAICS nc
		ON tm.ItemID=nc.Code COLLATE Latin1_General_100_CI_AI

DELETE pr
	FROM CIC_BT_NC pr
	LEFT JOIN @tmpNAICSCodes tm
		ON pr.Code = tm.Code
WHERE tm.Code IS NULL AND NUM=@NUM

INSERT INTO CIC_BT_NC (NUM, Code) SELECT NUM=@NUM, tm.Code
	FROM @tmpNAICSCodes tm
WHERE NOT EXISTS(SELECT * FROM CIC_BT_NC pr WHERE NUM=@NUM AND pr.Code=tm.Code)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMSetNAICSCodes_u] TO [cioc_login_role]
GO
