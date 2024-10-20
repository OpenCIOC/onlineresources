SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_TAX_U_RelatedConcept_iu]
	@source_file nvarchar(MAX) 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

IF OBJECT_ID('tempdb.dbo.#relate_concept', 'U') IS NOT NULL
  DROP TABLE #relate_concept; 

CREATE TABLE #relate_concept (
	[Code] [varchar](6) COLLATE Latin1_General_100_CI_AI NOT NULL PRIMARY KEY,
	[ConceptName_en] [nvarchar](255) COLLATE Latin1_General_100_CI_AI  NULL,
	[ConceptName_fr] [nvarchar](255) COLLATE Latin1_General_100_CI_AI NULL
)

DECLARE @sql varchar(MAX)
SET @sql = '
INSERT INTO #relate_concept 
SELECT 
	Code, ConceptName_en, ConceptName_fr
FROM OPENROWSET ( BULK ''' + @source_file + '''
	, CODEPAGE = ''RAW''
    , FORMAT = ''CSV''
    , DATA_SOURCE = ''s3_bulkimport''
	, FIRSTROW=1
) WITH (
	[Code] [varchar](6),
	[ConceptName_en] [nvarchar](255),
	[ConceptName_fr] [nvarchar](255)
) as csvimport'
EXEC (@sql)

UPDATE r SET
	r.ConceptName_en=c.ConceptName_en,
	r.ConceptName_fr=c.ConceptName_fr,
	r.MODIFIED_DATE=GETDATE(),
	r.Source=(SELECT TOP(1) TAX_SRC_ID FROM dbo.TAX_U_Source WHERE SourceName_en='211HSIS'),
	r.Authorized=1
FROM dbo.TAX_U_RelatedConcept r
INNER JOIN #relate_concept c
	ON r.Code=c.Code
WHERE r.ConceptName_fr IS DISTINCT FROM c.ConceptName_fr OR r.ConceptName_en IS DISTINCT FROM c.ConceptName_en

INSERT  INTO dbo.TAX_U_RelatedConcept
(
	Code,
	ConceptName_en,
	ConceptName_fr,
	Source,
	Authorized
)
SELECT Code, ConceptName_en, ConceptName_fr, (SELECT TOP(1) TAX_SRC_ID FROM dbo.TAX_U_Source WHERE SourceName_en='211HSIS'), 1
FROM #relate_concept c
WHERE NOT EXISTS(
	SELECT * 
	FROM dbo.TAX_U_RelatedConcept o 
	WHERE o.code=c.code
)

DROP TABLE #relate_concept

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_U_RelatedConcept_iu] TO [cioc_maintenance_role]
GO
