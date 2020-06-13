SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_iCarolImport_l_Unmatched]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		INT
SET @Error = 0

SELECT i.ResourceAgencyNum, i.PublicName, i.TaxonomyLevelName, i.PhysicalCity
FROM dbo.CIC_iCarolImportRollup i
WHERE NOT EXISTS(SELECT * FROM dbo.GBL_baseTable ib WHERE ib.EXTERNAL_ID=i.ResourceAgencyNum AND ib.SOURCE_DB_CODE='ICAROL') AND NOT EXISTS(SELECT * FROM dbo.GBL_Agency a WHERE a.AgencyCode = i.RECORD_OWNER AND a.AutoImportFromICarol=1) AND i.LangID=@@LANGID


RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_iCarolImport_l_Unmatched] TO [cioc_login_role]
GO
