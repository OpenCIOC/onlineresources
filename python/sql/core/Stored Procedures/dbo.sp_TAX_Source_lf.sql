SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Source_lf]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 14-May-2012
	Action: NO ACTION REQUIRED
*/

SELECT ts.*, 
		(SELECT COUNT(*) FROM TAX_Term tm WHERE tm.Source=ts.TAX_SRC_ID) AS UsageCount,
		(SELECT SourceName AS [@SourceName], l.Culture AS [@Culture]
			FROM TAX_Source_Name tsn
			INNER JOIN STP_Language l
				ON tsn.LangID=l.LangID
		WHERE tsn.TAX_SRC_ID=ts.TAX_SRC_ID
		FOR XML PATH('DESC'), TYPE) AS Descriptions
	FROM TAX_Source ts
ORDER BY (SELECT TOP 1 SourceName FROM TAX_Source_Name WHERE ts.TAX_SRC_ID=TAX_SRC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Source_lf] TO [cioc_login_role]
GO
