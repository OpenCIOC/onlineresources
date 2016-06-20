SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Activity_Status_l]
	@AllLanguages [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action:	NO ACTION REQUIRED
*/

SELECT astat.ASTAT_ID, CASE WHEN astatn.LangID=@@LANGID THEN astatn.Name ELSE '[' + astatn.Name + ']' END AS Status
	FROM CIC_Activity_Status astat
	INNER JOIN CIC_Activity_Status_Name astatn
		ON astat.ASTAT_ID=astatn.ASTAT_ID
			AND astatn.LangID=CASE
				WHEN @AllLanguages=0 THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM CIC_Activity_Status_Name WHERE ASTAT_ID=astat.ASTAT_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
ORDER BY astat.DisplayOrder, astatn.Name

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Activity_Status_l] TO [cioc_login_role]
GO
