SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[sp_TAX_U_Metadata_iu]
	@cultures nvarchar(MAX) 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		INT
SET @Error = 0

DECLARE @ParsedCultures table (
	[language] varchar(255) COLLATE Latin1_General_100_CI_AI NOT NULL,
	[country] varchar(255) COLLATE Latin1_General_100_CI_AI NOT NULL
)

DECLARE @MaxDate datetime

SELECT @MaxDate = MAX(MODIFIED_DATE) FROM TAX_U_Term

INSERT INTO @parsedCultures (language, country)
SELECT * FROM dbo.fn_GBL_ParseVarCharIDPairList(@cultures, ',', '_')



UPDATE m SET m.ReleaseDate=@MaxDate, m.Country=l.country, m.Language=l.language
FROM 
dbo.TAX_U_MetaData m
INNER JOIN @ParsedCultures l
	ON m.Language=l.language AND l.country=m.Country

INSERT INTO dbo.TAX_U_MetaData (Country, Language, ReleaseDate)
SELECT l.country, l.language, @MaxDate
FROM @ParsedCultures l WHERE NOT EXISTS(SELECT * FROM dbo.TAX_U_MetaData m WHERE m.Language=l.language AND l.country=m.Country)

DELETE m
FROM dbo.TAX_U_MetaData m
WHERE NOT EXISTS(SELECT * FROM @ParsedCultures l WHERE m.Language=l.language AND l.country=m.Country)

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_U_Metadata_iu] TO [cioc_login_role]
GO
