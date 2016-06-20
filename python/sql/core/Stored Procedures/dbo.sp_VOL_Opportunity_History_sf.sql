SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_History_sf]
	@FieldName varchar(100),
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

DECLARE @FieldID int

SELECT @FieldID = fo.FieldID
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_View_UpdateField uf
		ON fo.FieldID = uf.FieldID AND uf.ViewType=@ViewType
WHERE fo.FieldName = @FieldName AND uf.FieldID IS NOT NULL

SELECT dbo.fn_VOL_CanUpdateRecord(@VNUM,@User_ID,@ViewType,@LangID,GETDATE()) AS CAN_SEE_HISTORY

SELECT TOP 1 @LangID = sln.LangID
	FROM VOL_Opportunity_Description vod
	INNER JOIN STP_Language sln
		ON vod.LangID=sln.LangID
ORDER BY CASE WHEN sln.LangID=@LangID THEN 0 ELSE 1 END, sln.LanguageName

SELECT sln.LangID, sln.LanguageName
	FROM VOL_Opportunity_Description vod
	INNER JOIN STP_Language sln
		ON vod.LangID=sln.LangID
WHERE vod.VNUM=@VNUM
ORDER BY CASE WHEN sln.LangID=@LangID THEN 0 ELSE 1 END, sln.LanguageName

SELECT HST_ID, MODIFIED_DATE, MODIFIED_BY
	FROM VOL_Opportunity_History
WHERE FieldID=@FieldID AND VNUM=@VNUM AND LangID=@LangID
ORDER BY HST_ID DESC

SELECT TOP 1 FieldDisplay
	FROM VOL_Opportunity_History
WHERE FieldID=@FieldID AND VNUM=@VNUM AND LangID=@LangID
ORDER BY HST_ID DESC

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_History_sf] TO [cioc_login_role]
GO
