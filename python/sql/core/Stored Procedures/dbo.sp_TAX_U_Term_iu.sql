SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_TAX_U_Term_iu]
	@source_file nvarchar(MAX) 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		INT
SET @Error = 0

IF OBJECT_ID('tempdb.dbo.#terms_to_upsert', 'U') IS NOT NULL
  DROP TABLE #terms_to_upsert; 

CREATE TABLE #terms_to_upsert (
	[Code] [varchar](21) COLLATE Latin1_General_100_CI_AI NOT NULL PRIMARY KEY,
	[CREATED_DATE] [datetime] NOT NULL,
	[MODIFIED_DATE] [datetime] NOT NULL,
	[CdLvl1] [char](1) NOT NULL,
	[CdLvl2] [varchar](1) NULL,
	[CdLvl3] [varchar](4) NULL,
	[CdLvl4] [varchar](4) NULL,
	[CdLvl5] [varchar](3) NULL,
	[CdLvl6] [varchar](2) NULL,
	[ParentCode] [varchar](16) COLLATE Latin1_General_100_CI_AI NULL,
	[CdLvl] [tinyint] NOT NULL,
	[Term_en] [nvarchar](255) NULL,
	[Term_fr] [nvarchar](255) NULL,
	[Definition_en] [nvarchar](max) NULL,
	[Definition_fr] [nvarchar](max) NULL,
	[Facet] [nvarchar](255) COLLATE Latin1_General_100_CI_AI NULL,
	[Comments_en] [nvarchar](max) NULL,
	[Comments_fr] [nvarchar](max) NULL,
	[BiblioRef_en] [nvarchar](max) NULL,
	[BiblioRef_fr] [nvarchar](max) NULL
)

DECLARE @sql VARCHAR(MAX)
SET @sql = '
INSERT INTO #terms_to_upsert 
SELECT 
	Code, CREATED_DATE, MODIFIED_DATE, CdLvl1, CdLvl2, CdLvl3, CdLvl4, CdLvl5, CdLvl6, ParentCode, CdLvl, Term_en, Term_fr, Definition_en, Definition_fr, Facet, Comments_en, Comments_fr, BiblioRef_en, BiblioRef_fr 
FROM OPENROWSET ( BULK ''' + @source_file + '''
	, CODEPAGE = ''RAW''
    , FORMAT = ''CSV''
    , DATA_SOURCE = ''s3_bulkimport''
	, FIRSTROW=1
) WITH (
	[Code] [VARCHAR](21),
	[CREATED_DATE] [datetime],
	[MODIFIED_DATE] [datetime],
	[CdLvl1] [char](1),
	[CdLvl2] [varchar](1),
	[CdLvl3] [varchar](4),
	[CdLvl4] [varchar](4),
	[CdLvl5] [varchar](3),
	[CdLvl6] [varchar](2),
	[ParentCode] [varchar](16),
	[CdLvl] [tinyint],
	[Term_en] [nvarchar](255),
	[Term_fr] [nvarchar](255),
	[Definition_en] [nvarchar](max),
	[Definition_fr] [nvarchar](max),
	[Facet] [nvarchar](255),
	[Comments_en] [nvarchar](max),
	[Comments_fr] [nvarchar](max),
	[BiblioRef_en] [nvarchar](max),
	[BiblioRef_fr] [nvarchar](max)
) as csvimport'
EXEC (@sql)

UPDATE t  SET 
    CREATED_DATE=u.CREATED_DATE,
    MODIFIED_DATE=u.MODIFIED_DATE,
    CdLvl1 = u.CdLvl1,
    CdLvl2 = u.CdLvl2,
    CdLvl3=u.CdLvl3,
    CdLvl4=u.CdLvl4,
    CdLvl5=u.CdLvl5,
    CdLvl6=u.CdLvl6,
    ParentCode=u.ParentCode,
    CdLvl=u.CdLvl,
    Term_en=u.Term_en,
    Term_fr=u.Term_fr,
    Authorized=1,
    Active=0,
	[Source]=(SELECT TOP(1) TAX_SRC_ID FROM dbo.TAX_U_Source WHERE SourceName_en='211HSIS'),
    Definition_en=u.Definition_en,
    Definition_fr=u.Definition_fr,
    Facet=(SELECT TOP(1) f.FC_ID FROM dbo.TAX_U_Facet f WHERE f.Facet_en=u.Facet),
    Comments_en=u.Comments_en,
    Comments_fr=u.Comments_fr,
    BiblioRef_en=u.BiblioRef_en,
    BiblioRef_fr=u.BiblioRef_fr
FROM dbo.TAX_U_Term t
INNER JOIN #terms_to_upsert u
	ON t.Code = u.Code

INSERT INTO dbo.TAX_U_Term
(
	Code,
	CREATED_DATE,
	MODIFIED_DATE,
	CdLvl1,
	CdLvl2,
	CdLvl3,
	CdLvl4,
	CdLvl5,
	CdLvl6,
	ParentCode,
	CdLvl,
	Term_en,
	Term_fr,
	Authorized,
	Active,
	[Source],
	Definition_en,
	Definition_fr,
	Facet,
	Comments_en,
	Comments_fr,
	BiblioRef_en,
	BiblioRef_fr
)

SELECT Code,
		CREATED_DATE,
		MODIFIED_DATE,
		CdLvl1,
		CdLvl2,
		CdLvl3,
		CdLvl4,
		CdLvl5,
		CdLvl6,
		ParentCode,
		CdLvl,
		Term_en,
		Term_fr,
		Authorized=1,
		Active=0,
		[Source]=(SELECT TOP(1) TAX_SRC_ID FROM dbo.TAX_U_Source WHERE SourceName_en='211HSIS'),
		Definition_en,
		Definition_fr,
		Facet=(SELECT TOP(1) f.FC_ID FROM dbo.TAX_U_Facet f WHERE f.Facet_en=u.Facet),
		Comments_en,
		Comments_fr,
		BiblioRef_en,
		BiblioRef_fr
FROM #terms_to_upsert u
WHERE NOT EXISTS(SELECT * FROM dbo.TAX_U_Term t WHERE t.Code=u.Code)

DROP TABLE #terms_to_upsert

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_U_Term_iu] TO [cioc_maintenance_role]
GO
