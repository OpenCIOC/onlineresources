SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_History_s]
	@HST_ID int,
	@User_ID int,
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@VNUM varchar(10),
		@FieldID int,
		@FieldName varchar(100)

SELECT @VNUM=VNUM
	FROM VOL_Opportunity_History
WHERE HST_ID=@HST_ID

SELECT @FieldID = fo.FieldID, @FieldName = fo.FieldName
	FROM VOL_FieldOption fo
	INNER JOIN VOL_Opportunity_History hst
		ON fo.FieldID=hst.FieldID
	INNER JOIN VOL_View_UpdateField uf
		ON fo.FieldID = uf.FieldID AND uf.ViewType=@ViewType
WHERE hst.HST_ID=@HST_ID

IF @VNUM IS NULL BEGIN
	SELECT 0 AS CAN_SEE_HISTORY
END ELSE BEGIN
	SELECT CAST(dbo.fn_VOL_CanUpdateRecord(@VNUM,@User_ID,@ViewType,@@LANGID,GETDATE()) AS bit) AS CAN_SEE_HISTORY
END

SELECT FieldDisplay
	FROM VOL_Opportunity_History
WHERE HST_ID=@HST_ID

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_History_s] TO [cioc_login_role]
GO
