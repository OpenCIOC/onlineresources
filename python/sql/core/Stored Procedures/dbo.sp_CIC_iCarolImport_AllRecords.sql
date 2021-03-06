SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_iCarolImport_AllRecords]
	@source_file NVARCHAR(MAX) 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		INT
SET @Error = 0

IF OBJECT_ID('tempdb.dbo.#allrecords', 'U') IS NOT NULL
  DROP TABLE #allrecords; 

CREATE TABLE #allrecords (
	[ResourceAgencyNum] [NVARCHAR](50) COLLATE Latin1_General_100_CI_AI  NOT NULL PRIMARY KEY,
	[ParentAgencyNum] [NVARCHAR](MAX)  COLLATE Latin1_General_100_CI_AI NULL,
	[ConnectsToSiteNum] [nvarchar](max)  COLLATE Latin1_General_100_CI_AI NULL,
	[ConnectsToProgramNum] [nvarchar](max)  COLLATE Latin1_General_100_CI_AI NULL,
	[UniqueIDPriorSystem] [nvarchar](max)  COLLATE Latin1_General_100_CI_AI NULL,
	[PublicName] [nvarchar](max)  COLLATE Latin1_General_100_CI_AI NULL,
	[TaxonomyLevelName] [nvarchar](max)  COLLATE Latin1_General_100_CI_AI NULL,
	[iCarolManaged] [nvarchar](max)  COLLATE Latin1_General_100_CI_AI NULL,
	[RecordOwner] [nvarchar](max)  COLLATE Latin1_General_100_CI_AI NULL,
	[UpdatedOn] [nvarchar](max)  COLLATE Latin1_General_100_CI_AI NULL,
)

DECLARE @sql VARCHAR(MAX)
SET @sql = 'BULK INSERT #allrecords FROM ''' + @source_file + '''WITH (CODEPAGE=''65001'',DATAFILETYPE=''Char'',  FIELDTERMINATOR=''' + CHAR(3) + ''', ROWTERMINATOR=''' + CHAR(4) + ''', FIRSTROW=1)'
EXEC (@sql)

MERGE INTO dbo.CIC_iCarolImportAllRecords dst
USING #allrecords AS src
ON dst.ResourceAgencyNum=src.ResourceAgencyNum AND dst.LangID=@@LANGID
WHEN MATCHED THEN
	UPDATE SET 
		[ParentAgencyNum]=src.[ParentAgencyNum],
		[ConnectsToSiteNum]=src.[ConnectsToSiteNum],
		[ConnectsToProgramNum]=src.[ConnectsToProgramNum],
		[UniqueIDPriorSystem]=src.[UniqueIDPriorSystem],
		[PublicName]=src.[PublicName],
		[TaxonomyLevelName]=src.[TaxonomyLevelName],
		[dst].[iCarolManaged]=src.[iCarolManaged],
		[RecordOwner]=src.[RecordOwner],
		[UpdatedOn]=src.[UpdatedOn]

WHEN NOT MATCHED BY TARGET THEN
	INSERT (
		[ResourceAgencyNum],
		[LangID],
		[PublicName],
		[TaxonomyLevelName],
		[ParentAgencyNum],
		[RecordOwner],
		[UniqueIDPriorSystem],
		[UpdatedOn],
		[ConnectsToSiteNum],
		[ConnectsToProgramNum],
		[iCarolManaged]
	) VALUES (
		src.[ResourceAgencyNum],
		@@LANGID,
		src.[PublicName],
		src.[TaxonomyLevelName],
		src.[ParentAgencyNum],
		src.[RecordOwner],
		src.[UniqueIDPriorSystem],
		src.[UpdatedOn],
		src.[ConnectsToSiteNum],
		src.[ConnectsToProgramNum],
		src.[iCarolManaged]
	)
WHEN NOT MATCHED BY SOURCE AND dst.LangID=@@LANGID THEN
	DELETE

	;

UPDATE ii SET ii.DELETION_DATE=GETDATE()
FROM dbo.CIC_iCarolImport ii
LEFT JOIN dbo.CIC_iCarolImportAllRecords ar
	ON ii.ResourceAgencyNum=ar.ResourceAgencyNum AND ii.LangID=ar.LangID
WHERE ar.ResourceAgencyNum IS NULL AND ii.LANGID=@@LANGID AND ii.DELETION_DATE IS NULL

UPDATE ir SET ir.DELETION_DATE=GETDATE()
FROM dbo.CIC_iCarolImportRollup ir
LEFT JOIN dbo.CIC_iCarolImport ii
	ON ii.ResourceAgencyNum=ir.ResourceAgencyNum AND ii.LangID=ir.LangID
WHERE ii.ResourceAgencyNum IS NULL

DELETE ir FROM dbo.CIC_iCarolImportRollup AS ir
-- We flagged a deltion and either created an import file with that deletion date or never created an import file ever
WHERE ir.DELETION_DATE IS NOT NULL AND (ir.DATE_IMPORTED IS NULL OR ir.DATE_IMPORTED > ir.DELETION_DATE)

DELETE ii 
FROM dbo.CIC_iCarolImport ii
LEFT JOIN dbo.CIC_iCarolImportRollup ir
	ON ii.ResourceAgencyNum=ir.ResourceAgencyNum AND ii.LangID=ir.LangID
-- Flagged for deletion and rollup condition is already cleared (see statement above)
WHERE ii.DELETION_DATE IS NOT NULL AND ir.ResourceAgencyNum IS NULL

SELECT a.*
FROM dbo.CIC_iCarolImportAllRecords a 
LEFT JOIN dbo.CIC_iCarolImport i
	ON i.ResourceAgencyNum=a.ResourceAgencyNum AND i.LangID=a.LangID
WHERE a.LANGID=@@LANGID AND (i.ResourceAgencyNum IS NULL OR a.UpdatedOn <> i.UpdatedOn OR (a.UpdatedOn IS NULL AND i.UpdatedOn IS NOT NULL) OR (a.UpdatedOn IS NOT NULL AND i.UpdatedOn IS NULL))


RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_iCarolImport_AllRecords] TO [cioc_maintenance_role]
GO
