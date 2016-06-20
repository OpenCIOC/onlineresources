SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_NUMsToPotentialOrg_l]
	@IdList varchar(max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 06-Oct-2013
	Action: NO ACTION REQUIRED
*/

SELECT COUNT(DISTINCT ORG_LEVEL_1) AS ORG_LEVEL_1_COUNT
	FROM GBL_BaseTable_Description btd
	INNER JOIN GBL_BaseTable bt
		ON bt.NUM=btd.NUM
	INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@IdList,',') tm
		ON tm.ItemID=bt.NUM COLLATE Latin1_General_100_CI_AI
WHERE btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)

SELECT	obtd.NUM,
		ISNULL(obtd.ORG_LEVEL_1,'') + ISNULL(', ' + obtd.ORG_LEVEL_2,'') + ISNULL(', ' + obtd.ORG_LEVEL_3,'') + ISNULL(', ' + obtd.ORG_LEVEL_4,'') + ISNULL(', ' + obtd.ORG_LEVEL_5,'') AS ORG_NAME,
		CAST(CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code='AGENCY' WHERE pr.NUM=obtd.NUM) THEN 1 ELSE 0 END AS bit) AS IS_AGENCY
	FROM GBL_BaseTable_Description obtd
WHERE obtd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=obtd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description btd
				INNER JOIN GBL_BaseTable bt
					ON bt.NUM=btd.NUM
				INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@IdList,',') tm
					ON tm.ItemID=bt.NUM COLLATE Latin1_General_100_CI_AI
				WHERE btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AND obtd.NUM<>btd.NUM
					AND (
						(obtd.ORG_LEVEL_1=btd.ORG_LEVEL_1 AND (((obtd.ORG_LEVEL_2=btd.ORG_LEVEL_2 OR obtd.ORG_LEVEL_2 IS NULL) AND btd.ORG_LEVEL_2 IS NOT NULL) AND (obtd.ORG_LEVEL_3=btd.ORG_LEVEL_3 OR (obtd.ORG_LEVEL_3 IS NULL AND (obtd.ORG_LEVEL_2 IS NULL OR btd.ORG_LEVEL_3 IS NOT NULL))) AND (obtd.ORG_LEVEL_4=btd.ORG_LEVEL_4 OR (obtd.ORG_LEVEL_4 IS NULL AND (obtd.ORG_LEVEL_3 IS NULL OR btd.ORG_LEVEL_4 IS NOT NULL))) AND (obtd.ORG_LEVEL_4=btd.ORG_LEVEL_5 OR (obtd.ORG_LEVEL_5 IS NULL AND (obtd.ORG_LEVEL_4 IS NULL OR btd.ORG_LEVEL_5 IS NOT NULL)))))
						OR bt.ORG_NUM=obtd.NUM
					)
			)
ORDER BY IS_AGENCY DESC, obtd.ORG_LEVEL_1, obtd.ORG_LEVEL_2, obtd.ORG_LEVEL_3, obtd.ORG_LEVEL_4, obtd.ORG_LEVEL_5, 
	STUFF(
		CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=obtd.NUM)
			THEN NULL
			ELSE COALESCE(', ' + obtd.LOCATION_NAME,'') +
				COALESCE(', ' + obtd.SERVICE_NAME_LEVEL_1,'') +
				COALESCE(', ' + obtd.SERVICE_NAME_LEVEL_2,'')
			 END,
		1, 2, ''
	),
	obtd.NUM

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_NUMsToPotentialOrg_l] TO [cioc_login_role]
GO
