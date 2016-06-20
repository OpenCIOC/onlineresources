SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_GeneralHeading_s_Entryform]
	@PB_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 09-Oct-2012
	Action: NO ACTION REQUIRED
*/

SELECT 
	(SELECT
		gh.GH_ID AS '@ID',
		CASE WHEN ghn.LangID=@@LANGID THEN ghn.Name ELSE '[' + ghn.Name + ']' END AS '@Name',
		ghgn.Name AS '@Group',
		CAST(0 AS bit) AS '@Selected'
	FROM CIC_GeneralHeading gh
	INNER JOIN CIC_GeneralHeading_Name ghn
		ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN CIC_GeneralHeading_Group ghg
		ON gh.HeadingGroup=ghg.GroupID
	LEFT JOIN CIC_GeneralHeading_Group_Name ghgn
		ON ghg.GroupID=ghgn.GroupID
			AND ghgn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Group_Name WHERE GroupID=ghg.GroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE gh.PB_ID=@PB_ID AND gh.Used=1
	ORDER BY ISNULL(ghg.DisplayOrder,255), ghgn.Name, gh.DisplayOrder, ghn.Name
FOR XML PATH('GH'),ROOT('HEADINGS'), TYPE) AS HEADINGS

SET NOCOUNT OFF






GO
GRANT EXECUTE ON  [dbo].[sp_CIC_GeneralHeading_s_Entryform] TO [cioc_login_role]
GO
