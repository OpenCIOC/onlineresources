SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Facet_lf]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 14-May-2012
	Action: NO ACTION REQUIRED
*/

SELECT f.*,
		(SELECT COUNT(*) FROM TAX_Term tm WHERE tm.Facet=f.FC_ID) AS UsageCount,
		(SELECT fn.Facet AS [@Facet], Culture AS [@Culture]
			FROM TAX_Facet_Name fn
			INNER JOIN STP_Language l
				ON fn.LangID=l.LangID
		WHERE FC_ID=f.FC_ID
		FOR XML PATH('DESC'), TYPE) AS Descriptions
	FROM TAX_Facet f
ORDER BY (SELECT TOP 1 Facet FROM TAX_Facet_Name WHERE FC_ID=f.FC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Facet_lf] TO [cioc_login_role]
GO
