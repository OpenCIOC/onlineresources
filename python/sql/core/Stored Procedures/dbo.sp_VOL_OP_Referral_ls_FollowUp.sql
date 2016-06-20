SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_Referral_ls_FollowUp]
	@MemberID int,
	@RECORD_OWNER [varchar](3)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

SELECT rf.REF_ID, rf.ReferralDate, 
		rf.VolunteerName, rf.VolunteerEmail, 
		rf.MODIFIED_DATE, 
		rf.FollowUpFlag, rf.SuccessfulPlacement,
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
		ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vo.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE rf.MemberID=@MemberID
	AND FollowUpFlag = 1
	AND (@RECORD_OWNER IS NULL OR (vo.RECORD_OWNER=@RECORD_OWNER))
ORDER BY rf.MODIFIED_DATE DESC

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_ls_FollowUp] TO [cioc_login_role]
GO
