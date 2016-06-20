SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_RelatedConcept_la]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 19-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT rc.RC_ID, Code, CASE WHEN @@LANGID=rcn.LangID
			THEN ConceptName
			ELSE '[' + ConceptName + ']' 
		END AS ConceptName
	FROM TAX_RelatedConcept rc
	INNER JOIN TAX_RelatedConcept_Name rcn
		ON rc.RC_ID=rcn.RC_ID AND rcn.LangID=(SELECT TOP 1 LangID FROM TAX_RelatedConcept_Name WHERE rcn.RC_ID=RC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY rcn.ConceptName

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_RelatedConcept_la] TO [cioc_login_role]
GO
