SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_GBL_NUMSetLOCATION_SERVICES_NUMs_u]
	@NUM varchar(8),
	@IdList varchar(max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 20-Jan-2012
	Action: IN PROGRESS
*/

DECLARE @tmpSERVICE_NUMs TABLE(
	SERVICE_NUM varchar(8) COLLATE Latin1_General_100_CI_AI NOT NULL PRIMARY KEY 
)

INSERT INTO @tmpSERVICE_NUMs SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseVarCharIDList(@IdList,',') tm
	INNER JOIN GBL_BaseTable bt
		ON tm.ItemID=bt.NUM COLLATE Latin1_General_100_CI_AI 
			AND bt.NUM<>@NUM COLLATE Latin1_General_100_CI_AI
			
MERGE INTO GBL_BT_LOCATION_SERVICE dst
USING @tmpSERVICE_NUMs src
ON dst.SERVICE_NUM=src.SERVICE_NUM AND dst.LOCATION_NUM=@NUM
WHEN NOT MATCHED BY TARGET THEN
	INSERT (LOCATION_NUM, SERVICE_NUM)
		VALUES (@NUM, src.SERVICE_NUM)
WHEN NOT MATCHED BY SOURCE AND dst.LOCATION_NUM=@NUM THEN
	DELETE
	;
	

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_NUMSetLOCATION_SERVICES_NUMs_u] TO [cioc_login_role]
GO
