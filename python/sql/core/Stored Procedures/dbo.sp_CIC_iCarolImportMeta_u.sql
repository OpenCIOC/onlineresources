SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_iCarolImportMeta_u]
	@Mechanism NVARCHAR(50),
	@LastFetched SMALLDATETIME 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		INT
SET @Error = 0


UPDATE ii SET ii.DELETION_DATE=@LastFetched
FROM dbo.CIC_iCarolImport ii
LEFT JOIN dbo.CIC_iCarolImportAllRecords ar
	ON ii.ResourceAgencyNum=ar.ResourceAgencyNum AND ii.LangID=ar.LangID
WHERE ar.ResourceAgencyNum IS NULL

UPDATE dbo.CIC_iCarolImportMeta SET LastFetched=@LastFetched WHERE Mechanism=@Mechanism

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_iCarolImportMeta_u] TO [cioc_login_role]
GO
