SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_2]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 12-Oct-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @FacetMap TABLE(
	Src int,
	Dst int
)

INSERT INTO @FacetMap
SELECT fcu.FC_ID, fcd.FC_ID
	FROM TAX_Facet_Name fcd
	INNER JOIN tax_updater.dbo.UPDATER_Facet fcu
		ON fcu.Facet = fcd.Facet AND fcd.LangID = 0
	
DECLARE @NewFCIDs TABLE (
	New int NULL,
	Old int NULL,
	ACTN varchar(20)
)

MERGE INTO TAX_Facet fc
USING (SELECT Dst AS FC_ID, ufc.FC_ID AS Src, Facet, FacetEq
			FROM tax_updater.dbo.UPDATER_Facet ufc
			LEFT JOIN @FacetMap fm
				ON fm.Src=ufc.FC_ID) ufc
	ON fc.FC_ID=ufc.FC_ID AND ufc.FC_ID IS NOT NULL
WHEN MATCHED AND EXISTS(SELECT * FROM TAX_Facet_Name WHERE LangID=2 AND Facet<>ufc.FacetEq AND fc.FC_ID=FC_ID) THEN
	UPDATE SET
		MODIFIED_BY		= '(Import)',
		MODIFIED_DATE	= GETDATE()
WHEN NOT MATCHED BY TARGET THEN
	INSERT (CREATED_BY, MODIFIED_BY, CREATED_DATE, MODIFIED_DATE)
		VALUES ( '(Import)', '(Import)', GETDATE(), GETDATE() )
WHEN NOT MATCHED BY SOURCE THEN
	DELETE
OUTPUT INSERTED.FC_ID, ufc.Src, $action INTO @NewFCIDs
	;
	
INSERT INTO @FacetMap
SELECT DISTINCT Old, New 
	FROM @NewFCIDs
WHERE ACTN = 'INSERT' AND New IS NOT NULL AND Old IS NOT NULL
	AND NOT EXISTS(SELECT * FROM @FacetMap WHERE Old=Src)

MERGE INTO TAX_Facet_Name fcn
USING (SELECT Dst AS FC_ID,
		0 AS LangID, Facet
		FROM tax_updater.dbo.UPDATER_Facet ufc INNER JOIN @FacetMap fm
			ON fm.Src=ufc.FC_ID
		WHERE Facet IS NOT NULL
		UNION ALL 
		SELECT Dst AS FC_ID,
		2 AS LangID, FacetEq AS Facet
		FROM tax_updater.dbo.UPDATER_Facet ufc INNER JOIN @FacetMap fm
			ON fm.Src=ufc.FC_ID
		WHERE FacetEq IS NOT NULL) nt
	ON fcn.FC_ID=nt.FC_ID AND fcn.LangID=fcn.LangID
WHEN MATCHED AND fcn.Facet<>nt.Facet THEN
	UPDATE SET Facet = nt.Facet
WHEN NOT MATCHED BY TARGET THEN
	INSERT (FC_ID, LangID, Facet) 
		VALUES (nt.FC_ID, nt.LangID, nt.Facet)
WHEN NOT MATCHED BY SOURCE THEN
	DELETE
	;

SET NOCOUNT OFF

END



GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_2] TO [cioc_login_role]
GO
