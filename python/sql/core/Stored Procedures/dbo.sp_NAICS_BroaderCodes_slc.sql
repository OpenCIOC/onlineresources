SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_NAICS_BroaderCodes_slc]
	@Code [varchar](6),
	@ViewType [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 01-Feb-2011
	Action: NO ACTION REQUIRED
*/

DECLARE	@Sector char(2)

SELECT @Sector = Parent
	FROM NAICS

WHERE Code = left(@Code,3)

SELECT nc.Code, ncd.Classification, 
		dbo.fn_CIC_NAICSCount(@ViewType, nc.Code, 0, GETDATE()) AS UsageCount
	FROM NAICS nc
	INNER JOIN NAICS_Description ncd
		ON nc.Code=ncd.Code AND LangID=(SELECT TOP 1 LangID FROM NAICS_Description WHERE Code=ncd.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
WHERE nc.Code <> @Code
	AND (
		nc.Code = LEFT(@Code,5) OR
		nc.Code = LEFT(@Code,4) OR
		nc.Code = LEFT(@Code,3) OR
		nc.Code = LEFT(@Code,2) OR
		nc.Code = @Sector
	)
ORDER BY nc.Code

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_NAICS_BroaderCodes_slc] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_NAICS_BroaderCodes_slc] TO [cioc_login_role]
GO
