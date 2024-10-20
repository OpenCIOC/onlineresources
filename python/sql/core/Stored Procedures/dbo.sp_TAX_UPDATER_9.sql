SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_9]
WITH EXECUTE AS CALLER
AS
BEGIN

SET NOCOUNT ON

/* Update history values for all changed Taxonomy fields */
DECLARE @FieldID int
SELECT @FieldID=FieldID FROM dbo.GBL_FieldOption WHERE FieldName='TAXONOMY'

DECLARE @NUMList varchar(max)

SELECT @NUMList = COALESCE(@NUMList + ',','') + cbtd.NUM
	FROM dbo.CIC_Basetable_Description cbtd
	LEFT JOIN dbo.GBL_BaseTable_History hst
		ON hst.NUM=cbtd.NUM AND hst.LangID=cbtd.LangID AND hst.FieldID=@FieldID
			AND hst.HST_ID=(SELECT MAX(HST_ID) FROM dbo.GBL_BaseTable_History WHERE NUM=cbtd.NUM AND LangID=cbtd.LangID AND FieldID=@FieldID)
WHERE cbtd.CMP_Taxonomy <> hst.FieldDisplay COLLATE Latin1_General_100_CS_AS OR (hst.FieldDisplay IS NULL AND cbtd.CMP_Taxonomy IS NOT NULL)

DECLARE @Now datetime
SET @Now = GETDATE()

EXEC sp_GBL_BaseTable_History_i_Field '(Import)', @Now, @NUMList, 'TAXONOMY', NULL, NULL, NULL

SET NOCOUNT OFF

END

GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_9] TO [cioc_login_role]
GO
