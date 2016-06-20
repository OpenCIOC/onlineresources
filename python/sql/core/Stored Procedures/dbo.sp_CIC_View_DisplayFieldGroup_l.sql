SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_DisplayFieldGroup_l]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 13-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT fg.DisplayFieldGroupID, fgn.Name AS DisplayFieldGroupName
	FROM CIC_View_DisplayFieldGroup fg
	INNER JOIN CIC_View_DisplayFieldGroup_Name fgn
		ON fg.DisplayFieldGroupID=fgn.DisplayFieldGroupID
			AND fgn.LangID=(SELECT TOP 1 LangID FROM CIC_View_DisplayFieldGroup_Name WHERE DisplayFieldGroupID=fgn.DisplayFieldGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE ViewType=@ViewType
ORDER BY fg.DisplayOrder, fgn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_DisplayFieldGroup_l] TO [cioc_login_role]
GO
