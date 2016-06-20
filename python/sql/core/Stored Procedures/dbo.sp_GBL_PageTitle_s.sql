SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PageTitle_s]
	@PageName [varchar](255)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT pg.*
	FROM GBL_PageInfo pg
WHERE @PageName = pg.PageName

SELECT pgn.*, l.Culture
	FROM GBL_PageInfo_Description pgn
	INNER JOIN STP_Language l
		ON pgn.LangID=l.LangID
WHERE @PageName = pgn.PageName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PageTitle_s] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_PageTitle_s] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_PageTitle_s] TO [cioc_vol_search_role]
GO
