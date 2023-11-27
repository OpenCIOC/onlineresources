SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Stats1_Gen]
	@MemberID int,
	@ViewType int,
	@IdList varchar(max),
	@SL_ID int,
	@ViewList varchar(max),
	@StartDate smalldatetime,
	@EndDate smalldatetime,
	@IPAddress varchar(50),
	@Staff bit,
	@LimitLangID smallint,
	@RobotID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT 	dbo.fn_GBL_DisplayFullOrgName_2(btd.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		vo.VNUM, vod.POSITION_TITLE,
		COUNT(*) AS UsageCount,
		dbo.fn_VOL_RecordInView(vo.VNUM,@ViewType,@@LANGID,0,GETDATE()) AS InCurrentView
	FROM dbo.fn_GBL_ParseVarCharIDList(@IdList,',') tm
	INNER JOIN dbo.VOL_Opportunity vo
		ON tm.ItemID=vo.VNUM COLLATE Latin1_General_100_CI_AI
	LEFT JOIN dbo.VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM dbo.VOL_Opportunity_Description WHERE VNUM=vo.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN dbo.GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	INNER JOIN dbo.GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
			AND btd.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_BaseTable_Description WHERE NUM=bt.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN dbo.VOL_Stats_OPID st
		 ON vo.OP_ID = st.OP_ID
	LEFT JOIN dbo.fn_GBL_ParseVarCharIDList(@ViewList,',') tm2
		ON st.ViewType=tm2.ItemID
WHERE st.MemberID=@MemberID
	AND (@IPAddress IS NULL OR st.IPAddress Like @IPAddress + '%')
	AND (@SL_ID IS NULL OR (EXISTS(SELECT * FROM dbo.GBL_Users us WHERE us.SL_ID_VOL=@SL_ID AND us.[User_ID]=st.[User_ID])))
	AND (@Staff IS NULL OR (@Staff = 1 AND st.[User_ID] IS NOT NULL) OR (@Staff=0 AND st.[User_ID] IS NULL))
	AND (@StartDate IS NULL OR st.AccessDate >= @StartDate)
	AND (@EndDate IS NULL OR st.AccessDate < @EndDate)
	AND (@LimitLangID IS NULL OR st.LangID = @LimitLangID)
	AND (@ViewList IS NULL OR tm2.ItemID IS NOT NULL)
GROUP BY btd.NUM, btd.SORT_AS, btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, btd.LOCATION_NAME, btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2, bt.DISPLAY_ORG_NAME, bt.DISPLAY_LOCATION_NAME,
	vo.VNUM, vod.POSITION_TITLE
ORDER BY CASE WHEN vo.VNUM IS NULL THEN 1 ELSE 0 END, UsageCount DESC, 
	ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
		STUFF(
			CASE WHEN EXISTS(SELECT * FROM dbo.GBL_BT_OLS pr INNER JOIN dbo.GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)
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
GRANT EXECUTE ON  [dbo].[sp_VOL_Stats1_Gen] TO [cioc_login_role]
GO
