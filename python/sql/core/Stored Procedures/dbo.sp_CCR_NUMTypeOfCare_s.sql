SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CCR_NUMTypeOfCare_s]
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 23-Dec-2011
	Action: NO ACTION REQUIRED
*/

SELECT toc.TOC_ID, tocn.LangID, CASE WHEN tocn.LangID=@@LANGID THEN tocn.Name ELSE '[' + tocn.Name + ']' END AS TypeOfCare, prn.Notes,
		CASE WHEN pr.NUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM CCR_TypeOfCare toc
	INNER JOIN CCR_TypeOfCare_Name tocn
		ON toc.TOC_ID=tocn.TOC_ID AND tocn.LangID=(SELECT TOP 1 LangID FROM CCR_TypeOfCare_Name WHERE TOC_ID=toc.TOC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN CCR_BT_TOC pr 
		ON toc.TOC_ID = pr.TOC_ID AND pr.NUM=@NUM
	LEFT JOIN CCR_BT_TOC_Notes prn
		ON pr.BT_TOC_ID=prn.BT_TOC_ID AND prn.LangID=@@LANGID
ORDER BY toc.DisplayOrder, tocn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CCR_NUMTypeOfCare_s] TO [cioc_login_role]
GO
