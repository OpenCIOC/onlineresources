SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_iCarolExport_u]
	@NUM VARCHAR(8),
	@Code varchar(20),
	@ExternalID varchar(max),
	@ExportDate smalldatetime,
	@PostalCodeError bit,
	@CityError bit,
	@OtherError bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		INT
SET @Error = 0

UPDATE btols SET btols.EXTERNAL_ID=CASE WHEN @ExternalID IS NULL THEN btols.EXTERNAL_ID ELSE (SELECT x.value FROM STRING_SPLIT(@ExternalID, ';', 1) x WHERE x.ordinal=1) END, btols.QUEUE_FOR_EXPORT=0, btols.EXPORT_DATE=ISNULL(@ExportDate, btols.EXPORT_DATE), POSTAL_CODE_ERROR=@PostalCodeError, CITY_ERROR=@CityError, OTHER_ERROR=@OtherError
FROM dbo.GBL_BT_OLS btols INNER JOIN dbo.GBL_OrgLocationService ols ON ols.OLS_ID = btols.OLS_ID
WHERE btols.NUM=@NUM AND ols.Code=@Code

IF @ExternalID IS NOT NULL BEGIN

DECLARE @ProgramAtSites TABLE (
   BT_OLS_ID INT, SITE_NUM VARCHAR(8), EXTERNAL_ID NVARCHAR(50)
)

DECLARE @BtOlsID INT 

SET @BtOlsID = (SELECT TOP (1) BT_OLS_ID FROM GBL_BT_OLS btols INNER JOIN dbo.GBL_OrgLocationService ols ON btols.OLS_ID=ols.OLS_ID WHERE btols.NUM=@NUM AND ols.Code=@Code)

INSERT INTO @ProgramAtSites
(
    BT_OLS_ID,
	SITE_NUM,
    EXTERNAL_ID
)
SELECT 
	@BtOlsID,
	MAX(CASE WHEN cols.ordinal=2 THEN cols.value END) AS EXTERNAL_ID, MAX(CASE WHEN cols.ordinal=1 THEN cols.value END) AS SITE_NUM
FROM STRING_SPLIT(@ExternalID, ';', 1) ext
CROSS APPLY STRING_SPLIT(ext.value, '/', 1) cols
WHERE @ExternalID LIKE '%;%' AND ext.ordinal > 1
GROUP BY ext.ordinal, ext.value

DELETE btols FROM dbo.GBL_BT_OLS_prog_at_site AS btols WHERE BT_OLS_ID=@BtOlsID AND NOT EXISTS(SELECT * FROM @ProgramAtSites pas WHERE btols.SITE_NUM=pas.SITE_NUM AND btols.EXTERNAL_ID=pas.EXTERNAL_ID)
INSERT INTO dbo.GBL_BT_OLS_prog_at_site
(
    BT_OLS_ID,
    EXTERNAL_ID,
    SITE_NUM
)
SELECT BT_OLS_ID, EXTERNAL_ID, SITE_NUM 
FROM @ProgramAtSites pas
WHERE NOT EXISTS(SELECT * FROM dbo.GBL_BT_OLS_prog_at_site btols WHERE btols.EXTERNAL_ID=pas.EXTERNAL_ID AND btols.SITE_NUM=pas.SITE_NUM AND btols.EXTERNAL_ID=pas.EXTERNAL_ID)

END
	
RETURN @Error

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_CIC_iCarolExport_u] TO [cioc_login_role]
GO
