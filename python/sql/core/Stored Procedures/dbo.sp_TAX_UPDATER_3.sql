
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_3]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Mar-2015
	Action: NO ACTION REQUIRED
*/

DECLARE @FacetMap TABLE(
	Src int,
	Dst int
)

DECLARE @SRC_ID int
SET @SRC_ID = (SELECT TOP 1 TAX_SRC_ID FROM TAX_Source_Name WHERE SourceName='INFO LINE')

IF @SRC_ID IS NULL BEGIN
	INSERT INTO dbo.TAX_Source
	        ( CREATED_DATE ,
	          CREATED_BY ,
	          MODIFIED_DATE ,
	          MODIFIED_BY
	        )
	VALUES  ( GETDATE(),
	          'CIOC HelpDesk',
	          GETDATE(),
	          'CIOC HelpDesk'
	        )
	SET @SRC_ID=SCOPE_IDENTITY()

	INSERT INTO dbo.TAX_Source_Name
	        ( TAX_SRC_ID, LangID, SourceName )
	VALUES  ( @SRC_ID,
	          0,
	          N'INFO LINE'
	          )
END

INSERT INTO @FacetMap
SELECT fcu.FC_ID, fcd.FC_ID
	FROM TAX_Facet_Name fcd
	INNER JOIN tax_updater.dbo.UPDATER_Facet fcu
		ON fcu.Facet=fcd.Facet AND fcd.LangID=0

/* Update existing Terms - everything but Term name */
UPDATE tm SET
	MODIFIED_DATE	= GETDATE(),
	MODIFIED_BY		= '(Import)',
	[Source]		= @SRC_ID,
	Facet			= (SELECT fc.Dst FROM @FacetMap fc WHERE utm.Facet=fc.Src)
FROM TAX_Term tm
INNER JOIN tax_updater.dbo.UPDATER_Term utm
	ON tm.Code=utm.Code AND tm.Authorized=1
WHERE (tm.Facet<>(SELECT fc.Dst FROM @FacetMap fc WHERE utm.Facet=fc.Src) OR (tm.Facet IS NULL AND utm.Facet IS NOT NULL) OR (tm.Facet IS NOT NULL AND utm.Facet IS NULL))
	OR tm.[Source]<>@SRC_ID
	
DECLARE @UpdatedCodes TABLE(
	Code varchar(21)
)

UPDATE tmd SET
	[Definition]	= utm.[Definition],
	Comments		= utm.Comments,
	BiblioRef		= utm.BiblioRef
OUTPUT tm.Code INTO @UpdatedCodes
FROM TAX_Term_Description tmd
INNER JOIN TAX_Term tm
	ON tmd.Code=tm.Code AND tm.Authorized=1
INNER JOIN (
		SELECT
				utme.Code,
				LangID=0,
				utme.[Definition],
				utme.Comments,
				utme.BiblioRef
		FROM tax_updater.dbo.UPDATER_Term utme
		UNION SELECT
				utmf.Code,
				LangID=2,
				utmf.DefinitionEq AS [Definition],
				utmf.CommentsEq AS [CommentsEq],
				utmf.BiblioRefEq AS [BiblioRef]
		FROM tax_updater.dbo.UPDATER_Term utmf
	) utm
	ON tmd.Code=utm.Code AND tmd.LangID=utm.LangID
WHERE (tmd.Definition<>utm.Definition OR (tmd.Definition IS NULL AND utm.Definition IS NOT NULL) OR (tmd.Definition IS NOT NULL AND utm.Definition IS NULL))
	OR (tmd.Comments<>utm.Comments OR (tmd.Comments IS NULL AND utm.Comments IS NOT NULL) OR (tmd.Comments IS NOT NULL AND utm.Comments IS NULL))
	OR (tmd.BiblioRef<>utm.BiblioRef OR (tmd.BiblioRef IS NULL AND utm.BiblioRef IS NOT NULL) OR (tmd.BiblioRef IS NOT NULL AND utm.BiblioRef IS NULL))

/* Update existing Terms - Term name only*/
UPDATE tmd SET
	Term			= utm.Term
OUTPUT tm.Code INTO @UpdatedCodes
FROM TAX_Term_Description tmd
INNER JOIN TAX_Term tm
	ON tmd.Code=tm.Code
INNER JOIN (
	SELECT Code, 0 AS LangID, Term FROM tax_updater.dbo.UPDATER_Term utme WHERE utme.Term IS NOT NULL
	UNION SELECT Code, 2 AS LangID, TermEq AS Term FROM tax_updater.dbo.UPDATER_Term utmf WHERE utmf.TermEq IS NOT NULL
	) utm
	ON tmd.Code=utm.Code AND tmd.LangID=utm.LangID AND tm.Authorized=1
WHERE (tmd.Term<>utm.Term OR (tmd.Term IS NULL AND utm.Term IS NOT NULL) OR (tmd.Term IS NOT NULL AND utm.Term IS NULL))

/* Update Modified Info */

UPDATE tm SET
	MODIFIED_DATE	= GETDATE(),
	MODIFIED_BY		= '(Import)'
FROM TAX_Term tm
WHERE EXISTS(SELECT * FROM @UpdatedCodes uc WHERE uc.Code=tm.Code)

/* Insert new Terms */
INSERT INTO TAX_Term (
	Code,
	CREATED_DATE,
	CREATED_BY,MODIFIED_BY,
	CdLvl1,CdLvl2,CdLvl3,CdLvl4,CdLvl5,CdLvl6,CdLocal,
	ParentCode,CdLvl,
	Authorized,
	Active,
	Source,
	Facet
)
SELECT
	Code,
	utm.CREATED_DATE,
	'(Import)','(Import)',
	CdLvl1,CdLvl2,CdLvl3,CdLvl4,CdLvl5,CdLvl6,CdLocal,
	ParentCode,CdLvl,
	Authorized,
	Active,
	@SRC_ID,
	(SELECT fc.Dst FROM @FacetMap fc WHERE utm.Facet=fc.Src)
FROM tax_updater.dbo.UPDATER_Term utm
WHERE NOT EXISTS(SELECT * FROM TAX_Term tm WHERE tm.Code=utm.Code)

INSERT INTO TAX_Term_Description (
	Code,
	LangID,
	Term,
	Definition,
	Comments,
	BiblioRef
)
SELECT
	Code,
	LangID,
	Term,
	Definition,
	Comments,
	BiblioRef
FROM (
		SELECT
				utme.Code,
				LangID=0,
				utme.Term,
				utme.[Definition],
				utme.Comments,
				utme.BiblioRef
		FROM tax_updater.dbo.UPDATER_Term utme
		UNION SELECT
				utmf.Code,
				LangID=2,
				utmf.Term,
				utmf.DefinitionEq AS [Definition],
				utmf.CommentsEq AS [CommentsEq],
				utmf.BiblioRefEq AS [BiblioRef]
		FROM tax_updater.dbo.UPDATER_Term utmf
	) utm
WHERE NOT EXISTS(SELECT * FROM TAX_Term_Description tmd WHERE tmd.Code=utm.Code AND tmd.LangID=utm.LangID)

SET NOCOUNT OFF

END



GO

GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_3] TO [cioc_login_role]
GO
