SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_MappingSystem_l]
	@AllLanguages [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT map.MAP_ID, CASE WHEN mapn.LangID=@@LANGID THEN mapn.Name ELSE '[' + mapn.Name + ']' END AS MappingSystemName
	FROM GBL_MappingSystem map
	INNER JOIN GBL_MappingSystem_Name mapn
		ON map.MAP_ID=mapn.MAP_ID
			AND mapn.LangID=CASE
				WHEN @AllLanguages=0 THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM GBL_MappingSystem_Name WHERE MAP_ID=map.MAP_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
ORDER BY mapn.Label

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_MappingSystem_l] TO [cioc_login_role]
GO
