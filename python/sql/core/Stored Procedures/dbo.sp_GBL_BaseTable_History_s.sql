SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_History_s]
	@HST_ID int,
	@User_ID int,
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Feb-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@NUM varchar(8),
		@FieldID int,
		@FieldName varchar(100)

SELECT @NUM=NUM
	FROM GBL_BaseTable_History
WHERE HST_ID=@HST_ID

SELECT @FieldID = fo.FieldID, @FieldName = fo.FieldName
	FROM GBL_FieldOption fo
	INNER JOIN GBL_BaseTable_History hst
		ON fo.FieldID=hst.FieldID
	INNER JOIN CIC_View_UpdateField uf
		ON fo.FieldID = uf.FieldID
	INNER JOIN CIC_View_DisplayFieldGroup fg
		ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType
WHERE hst.HST_ID=@HST_ID

IF @NUM IS NULL BEGIN
	SELECT 0 AS CAN_SEE_HISTORY
END ELSE IF @FieldName='TAXONOMY' BEGIN
	SELECT dbo.fn_CIC_CanIndexRecord(@NUM,@User_ID,@ViewType,@@LANGID,GETDATE()) AS CAN_SEE_HISTORY
END ELSE BEGIN
	SELECT CAST(dbo.fn_CIC_CanUpdateRecord(@NUM,@User_ID,@ViewType,@@LANGID,GETDATE()) AS bit) AS CAN_SEE_HISTORY
END

SELECT FieldDisplay
	FROM GBL_BaseTable_History
WHERE HST_ID=@HST_ID

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_History_s] TO [cioc_login_role]
GO
