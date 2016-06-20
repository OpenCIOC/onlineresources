SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CCR_NUMToSchoolsInArea_rst](
	@NUM varchar(8),
	@LangID smallint
)
RETURNS @SchoolName TABLE (
	[SCH_ID] int NULL,
	[SchoolName] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL,
	[Notes] nvarchar(255) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 30-Sep-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @SchoolName
SELECT sch.SCH_ID,
		schn.Name + CASE WHEN sch.SchoolBoard IS NULL THEN '' ELSE ' (' + sch.SchoolBoard + ')' END,
		prn.InAreaNotes
	FROM CCR_BT_SCH pr
	LEFT JOIN CCR_BT_SCH_Notes prn
		ON pr.BT_SCH_ID=prn.BT_SCH_ID AND prn.LangID=@LangID
	INNER JOIN CCR_School sch
		ON pr.SCH_ID = sch.SCH_ID
	INNER JOIN CCR_School_Name schn
		ON sch.SCH_ID=schn.SCH_ID AND schn.LangID=(SELECT TOP 1 LangID FROM CCR_School_Name WHERE SCH_ID=sch.SCH_ID ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
WHERE NUM = @NUM
	AND pr.InArea=1
ORDER BY schn.Name

RETURN

END
GO
