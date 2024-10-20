SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_TAX_U_SeeAlso_id]
	@source_file nvarchar(MAX) 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

IF OBJECT_ID('tempdb.dbo.#see_also', 'U') IS NOT NULL
  DROP TABLE #see_also; 

CREATE TABLE #see_also (
	[Code] [varchar](21) COLLATE Latin1_General_100_CI_AI NOT NULL,
	[SA_Code] [varchar](21) COLLATE Latin1_General_100_CI_AI NOT NULL
)

DECLARE @sql varchar(MAX)
SET @sql = '
INSERT INTO #see_also 
SELECT 
	Code, SA_Code
FROM OPENROWSET ( BULK ''' + @source_file + '''
	, CODEPAGE = ''RAW''
    , FORMAT = ''CSV''
    , DATA_SOURCE = ''s3_bulkimport''
	, FIRSTROW=1
) WITH (
	[Code] [varchar](21),
	[SA_Code] [varchar](21)
) as csvimport'
EXEC (@sql)

INSERT  INTO dbo.TAX_U_SeeAlso
(
	code,
	SA_Code,
	CREATED_DATE,
	MODIFIED_DATE,
	Authorized
)
SELECT code, SA_Code, GETDATE(), GETDATE(), 1
FROM #see_also c
WHERE NOT EXISTS(
	SELECT * 
	FROM dbo.TAX_U_SeeAlso o 
	WHERE o.code=c.code AND o.SA_Code = c.SA_Code
)

DELETE d FROM dbo.TAX_U_SeeAlso d
WHERE (EXISTS(SELECT * FROM #see_also c WHERE c.Code=d.Code)
AND NOT EXISTS(SELECT * FROM #see_also c WHERE c.Code=d.Code AND c.SA_Code=d.SA_Code))
OR NOT EXISTS(SELECT * FROM dbo.TAX_U_Term t WHERE d.Code=t.Code)

DROP TABLE #see_also

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_U_SeeAlso_id] TO [cioc_maintenance_role]
GO
