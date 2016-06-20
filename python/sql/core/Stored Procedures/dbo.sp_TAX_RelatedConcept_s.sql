SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_RelatedConcept_s]
	@RC_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 19-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT rc.*, 
		(SELECT TOP 1 CASE WHEN LangID=@@LANGID THEN ConceptName ELSE '[' + ConceptName + ']' END FROM TAX_RelatedConcept_Name WHERE RC_ID=rc.RC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS ConceptName,
		(SELECT COUNT(*) FROM TAX_TM_RC tr WHERE RC_ID=@RC_ID) AS UsageCount,
		(SELECT ConceptName AS [@ConceptName], l.Culture AS [@Culture]
			FROM TAX_RelatedConcept_Name rcn
			INNER JOIN STP_Language l
				ON rcn.LangID=l.LangID
		WHERE rcn.RC_ID=rc.RC_ID
		FOR XML PATH('DESC'),TYPE) AS Descriptions
	FROM TAX_RelatedConcept rc
WHERE RC_ID=@RC_ID

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_RelatedConcept_s] TO [cioc_login_role]
GO
