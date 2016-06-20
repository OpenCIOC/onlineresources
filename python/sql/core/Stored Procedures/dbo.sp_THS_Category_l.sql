SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_THS_Category_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action: NO ACTION REQUIRED
*/

SELECT c.SubjCat_ID, cn.Category
	FROM THS_Category c
	INNER JOIN THS_Category_Name cn
		ON c.SubjCat_ID=cn.SubjCat_ID AND LangID=(SELECT TOP 1 LangID FROM THS_Category_Name WHERE SubjCat_ID=cn.SubjCat_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
ORDER BY Category

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_THS_Category_l] TO [cioc_login_role]
GO
