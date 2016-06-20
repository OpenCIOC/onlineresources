SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_NUMMappingSystem_s]
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT map.MAP_ID, CASE WHEN mapn.LangID=@@LANGID THEN mapn.Name ELSE '[' + mapn.Name + ']' END AS [Name],
		CASE WHEN pr.NUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM GBL_MappingSystem map
	INNER JOIN GBL_MappingSystem_Name mapn
		ON map.MAP_ID=mapn.MAP_ID
			AND LangID=(SELECT TOP 1 LangID FROM GBL_MappingSystem_Name WHERE MAP_ID=map.MAP_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN (SELECT NUM, MAP_ID FROM GBL_BT_MAP WHERE NUM = @NUM) pr
		ON map.MAP_ID = pr.MAP_ID
ORDER BY mapn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_NUMMappingSystem_s] TO [cioc_login_role]
GO
