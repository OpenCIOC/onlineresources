SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_TAX_U_Term_d]
	@source_file nvarchar(MAX) 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

IF OBJECT_ID('tempdb.dbo.#terms_to_del', 'U') IS NOT NULL
  DROP TABLE #terms_to_del; 

CREATE TABLE #terms_to_del (
	[Code] [varchar](21) COLLATE Latin1_General_100_CI_AI  NOT NULL PRIMARY KEY,
	[Garbage] varchar(1) NULL
)

DECLARE @sql varchar(MAX)
SET @sql = '
INSERT INTO #terms_to_del 
SELECT 
	Code, Garbage 
FROM OPENROWSET ( BULK ''' + @source_file + '''
	, CODEPAGE = ''RAW''
    , FORMAT = ''CSV''
    , DATA_SOURCE = ''s3_bulkimport''
	, FIRSTROW=1
) WITH (
	[Code] [VARCHAR](21) COLLATE Latin1_General_100_CI_AI,
	Garbage varchar(1)
) as csvimport'
EXEC (@sql)

DELETE t
FROM dbo.TAX_U_SeeAlso t
WHERE t.SA_Code IN (SELECT Code FROM #terms_to_del d)

DELETE t
FROM dbo.TAX_U_Term t
WHERE t.Code IN (SELECT Code FROM #terms_to_del d)

DROP TABLE #terms_to_del

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_U_Term_d] TO [cioc_maintenance_role]
GO
