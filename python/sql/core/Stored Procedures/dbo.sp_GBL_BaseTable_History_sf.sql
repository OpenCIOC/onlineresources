SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_History_sf]
	@FieldName varchar(100),
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
	Checked on: 28-Feb-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @FieldID int

IF @FieldName='TAXONOMY' BEGIN
	SELECT @FieldID = fo.FieldID
		FROM GBL_FieldOption fo
	WHERE fo.FieldName = 'TAXONOMY'
	SELECT dbo.fn_CIC_CanIndexRecord(@NUM,@User_ID,@ViewType,@LangID,GETDATE()) AS CAN_SEE_HISTORY
END ELSE BEGIN
	SELECT @FieldID = fo.FieldID
		FROM GBL_FieldOption fo
		LEFT JOIN CIC_View_UpdateField uf
			ON fo.FieldID = uf.FieldID
		INNER JOIN CIC_View_DisplayFieldGroup fg
			ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID AND fg.ViewType=@ViewType
	WHERE fo.FieldName = @FieldName AND (@FieldName='TAXONOMY' OR uf.FieldID IS NOT NULL)
	SELECT dbo.fn_CIC_CanUpdateRecord(@NUM,@User_ID,@ViewType,@LangID,GETDATE()) AS CAN_SEE_HISTORY
END

SELECT TOP 1 @LangID = sln.LangID
	FROM GBL_BaseTable_Description btd
	INNER JOIN STP_Language sln
		ON btd.LangID=sln.LangID
ORDER BY CASE WHEN sln.LangID=@LangID THEN 0 ELSE 1 END, sln.LanguageName

SELECT sln.LangID, sln.LanguageName
	FROM GBL_BaseTable_Description btd
	INNER JOIN STP_Language sln
		ON btd.LangID=sln.LangID
WHERE btd.NUM=@NUM
ORDER BY CASE WHEN sln.LangID=@LangID THEN 0 ELSE 1 END, sln.LanguageName

SELECT HST_ID, MODIFIED_DATE, MODIFIED_BY
	FROM GBL_BaseTable_History
WHERE FieldID=@FieldID AND NUM=@NUM AND LangID=@LangID
ORDER BY HST_ID DESC

SELECT TOP 1 FieldDisplay
	FROM GBL_BaseTable_History
WHERE FieldID=@FieldID AND NUM=@NUM AND LangID=@LangID
ORDER BY HST_ID DESC

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_History_sf] TO [cioc_login_role]
GO
