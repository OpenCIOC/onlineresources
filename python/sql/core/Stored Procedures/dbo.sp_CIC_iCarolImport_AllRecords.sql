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
	[UpdatedOn] [nvarchar](max)  COLLATE Latin1_General_100_CI_AI NULL
)

DECLARE @sql VARCHAR(MAX)
SET @sql = '
INSERT INTO #allrecords 
SELECT 
	ResourceAgencyNum, ParentAgencyNum, ConnectsToSiteNum, ConnectsToProgramNum, UniqueIDPriorSystem,  PublicName, TaxonomyLevelName, iCarolManaged, RecordOwner, UpdatedOn 
FROM OPENROWSET ( BULK ''' + @source_file + '''
	, CODEPAGE = ''RAW''
    , FORMAT = ''CSV''
    , DATA_SOURCE = ''s3_bulkimport''
	, FIRSTROW=1
) WITH (
	[ResourceAgencyNum] [NVARCHAR](50),
	[ParentAgencyNum] [NVARCHAR](MAX),
	[ConnectsToSiteNum] [nvarchar](max),
	[ConnectsToProgramNum] [nvarchar](max),
	[UniqueIDPriorSystem] [nvarchar](max),
	[PublicName] [nvarchar](max),
	[TaxonomyLevelName] [nvarchar](max),
	[iCarolManaged] [nvarchar](max),
	[RecordOwner] [nvarchar](max),
	[UpdatedOn] [nvarchar](max)
) as csvimport'
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

DECLARE @changes TABLE(
    op NVARCHAR(50) NOT NULL,
	tbl nvarchar(50) NOT NULL,
	ResourceAgencyNum nvarchar(20) NOT NULL,
	resurrected BIT NOT null,
	DELETION_DAY VARCHAR(10) NULL,
	DAY_IMPORTED VARCHAR(10) NULL
)

UPDATE ii SET ii.DELETION_DATE=CASE WHEN ar.ResourceAgencyNum IS NULL THEN GETDATE() ELSE NULL END, ii.SYNC_DATE=GETDATE()
	OUTPUT 'mark', 'base', inserted.ResourceAgencyNum, CASE WHEN inserted.deletion_date IS NULL THEN 1 ELSE 0 END, CONVERT(VARCHAR(10), COALESCE(inserted.DELETION_DATE, deleted.deletion_date), 23), NULL INTO @changes
FROM dbo.CIC_iCarolImport ii
LEFT JOIN dbo.CIC_iCarolImportAllRecords ar
	ON ii.ResourceAgencyNum=ar.ResourceAgencyNum AND ii.LangID=ar.LangID
WHERE ii.LangID=@@LANGID AND ((ar.ResourceAgencyNum IS NULL AND ii.DELETION_DATE IS NULL) OR (ar.ResourceAgencyNum IS NOT NULL AND ii.DELETION_DATE IS NOT NULL))

-- This will get picked up via rollup.
/*
UPDATE ir SET ir.DELETION_DATE=CASE WHEN ii.ResourceAgencyNum IS NULL THEN GETDATE() ELSE NULL END
	OUTPUT 'mark', 'rollup', inserted.ResourceAgencyNum, CASE WHEN inserted.deletion_date IS NULL THEN 1 ELSE 0 END, CONVERT(VARCHAR(10), COALESCE(inserted.DELETION_DATE, deleted.deletion_date), 23), CONVERT(VARCHAR(10), deleted.DATE_IMPORTED, 23) INTO @changes
FROM dbo.CIC_iCarolImportRollup ir
LEFT JOIN dbo.CIC_iCarolImport ii
	ON ii.ResourceAgencyNum=ir.ResourceAgencyNum AND ii.LangID=ir.LangID
WHERE ir.LangID=@@LANGID AND ((ii.ResourceAgencyNum IS NULL AND ir.DELETION_DATE IS NULL) OR (ii.ResourceAgencyNum IS NOT NULL AND ir.DELETION_DATE IS NOT NULL))
*/

DELETE ir
	OUTPUT 'purge', 'rollup', deleted.ResourceAgencyNum, 0, CONVERT(VARCHAR(10), deleted.deletion_date, 23), CONVERT(VARCHAR(10), deleted.DATE_IMPORTED, 23) INTO @changes
FROM dbo.CIC_iCarolImportRollup AS ir
-- We flagged a deltion and either created an import file with that deletion date or never created an import file ever
WHERE ir.LangiD=@@LANGID AND ir.DELETION_DATE IS NOT NULL AND (ir.DATE_IMPORTED IS NULL OR ir.DATE_IMPORTED > ir.DELETION_DATE)

DELETE ii 
	OUTPUT 'purge', 'base', deleted.ResourceAgencyNum, 0, CONVERT(VARCHAR(10), deleted.deletion_date, 23), NULL INTO @changes
FROM dbo.CIC_iCarolImport ii
LEFT JOIN dbo.CIC_iCarolImportRollup ir
	ON ii.ResourceAgencyNum=ir.ResourceAgencyNum AND ii.LangID=ir.LangID
-- Flagged for deletion and rollup condition is already cleared (see statement above)
WHERE ii.LangID=@@LANGID AND ii.DELETION_DATE IS NOT NULL AND ((ii.TaxonomyLevelName <> 'Program' AND ir.ResourceAgencyNum IS NULL) OR 
		(ii.TaxonomyLevelName = 'Program' AND NOT EXISTS(SELECT * FROM dbo.CIC_iCarolImportRollup ir2 WHERE ii.ResourceAgencyNum=ir2.ConnectsToProgramNum AND ir2.LangID=ii.LangID)))


;WITH Pregrouped AS (
	SELECT COUNT(*) AS num_records, op, tbl, resurrected, DELETION_DAY, DAY_IMPORTED
	FROM @changes
	GROUP BY  op, tbl, resurrected, DELETION_DAY, DAY_IMPORTED
)
SELECT SUM(num_records) AS num_records, op, tbl, resurrected,
	days_deleted=STUFF((SELECT ', ' + ISNULL(i.DELETION_DAY, 'NULL') AS [text()] FROM (SELECT DISTINCT xt.DELETION_DAY FROM Pregrouped xt WHERE xt.op=t.op AND xt.tbl=t.tbl AND xt.resurrected=t.resurrected) AS i ORDER BY i.DELETION_DAY FOR XML PATH('')), 1 , 2, ''),
	days_imported = STUFF((SELECT ', ' + ISNULL(i.DAY_IMPORTED, 'NULL') AS [text()] FROM (SELECT DISTINCT xt.DAY_IMPORTED FROM Pregrouped xt WHERE xt.op=t.op AND xt.tbl=t.tbl AND xt.resurrected=t.resurrected) AS i ORDER BY i.DAY_IMPORTED FOR XML PATH('')), 1 , 2, '')
FROM Pregrouped AS t
GROUP BY op, tbl, resurrected

;
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
