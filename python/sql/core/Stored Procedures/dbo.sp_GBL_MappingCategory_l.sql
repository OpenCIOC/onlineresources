SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_MappingCategory_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT mc.*, mcn.Name AS CategoryName
	FROM GBL_MappingCategory mc
	LEFT JOIN GBL_MappingCategory_Name mcn
		ON mc.MapCatID=mcn.MapCatID AND mcn.LangID=@@LANGID
	
ORDER BY MapCatID

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_MappingCategory_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_MappingCategory_l] TO [cioc_login_role]
GO
