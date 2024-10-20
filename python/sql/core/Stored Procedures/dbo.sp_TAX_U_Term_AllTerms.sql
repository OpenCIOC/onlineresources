SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_TAX_U_Term_AllTerms]
	@source_file nvarchar(MAX) 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		INT
SET @Error = 0

IF OBJECT_ID('tempdb.dbo.#allterms', 'U') IS NOT NULL
  DROP TABLE #allterms; 

CREATE TABLE #allterms (
	[Code] [VARCHAR](21) COLLATE Latin1_General_100_CI_AI  NOT NULL PRIMARY KEY,
	[CreatedDate] datetime NULL,
	[ModifiedDate] datetime NULL,
	[ParentCode] [varchar](16) COLLATE Latin1_General_100_CI_AI NULL
)

DECLARE @sql VARCHAR(MAX)
SET @sql = '
INSERT INTO #allterms 
SELECT 
	Code, CreatedDate, ModifiedDate, ParentCode 
FROM OPENROWSET ( BULK ''' + @source_file + '''
	, CODEPAGE = ''RAW''
    , FORMAT = ''CSV''
    , DATA_SOURCE = ''s3_bulkimport''
	, FIRSTROW=1
) WITH (
	[Code] [VARCHAR](21),
	[CreatedDate] datetime,
	[ModifiedDate] datetime,
	[ParentCode] [varchar](16)
) as csvimport'
EXEC (@sql)


SELECT ISNULL(tm.Code, atm.Code) AS Code, CASE WHEN atm.Code IS NULL THEN 1 ELSE 0 END AS ToDelete
FROM #allterms AS atm
FULL JOIN dbo.TAX_U_Term tm
	ON atm.Code=tm.Code
WHERE atm.Code IS NULL OR tm.Code IS NULL OR tm.MODIFIED_DATE<>atm.ModifiedDate

DROP TABLE #allterms

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_TAX_U_Term_AllTerms] TO [cioc_maintenance_role]
GO
