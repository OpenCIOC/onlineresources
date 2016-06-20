SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_NAICS_Exclusion_lf]
	@Code [varchar](6)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action: NO ACTION REQUIRED
*/

SELECT TOP 1 Classification 
	FROM NAICS_Description
WHERE Code=@Code 
ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END

SELECT *, (SELECT UseCode [text()]
			FROM NAICS_Exclusion_Use nxu
			WHERE nxu.Exclusion_ID=nx.Exclusion_ID
			FOR XML PATH('Code'),ROOT('CODES'),TYPE ) AS UseCodes
	FROM NAICS_Exclusion nx
WHERE Code=@Code

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_NAICS_Exclusion_lf] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_NAICS_Exclusion_lf] TO [cioc_login_role]
GO
