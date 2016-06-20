SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_Referral_Search]
	@MemberID int,
	@RecordOwner [varchar](3),
	@RefStartDate [smalldatetime],
	@RefEndDate [smalldatetime],
	@ModStartDate [smalldatetime],
	@ModEndDate [smalldatetime],
	@OrgKeywords [nvarchar](1000),
	@PosKeywords [nvarchar](1000),
	@VolunteerName [nvarchar](100),
	@FollowUp [bit]
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

DECLARE @NormPosKeywords nvarchar(1000),
		@NormOrgKeywords nvarchar(1000)
		
SET @OrgKeywords = RTRIM(LTRIM(@OrgKeywords))
IF @OrgKeywords = '' SET @OrgKeywords = NULL
SET @NormOrgKeywords = ISNULL(@Orgkeywords, '""')

SET @PosKeywords = RTRIM(LTRIM(@PosKeywords))
IF @PosKeywords = '' SET @PosKeywords = NULL
SET @NormPosKeywords = ISNULL(@Poskeywords, '""')

SET @VolunteerName = RTRIM(LTRIM(@VolunteerName))
IF @VolunteerName = '' SET @VolunteerName = NULL

SELECT rf.REF_ID, rf.ReferralDate, 
		rf.VolunteerName, 
		rf.MODIFIED_DATE, 
		rf.FollowUpFlag,
		rf.SuccessfulPlacement,
		vo.VNUM, vod.POSITION_TITLE, vo.RECORD_OWNER,
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1),btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_SORT_KEY,
		l.LanguageName
	FROM VOL_OP_Referral rf
	INNER JOIN STP_Language l
		ON rf.LangID=l.LangID
	INNER JOIN VOL_Opportunity vo
		ON rf.VNUM=vo.VNUM
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vod.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE rf.MemberID=@MemberID
	AND (@RecordOwner IS NULL OR vo.RECORD_OWNER=@RecordOwner)
 	AND (@RefStartDate IS NULL OR rf.ReferralDate >= @RefStartDate)
	AND (@RefEndDate IS NULL OR rf.ReferralDate < @RefEndDate)
 	AND (@ModStartDate IS NULL OR rf.MODIFIED_DATE >= @ModStartDate)
	AND (@ModEndDate IS NULL OR rf.MODIFIED_DATE < @ModEndDate)
	AND (@OrgKeywords IS NULL OR CONTAINS(btd.SRCH_Org, @NormOrgkeywords))
	AND (@PosKeywords IS NULL OR CONTAINS(vod.POSITION_TITLE, @NormPoskeywords))
	AND (@VolunteerName IS NULL OR VolunteerName LIKE '%' + @VolunteerName + '%')
	AND (@FollowUp IS NULL OR rf.FollowUpFlag = @FollowUp)
ORDER BY rf.MODIFIED_DATE DESC

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_Search] TO [cioc_login_role]
GO
