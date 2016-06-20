SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_RelatedConcept_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 19-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT rc.RC_ID, Code, ConceptName
	FROM TAX_RelatedConcept rc
	INNER JOIN TAX_RelatedConcept_Name rcn
		ON rc.RC_ID=rcn.RC_ID AND LangID=@@LANGID
ORDER BY ConceptName

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_RelatedConcept_l] TO [cioc_login_role]
GO
