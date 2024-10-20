SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_6]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

DECLARE @SRC_ID int
SET @SRC_ID = (SELECT TOP 1 TAX_SRC_ID FROM TAX_Source_Name WHERE SourceName IN ('211HSIS','INFO LINE'))

/* Delete invalid Unused Terms */
DELETE ut
	FROM dbo.TAX_Unused ut
WHERE Authorized=1
	AND Term IS NOT NULL
	AND NOT EXISTS(
		SELECT * FROM dbo.TAX_U_Unused
		WHERE Code=ut.Code
			AND (
				(Term_en=ut.Term COLLATE Latin1_General_100_CS_AS AND ut.LangID=0)
				OR (Term_fr=ut.Term COLLATE Latin1_General_100_CS_AS AND ut.LangID=2)
			)
	)

/* Insert new Unused Terms */
INSERT INTO dbo.TAX_Unused (
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
	SELECT Code, 0 AS LangID, Term_en AS Term FROM dbo.TAX_U_Unused WHERE Term_en IS NOT NULL
	UNION SELECT Code, 2 AS LangID, Term_fr AS Term FROM dbo.TAX_U_Unused WHERE Term_fr IS NOT NULL
) uut
WHERE NOT EXISTS(SELECT * FROM dbo.TAX_Unused ut WHERE Code=ut.Code AND Term=uut.Term COLLATE Latin1_General_100_CI_AI AND LangID=uut.LangID)

/* Update Authorization status of Unused Terms */
UPDATE ut
	SET Authorized		= 1,
		MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= '(Import)'
FROM dbo.TAX_Unused ut
WHERE Authorized=0
AND EXISTS(SELECT * FROM dbo.TAX_U_Unused uut
	WHERE Code=ut.Code
	AND (uut.Term_en=ut.Term COLLATE Latin1_General_100_CS_AS AND ut.LangID=0)
	AND (uut.Term_fr=ut.Term COLLATE Latin1_General_100_CS_AS AND ut.LangID=2)
)

SET NOCOUNT OFF

END



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_6] TO [cioc_login_role]
GO
