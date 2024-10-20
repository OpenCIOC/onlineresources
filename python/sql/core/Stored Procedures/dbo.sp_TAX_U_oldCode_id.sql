SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_TAX_U_oldCode_id]
	@source_file nvarchar(MAX) 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		INT
SET @Error = 0

IF OBJECT_ID('tempdb.dbo.#old_codes', 'U') IS NOT NULL
  DROP TABLE #old_codes; 

CREATE TABLE #old_codes (
	[Code] [varchar](21) COLLATE Latin1_General_100_CI_AI NOT NULL,
	[oldCode] [varchar](21) COLLATE Latin1_General_100_CI_AI NOT NULL

)

DECLARE @sql VARCHAR(MAX)
SET @sql = '
INSERT INTO #old_codes 
SELECT 
	Code, oldCode
FROM OPENROWSET ( BULK ''' + @source_file + '''
	, CODEPAGE = ''RAW''
    , FORMAT = ''CSV''
    , DATA_SOURCE = ''s3_bulkimport''
	, FIRSTROW=1
) WITH (
	[Code] [VARCHAR](21),
	[oldCode] [VARCHAR](21)
) as csvimport'
EXEC (@sql)

INSERT  INTO dbo.TAX_U_oldCode
(
	code,
	oldCode
)
SELECT code, oldCode 
FROM #old_codes c
WHERE NOT EXISTS(
	SELECT * 
	FROM dbo.TAX_U_oldCode o 
	WHERE o.code=c.code AND o.oldCode = c.oldCode
)

DELETE d FROM dbo.TAX_U_oldCode d
WHERE (EXISTS(SELECT * FROM #old_codes c WHERE c.Code=d.Code)
AND NOT EXISTS(SELECT * FROM #old_codes c WHERE c.Code=d.Code AND c.OldCode=d.oldCode))
OR NOT EXISTS(SELECT * FROM dbo.TAX_U_Term t WHERE d.Code=t.Code)

DROP TABLE #old_codes

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_U_oldCode_id] TO [cioc_maintenance_role]
GO
