SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Stats3]
	@MemberID int,
	@ViewType int,
	@LimitByView bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT TOP 50 dbo.fn_GBL_DisplayFullOrgName_2(vo.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		vo.VNUM, vod.POSITION_TITLE,
		COUNT(st.[User_ID]) AS StaffUsageCount,
		COUNT(st.Log_ID) AS UsageCount,
		dbo.fn_VOL_RecordInView(vo.VNUM,@ViewType,@@LANGID,0,GETDATE()) AS InCurrentView
	FROM VOL_Stats_OPID st
	INNER JOIN VOL_Opportunity vo
		ON st.OP_ID=vo.OP_ID
	LEFT JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vo.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
			AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE st.MemberID=@MemberID
	AND (@LimitByView=0 OR st.ViewType=@ViewType)
GROUP BY btd.NUM, btd.SORT_AS, btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
	btd.LOCATION_NAME, btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2, bt.DISPLAY_ORG_NAME, bt.DISPLAY_LOCATION_NAME,
	vo.NUM, vo.VNUM, vod.POSITION_TITLE
ORDER BY COUNT(st.Log_ID) DESC,
	ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
		STUFF(
			CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)
				THEN NULL
				ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')
				 END,
			1, 2, ''
		),
	vod.POSITION_TITLE, vo.VNUM

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Stats3] TO [cioc_login_role]
GO
