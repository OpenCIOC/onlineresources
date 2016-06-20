SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_Info]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 15-Oct-2012
	Action: NO ACTION REQUIRED
*/

SELECT *
	FROM tax_updater.dbo.METAData

SELECT (SELECT ReleaseNotes FROM tax_updater.dbo.OtherData) AS ReleaseNotes, CASE WHEN
		EXISTS(SELECT * FROM TAX_Term tm INNER JOIN TAX_Term_Description tmd ON tm.Code=tmd.Code
		WHERE tm.Authorized=1 AND NOT EXISTS(SELECT * FROM tax_updater.dbo.UPDATER_Term utm
			WHERE utm.Code=tm.Code AND ((utm.Term=tmd.Term AND tmd.LangID=0) OR (utm.TermEq=tmd.Term AND tmd.LangID=2)))
		)
		OR EXISTS(SELECT * FROM tax_updater.dbo.UPDATER_Term utm
		WHERE NOT EXISTS(SELECT * FROM TAX_Term tm INNER JOIN TAX_Term_Description tmd ON tm.Code=tmd.Code
			WHERE utm.Code=tm.Code AND ((utm.Term=tmd.Term AND tmd.LangID=0) OR (utm.TermEq=tmd.Term AND tmd.LangID=2)))
		)
		OR EXISTS(SELECT * FROM TAX_RelatedConcept rc INNER JOIN TAX_RelatedConcept_Name rcn ON rc.RC_ID=rcn.RC_ID
		WHERE rc.Authorized=1 AND NOT EXISTS(SELECT * FROM tax_updater.dbo.UPDATER_RelatedConcept urc
			WHERE urc.Code=rc.Code AND ((urc.ConceptName=rcn.ConceptName AND rcn.LangID=0) OR (urc.ConceptNameEq=rcn.ConceptName AND rcn.LangID=2)))
		)
		OR EXISTS(SELECT * FROM tax_updater.dbo.UPDATER_RelatedConcept urc
		WHERE NOT EXISTS(SELECT * FROM TAX_RelatedConcept rc INNER JOIN TAX_RelatedConcept_Name rcn ON rc.RC_ID=rcn.RC_ID
			WHERE urc.Code=rc.Code AND ((urc.ConceptName=rcn.ConceptName AND rcn.LangID=0) OR (urc.ConceptNameEq=rcn.ConceptName AND rcn.LangID=2)))
		)
		THEN 1 ELSE 0 END AS NOT_UP_TO_DATE

SET NOCOUNT OFF

END



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_Info] TO [cioc_login_role]
GO
