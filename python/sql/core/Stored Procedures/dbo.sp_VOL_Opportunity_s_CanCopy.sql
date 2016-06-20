
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_s_CanCopy]
	@VNUM varchar(10),
	@Agency char(3),
	@User_ID int,
	@ViewType int,
	@Culture varchar(5)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

SELECT	CASE WHEN @Culture IS NULL THEN dbo.fn_VOL_CanUpdateRecord(@VNUM,@User_ID,@ViewType,@@LANGID,GETDATE()) ELSE dbo.fn_VOL_CanCreateEquivalent(@VNUM,@User_ID,@ViewType,(SELECT LangID FROM STP_Language WHERE Culture=@Culture),GETDATE(),@@LANGID) END AS CAN_UPDATE,
		(SELECT LangID FROM STP_Language WHERE Culture=@Culture AND ActiveRecord=1) AS LangID,
		(SELECT LanguageName FROM STP_Language WHERE Culture=@Culture AND ActiveRecord=1) AS LanguageName,
		(SELECT CASE WHEN @Culture IS NULL THEN NULL ELSE dbo.fn_VOL_LowestUnusedVNUM(@Agency) END) AS NewVNUM,
		POSITION_TITLE,
		dbo.fn_GBL_DisplayFullOrgName_Agency_2(btd.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2) AS ORG_NAME_FULL
	FROM VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=@@LANGID
	INNER JOIN GBL_BaseTable_Description btd
		ON btd.NUM=vo.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vo.VNUM=@VNUM

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_s_CanCopy] TO [cioc_login_role]
GO
