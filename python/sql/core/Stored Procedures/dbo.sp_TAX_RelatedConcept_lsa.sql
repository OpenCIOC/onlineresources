SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_RelatedConcept_lsa]
	@Code [varchar](15)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 19-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT pr.TM_RC_ID, rc.RC_ID, rc.Code, pr.Authorized,
		CASE WHEN rcn.LangID=@@LANGID
			THEN rcn.ConceptName 
			ELSE '[' + rcn.ConceptName + ']'
		END AS ConceptName
	FROM TAX_RelatedConcept rc
	INNER JOIN TAX_RelatedConcept_Name rcn
		ON rc.RC_ID=rcn.RC_ID AND LangID=(SELECT TOP 1 LangID FROM TAX_RelatedConcept_Name WHERE rc.RC_ID=RC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN TAX_TM_RC pr
		ON pr.RC_ID = rc.RC_ID
WHERE     (pr.Code = @Code)
ORDER BY rcn.ConceptName

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_RelatedConcept_lsa] TO [cioc_login_role]
GO
