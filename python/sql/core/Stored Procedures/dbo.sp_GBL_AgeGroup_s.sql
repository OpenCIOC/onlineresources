SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_AgeGroup_s]
	@AgeGroup_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT ag.MinAge, ag.MaxAge, agn.Name AS AgeGroupName
	FROM GBL_AgeGroup ag
	INNER JOIN GBL_AgeGroup_Name agn
		ON ag.AgeGroup_ID=agn.AgeGroup_ID AND agn.LangID = (SELECT TOP 1 LangID FROM GBL_AgeGroup_Name WHERE AgeGroup_ID=ag.AgeGroup_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE ag.AgeGroup_ID=@AgeGroup_ID

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_AgeGroup_s] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_AgeGroup_s] TO [cioc_login_role]
GO
