SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_NAICS_Exclusion_l]
	@Code [varchar](6),
	@AllLangs bit = 0
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action: NO ACTION REQUIRED
*/

SELECT Exclusion_ID, Establishment, Description
	FROM NAICS_Exclusion
WHERE Code = @Code AND (@AllLangs=1 OR LangID=@@LANGID)
ORDER BY Establishment, Description

SELECT Exclusion_ID, nc.Code, ncd.Classification
	FROM NAICS_Exclusion_Use eu
	INNER JOIN NAICS nc
		ON eu.UseCode=nc.Code
	INNER JOIN NAICS_Description ncd
		ON nc.Code=ncd.Code AND LangID=(SELECT TOP 1 LangID FROM NAICS_Description WHERE Code=ncd.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
WHERE EXISTS(SELECT * FROM NAICS_Exclusion WHERE Code=@Code AND Exclusion_ID=eu.Exclusion_ID)
ORDER BY Exclusion_ID, nc.Code

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_NAICS_Exclusion_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_NAICS_Exclusion_l] TO [cioc_login_role]
GO
