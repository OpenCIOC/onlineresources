SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_2]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

DECLARE @FacetMap TABLE(
	Src int,
	Dst int
)

INSERT INTO @FacetMap
SELECT fcu.FC_ID, fcd.FC_ID
	FROM dbo.TAX_Facet_Name fcd
	INNER JOIN dbo.TAX_U_Facet fcu
		ON fcu.Facet_en=fcd.Facet AND fcd.LangID=0
	
DECLARE @NewFCIDs TABLE (
	New int NULL,
	Old int NULL,
	ACTN varchar(20)
)

MERGE INTO dbo.TAX_Facet fc
USING (SELECT Dst AS FC_ID, ufc.FC_ID AS Src, Facet_en, Facet_fr
			FROM dbo.TAX_U_Facet ufc
			LEFT JOIN @FacetMap fm
				ON fm.Src=ufc.FC_ID) ufc
	ON fc.FC_ID=ufc.FC_ID AND ufc.FC_ID IS NOT NULL
WHEN MATCHED AND EXISTS(SELECT * FROM dbo.TAX_Facet_Name WHERE LangID=2 AND Facet<>ufc.Facet_fr AND fc.FC_ID=FC_ID) THEN
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

MERGE INTO dbo.TAX_Facet_Name fcn
USING (SELECT Dst AS FC_ID,
		0 AS LangID, ufc.Facet_en AS Facet
		FROM dbo.TAX_U_Facet ufc INNER JOIN @FacetMap fm
			ON fm.Src=ufc.FC_ID
		WHERE ufc.Facet_en IS NOT NULL
		UNION ALL 
		SELECT Dst AS FC_ID,
		2 AS LangID, ufc.Facet_fr AS Facet
		FROM dbo.TAX_U_Facet ufc INNER JOIN @FacetMap fm
			ON fm.Src=ufc.FC_ID
		WHERE ufc.Facet_fr IS NOT NULL) nt
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
