SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_TAX_U_Unused_id]
	@source_file nvarchar(MAX) 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

IF OBJECT_ID('tempdb.dbo.#use_ref', 'U') IS NOT NULL
  DROP TABLE #use_ref; 

CREATE TABLE #use_ref (
	[Code] [varchar](21) COLLATE Latin1_General_100_CI_AI NOT NULL,
	[Term_en] [nvarchar](255) COLLATE Latin1_General_100_CI_AI NULL,
	[Term_fr] [nvarchar](255) COLLATE Latin1_General_100_CI_AI NULL
)

DECLARE @sql varchar(MAX)
SET @sql = '
INSERT INTO #use_ref 
SELECT 
	Code, Term_en, Term_fr
FROM OPENROWSET ( BULK ''' + @source_file + '''
	, CODEPAGE = ''RAW''
    , FORMAT = ''CSV''
    , DATA_SOURCE = ''s3_bulkimport''
	, FIRSTROW=1
) WITH (
	[Code] [varchar](21),
	[Term_en] [nvarchar](255),
	[Term_fr] [nvarchar](255)
) as csvimport'
EXEC (@sql)

INSERT  INTO dbo.TAX_U_Unused
(
	code,
	Term_en,
	Term_fr,
	Source,
	Authorized
)
SELECT code, Term_en, Term_fr, (SELECT TOP(1) TAX_SRC_ID FROM dbo.TAX_U_Source WHERE SourceName_en='211HSIS'), 1
FROM #use_ref c
WHERE NOT EXISTS(
	SELECT * 
	FROM dbo.TAX_U_Unused o 
	WHERE o.code=c.code AND o.Term_en IS NOT DISTINCT FROM c.Term_en AND o.Term_fr IS NOT DISTINCT FROM c.Term_fr
)

DELETE c FROM dbo.TAX_U_Unused c
WHERE (EXISTS(
	SELECT *
	FROM #use_ref o
	WHERE o.code=c.code
) AND NOT EXISTS(
	SELECT *
	FROM #use_ref o
	WHERE o.code=c.code AND o.Term_en IS NOT DISTINCT FROM c.Term_en AND o.Term_fr IS NOT DISTINCT FROM c.Term_fr
)) OR NOT EXISTS(SELECT * FROM dbo.TAX_U_Term t WHERE t.Code=c.Code)

DROP TABLE #use_ref

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_U_Unused_id] TO [cioc_maintenance_role]
GO
