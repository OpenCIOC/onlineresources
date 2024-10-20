SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_Info]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

SELECT Country, Language, ReleaseDate
	FROM dbo.TAX_U_MetaData

SELECT NULL AS ReleaseNotes, CASE WHEN
		EXISTS(SELECT * FROM dbo.TAX_Term tm INNER JOIN dbo.TAX_Term_Description tmd ON tm.Code=tmd.Code
		WHERE tm.Authorized=1 AND NOT EXISTS(SELECT * FROM dbo.TAX_U_Term utm
			WHERE utm.Code=tm.Code AND ((utm.Term_en=tmd.Term AND tmd.LangID=0) OR (utm.Term_fr=tmd.Term AND tmd.LangID=2)))
		)
		OR EXISTS(SELECT * FROM dbo.TAX_U_Term utm
		WHERE NOT EXISTS(SELECT * FROM dbo.TAX_Term tm INNER JOIN dbo.TAX_Term_Description tmd ON tm.Code=tmd.Code
			WHERE utm.Code=tm.Code AND ((utm.Term_en=tmd.Term AND tmd.LangID=0) OR (utm.Term_fr=tmd.Term AND tmd.LangID=2)))
		)
		OR EXISTS(SELECT * FROM dbo.TAX_RelatedConcept rc INNER JOIN dbo.TAX_RelatedConcept_Name rcn ON rc.RC_ID=rcn.RC_ID
		WHERE rc.Authorized=1 AND NOT EXISTS(SELECT * FROM dbo.TAX_U_RelatedConcept urc
			WHERE urc.Code=rc.Code AND ((urc.ConceptName_en=rcn.ConceptName AND rcn.LangID=0) OR (urc.ConceptName_fr=rcn.ConceptName AND rcn.LangID=2)))
		)
		OR EXISTS(SELECT * FROM dbo.TAX_U_RelatedConcept urc
		WHERE NOT EXISTS(SELECT * FROM dbo.TAX_RelatedConcept rc INNER JOIN dbo.TAX_RelatedConcept_Name rcn ON rc.RC_ID=rcn.RC_ID
			WHERE urc.Code=rc.Code AND ((urc.ConceptName_en=rcn.ConceptName AND rcn.LangID=0) OR (urc.ConceptName_fr=rcn.ConceptName AND rcn.LangID=2)))
		)
		THEN 1 ELSE 0 END AS NOT_UP_TO_DATE

SET NOCOUNT OFF

END



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_Info] TO [cioc_login_role]
GO
