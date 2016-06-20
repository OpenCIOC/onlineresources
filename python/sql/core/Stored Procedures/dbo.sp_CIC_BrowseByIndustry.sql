SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_BrowseByIndustry]
	@Code [varchar](6),
	@ViewType [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 01-Feb-2012
	Action: NO ACTION REQUIRED
*/

SELECT	nc.Code,
		ncd.Classification,
		dbo.fn_CIC_NAICSCount(@ViewType, nc.Code, 1, GETDATE()) AS UsageCount
	FROM NAICS nc
	INNER JOIN NAICS_Description ncd
		ON nc.Code=ncd.Code AND LangID=(SELECT TOP 1 LangID FROM NAICS_Description WHERE Code=ncd.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
WHERE (
		(nc.Code LIKE @Code + '%' AND LEN(nc.Code) = LEN(@Code)+1)  OR
		(nc.Parent = @Code) OR
		(@Code IS NULL AND nc.Parent IS NULL)
	)
	AND (dbo.fn_CIC_NAICSCount(@ViewType, nc.Code, 1, GETDATE()) > 0)

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_BrowseByIndustry] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_BrowseByIndustry] TO [cioc_login_role]
GO
