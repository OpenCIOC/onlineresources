SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_StreetDir_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/


SELECT sd.Dir, ISNULL(sdn.Name,sd.Dir) AS DirName
	FROM GBL_StreetDir sd
	LEFT JOIN GBL_StreetDir_Name sdn
		ON sd.Dir=sdn.Dir AND sdn.LangID=@@LANGID
ORDER BY Dir

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetDir_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetDir_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetDir_l] TO [cioc_vol_search_role]
GO
