SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_PageInfo_s_Help]
	@PageName varchar(255)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 27-Mar-2013
	Action: NO ACTION REQUIRED
*/

SELECT TOP 1
		ISNULL(ISNULL(pgn.TitleOverride,pgn.PageTitle), pg.PageName) AS PageTitle,
		pgh.HelpFileName,
		pgh.LangID,
		pgh.HelpFileRelease
	FROM GBL_PageInfo pg
	LEFT JOIN GBL_PageInfo_Description pgn
		ON pg.PageName=pgn.PageName AND pgn.LangID=(SELECT TOP 1 LangID FROM GBL_PageInfo_Description WHERE PageName=pg.PageName ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_PageInfo_Description pgh
		ON pg.PageName=pgh.PageName AND pgh.LangID=(SELECT TOP 1 LangID FROM GBL_PageInfo_Description WHERE PageName=pg.PageName AND HelpFileName IS NOT NULL ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE @PageName LIKE pg.PageName + '%'
ORDER BY LEN(pg.PageName) DESC, pg.PageName

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PageInfo_s_Help] TO [cioc_login_role]
GO
