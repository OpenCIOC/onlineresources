SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_History_sl]
	@NUM varchar(8),
	@User_ID int,
	@ViewType int,
	@LangID tinyint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @CanSeeHistory bit

IF @NUM IS NULL BEGIN
	SET @CanSeeHistory=0
END ELSE BEGIN
	SET @CanSeeHistory=dbo.fn_CIC_CanUpdateRecord(@NUM,@User_ID,@ViewType,@LangID,GETDATE())
END

SELECT @CanSeeHistory AS CAN_SEE_HISTORY

SELECT DISTINCT hst.MODIFIED_DATE, hst.MODIFIED_BY, fo.FieldName, ISNULL(fod.FieldDisplay,fo.FieldName) AS FieldDisplay
	FROM GBL_BaseTable_History hst
	INNER JOIN GBL_FieldOption fo
		ON hst.FieldID=fo.FieldID
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN CIC_View_UpdateField uf
		ON fo.FieldID=uf.FieldID
	INNER JOIN CIC_View_DisplayFieldGroup fg
		ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType
WHERE hst.NUM=@NUM AND hst.LangID=@LangID
	AND @CanSeeHistory=1
ORDER BY hst.MODIFIED_DATE DESC, hst.MODIFIED_BY, ISNULL(fod.FieldDisplay,fo.FieldName)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_History_sl] TO [cioc_login_role]
GO
