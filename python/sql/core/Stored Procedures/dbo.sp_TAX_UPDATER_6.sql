SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_6]
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

DECLARE @SRC_ID int
SET @SRC_ID = (SELECT TOP 1 TAX_SRC_ID FROM TAX_Source_Name WHERE SourceName='INFO LINE')

/* Delete invalid Unused Terms */
DELETE ut
	FROM TAX_Unused ut
WHERE Authorized=1
	AND Term IS NOT NULL
	AND NOT EXISTS(
		SELECT * FROM tax_updater.dbo.UPDATER_Unused
		WHERE Code=ut.Code
			AND (
				(Term=ut.Term COLLATE Latin1_General_100_CI_AI AND ut.LangID=0)
				OR (TermEq=ut.Term COLLATE Latin1_General_100_CI_AI AND ut.LangID=2)
			)
	)

/* Insert new Unused Terms */
INSERT INTO TAX_Unused (
	CREATED_BY,
	MODIFIED_BY,
	Code,
	LangID,
	Term,
	Authorized,
	Active,
	Source
) SELECT 
	'(Import)',
	'(Import)',
	Code,
	LangID,
	Term,
	1,
	1,
	@SRC_ID
FROM (
	SELECT Code, 0 AS LangID, Term FROM tax_updater.dbo.UPDATER_Unused WHERE Term IS NOT NULL
	UNION SELECT Code, 2 AS LangID, TermEq AS Term FROM tax_updater.dbo.UPDATER_Unused WHERE TermEq IS NOT NULL
) uut
WHERE NOT EXISTS(SELECT * FROM TAX_Unused ut WHERE Code=ut.Code AND Term=uut.Term COLLATE Latin1_General_100_CI_AI AND LangID=uut.LangID)

/* Update Authorization status of Unused Terms */
UPDATE ut
	SET Authorized		= 1,
		MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= '(Import)'
FROM TAX_Unused ut
WHERE Authorized=0
AND EXISTS(SELECT * FROM tax_updater.dbo.UPDATER_Unused uut
	WHERE Code=ut.Code
	AND (Term=ut.Term COLLATE Latin1_General_100_CI_AI AND ut.LangID=0)
	AND (TermEq=ut.Term COLLATE Latin1_General_100_CI_AI AND ut.LangID=2)
)

SET NOCOUNT OFF

END



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_6] TO [cioc_login_role]
GO
