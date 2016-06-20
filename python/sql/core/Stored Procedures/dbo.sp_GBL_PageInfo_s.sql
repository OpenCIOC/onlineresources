SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PageInfo_s]
	@PageName varchar(255)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 02-Jan-2013
	Action: NO ACTION REQUIRED
*/

SELECT TOP 1
		ISNULL(ISNULL(pgn.TitleOverride,pgn.PageTitle), pg.PageName) AS PageTitle,
		CAST(CASE WHEN pgn.HelpFileName IS NOT NULL THEN 1 ELSE 0 END AS bit) AS HAS_HELP
	FROM GBL_PageInfo pg
	LEFT JOIN GBL_PageInfo_Description pgn
		ON pg.PageName=pgn.PageName AND pgn.LangID=(SELECT TOP 1 LangID FROM GBL_PageInfo_Description WHERE PageName=pg.PageName ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE @PageName LIKE pg.PageName + '%'
ORDER BY LEN(pg.PageName) DESC, pg.PageName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PageInfo_s] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_PageInfo_s] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_PageInfo_s] TO [cioc_vol_search_role]
GO
