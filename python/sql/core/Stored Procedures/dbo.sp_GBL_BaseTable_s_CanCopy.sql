
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_s_CanCopy]
	@NUM varchar(8),
	@Agency char(3),
	@User_ID int,
	@ViewType int,
	@Culture varchar(5)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 02-Oct-2013
	Action: NO ACTION REQUIRED
*/

SELECT	(SELECT ISNULL(FieldDisplay,FieldName)
			FROM GBL_FieldOption fo
			LEFT JOIN GBL_FieldOption_Description fod
				ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID WHERE FieldName='RECORD_TYPE') AS RecordTypeName,
		CAST(CASE WHEN EXISTS(SELECT * FROM CIC_SecurityLevel_RecordType srt INNER JOIN GBL_Users u ON srt.SL_ID=u.SL_ID_CIC WHERE u.User_ID=@User_ID) THEN 1 ELSE 0 END AS bit) AS LimitRecordType,
		cbt.RECORD_TYPE AS CUR_RT_ID,
		CASE WHEN @Culture IS NULL THEN dbo.fn_CIC_CanUpdateRecord(@NUM,@User_ID,@ViewType,@@LANGID,GETDATE()) ELSE dbo.fn_CIC_CanCreateEquivalent(@NUM, @User_ID, @ViewType, (SELECT LangID FROM STP_Language WHERE Culture=@Culture), GETDATE(),@@LANGID) END AS CAN_UPDATE,
		(SELECT LangID FROM STP_Language WHERE Culture=@Culture AND ActiveRecord=1) AS LangID,
		(SELECT LanguageName FROM STP_Language WHERE Culture=@Culture AND ActiveRecord=1) AS LanguageName,
		(SELECT CASE WHEN @Culture IS NULL THEN NULL ELSE dbo.fn_GBL_LowestUnusedNUM(@Agency) END) AS NewNUM,
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2
	FROM GBL_BaseTable_Description btd
	INNER JOIN GBL_BaseTable bt
		ON bt.NUM=btd.NUM
	LEFT JOIN CIC_BaseTable cbt
		ON bt.NUM=cbt.NUM
WHERE bt.NUM=@NUM AND LangID=@@LANGID

SET NOCOUNT OFF

GO

GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_s_CanCopy] TO [cioc_login_role]
GO
