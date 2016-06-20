SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UCheck_Concepts]
	@NewConcepts [varchar](max),
	@BadConcepts [varchar](max) OUTPUT,
	@NewIDs [varchar](max) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 19-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@rcpConcepts TABLE (ConceptName varchar(255))
DECLARE	@rcpGoodConcepts TABLE (ConceptName varchar(255))

/* Trim incoming data for all text-valued fields */
SET @NewConcepts = RTRIM(LTRIM(@NewConcepts))
IF @NewConcepts = '' SET @NewConcepts = NULL

/* If we have data to process... */
IF @NewConcepts IS NOT NULL BEGIN
	
	/* Create a table of Names/Codes to process */
	INSERT INTO @rcpConcepts SELECT * FROM dbo.fn_GBL_ParseVarCharIDList(@NewConcepts,';')
	SET @Error = @@ERROR

	IF @Error = 0 BEGIN
		/* Create a list of valid Concepts */
		SELECT @NewIDs = COALESCE(@NewIDs + ',','') + 
				CAST((SELECT TOP 1 rc.RC_ID 
						FROM TAX_RelatedConcept rc
						INNER JOIN TAX_RelatedConcept_Name rcn
							ON rc.RC_ID=rcn.RC_ID
						WHERE Code=tm.ConceptName COLLATE Latin1_General_100_CI_AI
							OR ConceptName=tm.ConceptName COLLATE Latin1_General_100_CI_AI
						ORDER BY CASE WHEN Code=tm.ConceptName COLLATE Latin1_General_100_CI_AI THEN 0 ELSE 1 END,
								CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS varchar)
			FROM @rcpConcepts tm 
			WHERE EXISTS(SELECT * FROM TAX_RelatedConcept_Name 
					WHERE ConceptName=tm.ConceptName COLLATE Latin1_General_100_CI_AI)
				OR EXISTS(SELECT * FROM TAX_RelatedConcept 
					WHERE Code=tm.ConceptName COLLATE Latin1_General_100_CI_AI)
		SET @Error = @@ERROR
	END
	IF @Error = 0 BEGIN
		/* Delete from the list of Concepts to process the ones we have identified as valid */
		DELETE tm
			FROM @rcpConcepts tm
			WHERE EXISTS(SELECT * FROM TAX_RelatedConcept_Name 
					WHERE ConceptName=tm.ConceptName COLLATE Latin1_General_100_CI_AI)
				OR EXISTS(SELECT * FROM TAX_RelatedConcept 
					WHERE Code=tm.ConceptName COLLATE Latin1_General_100_CI_AI)
		SET @Error = @@ERROR
	END
	IF @Error =0 BEGIN
		/* Any Concepts left in the list to process are not valid */
		SELECT @BadConcepts = COALESCE(@BadConcepts + ' ; ','') + tm.ConceptName
			FROM @rcpConcepts tm
		SET @Error = @@ERROR
	END
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UCheck_Concepts] TO [cioc_login_role]
GO
