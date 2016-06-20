SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_History_sl]
	@VNUM varchar(10),
	@User_ID int,
	@ViewType int,
	@LangID tinyint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE @CanSeeHistory bit

IF @VNUM IS NULL BEGIN
	SET @CanSeeHistory=0
END ELSE BEGIN
	SET @CanSeeHistory=dbo.fn_VOL_CanUpdateRecord(@VNUM,@User_ID,@ViewType,@LangID,GETDATE())
END

SELECT @CanSeeHistory AS CAN_SEE_HISTORY

SELECT DISTINCT hst.MODIFIED_DATE, hst.MODIFIED_BY, fo.FieldName, ISNULL(fod.FieldDisplay,fo.FieldName) AS FieldDisplay
	FROM VOL_Opportunity_History hst
	INNER JOIN VOL_FieldOption fo
		ON hst.FieldID=fo.FieldID
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN VOL_View_UpdateField uf
		ON fo.FieldID=uf.FieldID AND uf.ViewType=@ViewType
WHERE hst.VNUM=@VNUM AND hst.LangID=@LangID
	AND @CanSeeHistory=1
ORDER BY hst.MODIFIED_DATE DESC, hst.MODIFIED_BY, ISNULL(fod.FieldDisplay,fo.FieldName)

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_History_sl] TO [cioc_login_role]
GO
