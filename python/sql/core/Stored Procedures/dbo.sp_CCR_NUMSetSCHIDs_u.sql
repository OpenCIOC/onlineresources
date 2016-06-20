SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CCR_NUMSetSCHIDs_u]
	@NUM varchar(8),
	@IdList varchar(max),
	@UpdateEscort bit,
	@UpdateInArea bit
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

DECLARE @tmpSCHIDs TABLE(
	SCH_ID int NOT NULL PRIMARY KEY
)

INSERT INTO @tmpSCHIDs
SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN CCR_School sch
		ON tm.ItemID=sch.SCH_ID

DELETE pr
	FROM CCR_BT_SCH pr
	LEFT JOIN @tmpSCHIDs tm
		ON pr.SCH_ID = tm.SCH_ID
WHERE tm.SCH_ID IS NULL
		AND NUM=@NUM
		AND (@UpdateInArea=0 OR Escort=0)
		AND (@UpdateEscort=0 OR InArea=0)

IF @UpdateEscort=1 BEGIN
	UPDATE pr
		SET	Escort = CASE WHEN tm.SCH_ID IS NULL THEN 0 ELSE 1 END
		FROM CCR_BT_SCH pr
		LEFT JOIN @tmpSCHIDs tm
			ON pr.SCH_ID = tm.SCH_ID
	WHERE NUM=@NUM
END

IF @UpdateInArea=1 BEGIN
	UPDATE pr
		SET	InArea = CASE WHEN tm.SCH_ID IS NULL THEN 0 ELSE 1 END
		FROM CCR_BT_SCH pr
		LEFT JOIN @tmpSCHIDs tm
			ON pr.SCH_ID = tm.SCH_ID
	WHERE NUM=@NUM
END

INSERT INTO CCR_BT_SCH (
	NUM,
	SCH_ID,
	Escort,
	InArea
)
SELECT	@NUM,
		tm.SCH_ID,
		@UpdateEscort,
		@UpdateInArea
	FROM @tmpSCHIDs tm
WHERE NOT EXISTS(SELECT * FROM CCR_BT_SCH pr WHERE NUM=@NUM AND pr.SCH_ID=tm.SCH_ID)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CCR_NUMSetSCHIDs_u] TO [cioc_login_role]
GO
