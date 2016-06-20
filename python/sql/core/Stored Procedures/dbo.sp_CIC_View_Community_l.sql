SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_Community_l]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT cm.CM_ID, ISNULL(cmn.Display,cmn.Name) AS Community
	FROM CIC_View_Community cs
	INNER JOIN GBL_Community cm
		ON cs.CM_ID = cm.CM_ID
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE ViewType = @ViewType
ORDER BY cs.DisplayOrder, cmn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_Community_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_View_Community_l] TO [cioc_login_role]
GO
