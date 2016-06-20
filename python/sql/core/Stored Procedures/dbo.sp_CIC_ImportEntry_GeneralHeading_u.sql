SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_GeneralHeading_u]
	@NUM varchar(8),
	@PB_ID int,
	@BT_PB_ID int,
	@GeneralHeadings xml,
	@NoMatchHeadings nvarchar(max) OUTPUT,
	@NoMatchTaxonomyHeadings nvarchar(max) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 15-Sep-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @HeadingsTable TABLE (
	GeneralHeading nvarchar(200),
	GH_ID int,
	Used bit,
	BT_PB_GH_ID int
)

INSERT INTO @HeadingsTable (GeneralHeading, GH_ID)
SELECT	CASE WHEN @@LANGID=0
			THEN COALESCE(N.value('@V','nvarchar(200)'),N.value('@VF','nvarchar(200)'))
			ELSE COALESCE(N.value('@V','nvarchar(200)'),N.value('@VF','nvarchar(200)'))
		END AS GeneralHeading,
		(SELECT TOP 1 gh.GH_ID
			FROM CIC_GeneralHeading gh
			WHERE gh.PB_ID=@PB_ID
				AND (
					EXISTS(SELECT * FROM CIC_GeneralHeading_Name ghn WHERE ghn.GH_ID=gh.GH_ID AND (Name=N.value('@V','nvarchar(200)') OR Name=N.value('@VF','nvarchar(200)')))
					OR (gh.TaxonomyName=1 AND (dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID,0)=N.value('@V','nvarchar(200)') OR dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID,2)=N.value('@VF','nvarchar(200)')))
				)
			ORDER BY CASE
				WHEN (gh.TaxonomyName=1 AND (dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID,0)=N.value('@V','nvarchar(200)') OR dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID,2)=N.value('@VF','nvarchar(200)'))) THEN 1
				WHEN EXISTS(SELECT * FROM CIC_GeneralHeading_Name ghn WHERE ghn.GH_ID=gh.GH_ID AND ghn.LangID=0 AND Name=N.value('@V','nvarchar(200)')) THEN 1
				WHEN EXISTS(SELECT * FROM CIC_GeneralHeading_Name ghn WHERE ghn.GH_ID=gh.GH_ID AND ghn.LangID=2 AND Name=N.value('@VF','nvarchar(200)')) THEN 2
				ELSE 3
			END
		) AS GH_ID
	FROM @GeneralHeadings.nodes('//HEADINGS/HD') AS T(N)
	
DELETE FROM @HeadingsTable WHERE GeneralHeading IS NULL

UPDATE h SET
	BT_PB_GH_ID = pr.BT_PB_GH_ID,
	Used = gh.Used
FROM @HeadingsTable h
INNER JOIN CIC_GeneralHeading gh
	ON h.GH_ID=gh.GH_ID
LEFT JOIN CIC_BT_PB_GH pr
	ON h.GH_ID=pr.GH_ID AND pr.BT_PB_ID=@BT_PB_ID

SET @NoMatchHeadings = NULL
SET @NoMatchTaxonomyHeadings = NULL

SELECT @NoMatchHeadings = COALESCE(@NoMatchHeadings + ', ','') + GeneralHeading
	FROM @HeadingsTable h
WHERE h.GH_ID IS NULL

SELECT @NoMatchTaxonomyHeadings = COALESCE(@NoMatchTaxonomyHeadings + ', ','') + GeneralHeading
	FROM @HeadingsTable h
WHERE h.GH_ID IS NOT NULL AND h.BT_PB_GH_ID IS NULL AND h.Used IS NULL

DELETE FROM @HeadingsTable WHERE GH_ID IS NULL OR Used IS NULL

MERGE INTO CIC_BT_PB_GH pr
USING @HeadingsTable h
	ON h.BT_PB_GH_ID=pr.BT_PB_GH_ID
WHEN NOT MATCHED BY TARGET THEN
	INSERT (BT_PB_ID, GH_ID, NUM_Cache) VALUES (@BT_PB_ID, h.GH_ID, @NUM)
WHEN NOT MATCHED BY SOURCE AND pr.BT_PB_ID=@BT_PB_ID
		AND NOT EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE gh.GH_ID=pr.GH_ID AND gh.Used IS NULL) THEN
	DELETE
	;
	
IF @@ROWCOUNT > 0 BEGIN
	UPDATE CIC_BT_PB SET
		MODIFIED_DATE = GETDATE(),
		MODIFIED_BY = '(Import)'
	WHERE BT_PB_ID=@BT_PB_ID
END

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_GeneralHeading_u] TO [cioc_login_role]
GO
