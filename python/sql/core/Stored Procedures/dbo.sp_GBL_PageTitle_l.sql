SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PageTitle_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT pg.PageName, ISNULL(pgn.TitleOverride,pgn.PageTitle) AS PageTitle
	FROM GBL_PageInfo pg
	INNER JOIN GBL_PageInfo_Description pgn
		ON pg.PageName=pgn.PageName AND pgn.LangID=(SELECT TOP 1 LangID FROM GBL_PageInfo_Description WHERE PageName=pg.PageName ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE pg.CanOverrideTitle = 1
ORDER BY pg.PageName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PageTitle_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_PageTitle_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_PageTitle_l] TO [cioc_vol_search_role]
GO
