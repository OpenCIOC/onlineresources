SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_Referral_Stats]
	@MemberID int,
	@RecordOwner [varchar](3),
	@StartDate [smalldatetime],
	@EndDate [smalldatetime],
	@OrgKeywords [nvarchar](1000),
	@CountThreshold [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE @Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

DECLARE @NormOrgKeywords nvarchar(1000)

SET @OrgKeywords = RTRIM(LTRIM(@OrgKeywords))
IF @OrgKeywords = '' SET @OrgKeywords = NULL
SET @NormOrgKeywords = ISNULL(@Orgkeywords, '""')

SELECT btd.NUM, 
	dbo.fn_GBL_DisplayFullOrgName_2(btd.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
	vo.VNUM, vod.POSITION_TITLE,
	COUNT(rf.VNUM) AS ReferralCount,
	COUNT(CASE WHEN SuccessfulPlacement=1 THEN 1 ELSE NULL END) AS PlacementCount
FROM  VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vod.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN GBL_BaseTable bt
		ON vo.NUM = bt.NUM
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_OP_Referral rf
		ON rf.MemberID=@MemberID
			AND vo.VNUM = rf.VNUM
			AND (@StartDate IS NULL OR rf.ReferralDate >= @StartDate)
			AND (@EndDate IS NULL OR rf.ReferralDate < @EndDate)
WHERE (@RecordOwner IS NULL OR vo.RECORD_OWNER=@RecordOwner)
	AND (@OrgKeywords IS NULL OR CONTAINS(btd.SRCH_Org, @NormOrgKeywords))
GROUP BY btd.NUM, btd.SORT_AS, btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, btd.LOCATION_NAME, btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME,
	vo.VNUM, vod.POSITION_TITLE
HAVING (@CountThreshold IS NULL OR @CountThreshold < 1 OR COUNT(rf.VNUM) >= @CountThreshold)
ORDER BY ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
		STUFF(
			CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)
				THEN NULL
				ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')
				 END,
			1, 2, ''
		),
	ReferralCount DESC, vod.POSITION_TITLE, vo.VNUM

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_Stats] TO [cioc_login_role]
GO
