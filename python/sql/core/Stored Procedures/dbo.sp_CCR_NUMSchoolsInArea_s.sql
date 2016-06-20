SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CCR_NUMSchoolsInArea_s]
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

SELECT	sch.SCH_ID, schn.Name AS SchoolName, sch.SchoolBoard, prn.InAreaNotes AS Notes
	FROM CCR_School sch
	INNER JOIN CCR_School_Name schn
		ON sch.SCH_ID=schn.SCH_ID AND schn.LangID=(SELECT TOP 1 LangID FROM CCR_School_Name WHERE SCH_ID=sch.SCH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN CCR_BT_SCH pr
		ON sch.SCH_ID=pr.SCH_ID AND pr.NUM=@NUM
	LEFT JOIN CCR_BT_SCH_Notes prn
		ON pr.BT_SCH_ID=prn.BT_SCH_ID AND prn.LangID=@@LANGID
WHERE pr.InArea=1
ORDER BY schn.Name, sch.SchoolBoard

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CCR_NUMSchoolsInArea_s] TO [cioc_login_role]
GO
