SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_1]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

/* Update existing Related Concepts with Code change */
UPDATE rc
	SET Code			= urc.Code,
		Authorized		= urc.Authorized,
		Source			= (SELECT TOP 1 TAX_SRC_ID FROM dbo.TAX_Source_Name WHERE SourceName IN ('211HSIS','INFO LINE')),
		MODIFIED_BY		= '(Import)',
		MODIFIED_DATE	= urc.MODIFIED_DATE
FROM dbo.TAX_RelatedConcept rc
INNER JOIN dbo.TAX_RelatedConcept_Name rcn
	ON rc.RC_ID=rcn.RC_ID AND rcn.LangID=0
INNER JOIN dbo.TAX_U_RelatedConcept urc
	ON rcn.ConceptName=urc.ConceptName_en
WHERE rc.Authorized=0

/* Insert new Related Concepts */
INSERT INTO dbo.TAX_RelatedConcept (CREATED_BY, Code, Authorized, Source, MODIFIED_BY)
SELECT	CREATED_BY = '(Import)',
		Code,
		Authorized,
		Source=(SELECT TOP 1 TAX_SRC_ID FROM dbo.TAX_Source_Name WHERE SourceName IN ('211HSIS','INFO LINE')),
		MODIFIED_BY='(Import)'
FROM dbo.TAX_U_RelatedConcept urc
WHERE NOT EXISTS(SELECT * FROM dbo.TAX_RelatedConcept WHERE Code=urc.Code)


/* Delete invalid Related Concepts */
DELETE rc
FROM dbo.TAX_RelatedConcept rc
WHERE Authorized=1
	AND NOT EXISTS(SELECT * FROM dbo.TAX_U_RelatedConcept urc WHERE rc.Code=urc.Code)

/* flag updated / new entries */
DECLARE @UpdatedCodes TABLE (
	RC_ID int NULL
)

/* Handle names changes -- rc.Code and urc.Code must be updated by this point */
MERGE INTO dbo.TAX_RelatedConcept_Name rcn
USING (SELECT rc.RC_ID, 0 AS LangID, urc.ConceptName_en AS ConceptName
		FROM dbo.TAX_RelatedConcept rc
		INNER JOIN dbo.TAX_U_RelatedConcept urc
			ON rc.Code=urc.Code
		WHERE urc.ConceptName_en IS NOT NULL
		UNION ALL
		SELECT rc.RC_ID, 2 AS LangID, urc.ConceptName_fr AS ConceptName
		FROM dbo.TAX_RelatedConcept rc
		INNER JOIN dbo.TAX_U_RelatedConcept urc
			ON rc.Code=urc.Code
		WHERE urc.ConceptName_fr IS NOT NULL) nt
	ON rcn.RC_ID=nt.RC_ID AND rcn.LangID=nt.RC_ID
WHEN MATCHED AND rcn.ConceptName<>nt.ConceptName THEN
	UPDATE SET ConceptName=nt.ConceptName
WHEN NOT MATCHED BY TARGET THEN
	INSERT (RC_ID, LangID, ConceptName) 
		VALUES (nt.RC_ID, nt.LangID, nt.ConceptName)
WHEN NOT MATCHED BY SOURCE AND EXISTS(SELECT * FROM dbo.TAX_RelatedConcept WHERE rcn.RC_ID=RC_ID AND Authorized=1) THEN
	DELETE
OUTPUT INSERTED.RC_ID INTO @UpdatedCodes
	;

UPDATE rc
	SET Authorized		= urc.Authorized,
		Source			= (SELECT TOP 1 TAX_SRC_ID FROM TAX_Source_Name WHERE SourceName IN ('211HSIS','INFO LINE')),
		MODIFIED_BY		= '(Import)',
		MODIFIED_DATE	= GETDATE()
FROM dbo.TAX_RelatedConcept rc
INNER JOIN dbo.TAX_U_RelatedConcept urc
	ON rc.Code=urc.Code
WHERE EXISTS(SELECT * FROM @UpdatedCodes WHERE rc.RC_ID=RC_ID)

SET NOCOUNT OFF

END



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_1] TO [cioc_login_role]
GO
