SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_NAICS_NarrowerCodes_sl]
	@Code [varchar](6)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action:	NO ACTION REQUIRED
*/

DECLARE 	@SearchString varchar(10)

SELECT @SearchString=ISNULL(SearchChildren, Code)+'%'
	FROM NAICS
WHERE Code=@Code

SELECT nc.Code, ncd.Classification
	FROM NAICS nc
	INNER JOIN NAICS_Description ncd
		ON nc.Code=ncd.Code AND LangID=(SELECT TOP 1 LangID FROM NAICS_Description WHERE Code=ncd.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
WHERE nc.Code <> @Code AND 
	Len(nc.Code) = Len(@Code)+1 AND
	(nc.Code Like @SearchString)
ORDER BY nc.Code

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_NAICS_NarrowerCodes_sl] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_NAICS_NarrowerCodes_sl] TO [cioc_login_role]
GO
