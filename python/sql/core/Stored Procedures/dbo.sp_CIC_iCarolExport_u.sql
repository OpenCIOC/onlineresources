SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_iCarolExport_u]
	@NUM VARCHAR(8),
	@Code varchar(20),
	@ExternalID varchar(50),
	@ExportDate smalldatetime
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		INT
SET @Error = 0

UPDATE btols SET btols.EXTERNAL_ID=ISNULL(@ExternalID, btols.EXTERNAL_ID), btols.QUEUE_FOR_EXPORT=0, btols.EXPORT_DATE=ISNULL(@ExportDate, btols.EXPORT_DATE)
FROM dbo.GBL_BT_OLS btols INNER JOIN dbo.GBL_OrgLocationService ols ON ols.OLS_ID = btols.OLS_ID
WHERE btols.NUM=@NUM AND ols.Code=@Code

RETURN @Error

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_CIC_iCarolExport_u] TO [cioc_login_role]
GO
