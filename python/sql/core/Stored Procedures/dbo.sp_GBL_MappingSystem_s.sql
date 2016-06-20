SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_MappingSystem_s]
	@MAP_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT map.*,
	(SELECT COUNT(*) FROM GBL_BT_MAP WHERE MAP_ID=map.MAP_ID) AS UsageCount
	FROM GBL_MappingSystem map
WHERE MAP_ID = @MAP_ID

SELECT mapn.*,
	(SELECT Culture FROM STP_Language WHERE LangID=mapn.LangID) AS Culture
FROM GBL_MappingSystem_Name mapn
WHERE MAP_ID=@MAP_ID

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_MappingSystem_s] TO [cioc_login_role]
GO
