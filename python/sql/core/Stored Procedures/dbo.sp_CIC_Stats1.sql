
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CIC_Stats1]
	@MemberID int,
	@ViewType int,
	@Agency varchar(3),
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

/*
	Checked for Release: 3.6.2
	Checked by: KL
	Checked on: 18-Feb-2015
	Action: NO ACTION REQUIRED
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

SELECT	bt.NUM, 
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		UsageCount,
		dbo.fn_CIC_RecordInView(bt.NUM,@ViewType,@@LANGID,0,GETDATE()) AS InCurrentView 
	FROM (SELECT st.RSN,
			COUNT(*) AS UsageCount
		FROM CIC_Stats_RSN st
		LEFT JOIN dbo.fn_GBL_ParseVarCharIDList(@ViewList,',') tm
			ON st.ViewType=tm.ItemID
		INNER JOIN dbo.GBL_BaseTable bt
			ON bt.RSN = st.RSN
		WHERE st.MemberID=@MemberID
			AND (@Agency IS NULL OR bt.RECORD_OWNER = @Agency)
			AND (@IPAddress IS NULL OR st.IPAddress Like @IPAddress + '%')
			AND (@SL_ID IS NULL OR (EXISTS(SELECT * FROM GBL_Users us WHERE us.SL_ID_CIC=@SL_ID AND us.[User_ID]=st.[User_ID])))
			AND (@Staff IS NULL OR (@Staff = 1 AND st.[User_ID] IS NOT NULL) OR (@Staff=0 AND st.[User_ID] IS NULL))
			AND (@StartDate IS NULL OR st.AccessDate >= @StartDate)
			AND (@EndDate IS NULL OR st.AccessDate < @EndDate)
			AND (@LimitLangID IS NULL OR st.LangID = @LimitLangID)
			AND (
				@RobotID IS NULL
				OR (@RobotID=-1 AND RobotID IS NULL)
				OR (@RobotID=0 AND RobotID IS NOT NULL)
				OR RobotID=@RobotID
			)
			AND (@ViewList IS NULL OR tm.ItemID IS NOT NULL)
		GROUP BY st.RSN
	) st
	LEFT JOIN GBL_BaseTable bt
		ON st.RSN=bt.RSN
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
			AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY CASE WHEN bt.NUM IS NULL THEN 1 ELSE 0 END, UsageCount DESC,
	ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
		STUFF(
			CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=bt.NUM)
				THEN NULL
				ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')
				 END,
			1, 2, ''
		)

RETURN @Error

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Stats1] TO [cioc_login_role]
GO
