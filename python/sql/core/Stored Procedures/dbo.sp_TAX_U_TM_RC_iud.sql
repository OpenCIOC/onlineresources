SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_TAX_U_TM_RC_iud]
	@source_file nvarchar(MAX) 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

IF OBJECT_ID('tempdb.dbo.#tm_rc', 'U') IS NOT NULL
  DROP TABLE #tm_rc; 

CREATE TABLE #tm_rc (
	[Code] [varchar](21) COLLATE Latin1_General_100_CI_AI NOT NULL,
	[RCCode] [varchar](6) COLLATE Latin1_General_100_CI_AI NOT NULL
)

DECLARE @sql varchar(MAX)
SET @sql = '
INSERT INTO #tm_rc 
SELECT 
	Code, RCCode
FROM OPENROWSET ( BULK ''' + @source_file + '''
	, CODEPAGE = ''RAW''
    , FORMAT = ''CSV''
    , DATA_SOURCE = ''s3_bulkimport''
	, FIRSTROW=1
) WITH (
	[Code] [varchar](21),
	[RCCode] [varchar](6)

) as csvimport'
EXEC (@sql)

INSERT  INTO dbo.TAX_U_TM_RC
(
	Code,
	RC_ID,
	Authorized
)
SELECT c.Code, rc.RC_ID, 1
FROM #tm_rc c
INNER JOIN dbo.TAX_U_RelatedConcept rc
	ON c.RCCode=rc.Code
WHERE NOT EXISTS(
	SELECT * 
	FROM dbo.TAX_U_TM_RC n
	WHERE n.Code=c.Code AND n.RC_ID=rc.RC_ID
)

DELETE d FROM dbo.TAX_U_TM_RC d
WHERE (EXISTS(SELECT * FROM #tm_rc c WHERE d.Code=c.Code)
AND NOT EXISTS(SELECT * FROM #tm_rc c INNER JOIN dbo.TAX_U_RelatedConcept rc ON c.RCCode=rc.Code WHERE d.Code=c.Code AND d.RC_ID=rc.RC_ID))
OR NOT EXISTS(SELECT * FROM dbo.TAX_U_Term t WHERE d.Code=t.Code)

DROP TABLE #tm_rc

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_U_TM_RC_iud] TO [cioc_maintenance_role]
GO
