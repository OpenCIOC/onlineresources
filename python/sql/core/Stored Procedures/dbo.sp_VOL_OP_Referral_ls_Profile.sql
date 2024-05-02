SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_Referral_ls_Profile]
	@MemberID int,
	@Email [varchar](100),
	@ProfileID uniqueidentifier
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

IF @ProfileID IS NULL BEGIN
	SELECT @ProfileID=ProfileID FROM dbo.VOL_Profile WHERE Email=@Email AND MemberID=@MemberID
END

SELECT	ProfileID,
		CASE WHEN OrgCanContact=1 THEN FirstName ELSE cioc_shared.dbo.fn_SHR_GBL_AnonString(FirstName) END AS FirstName,
		CASE WHEN OrgCanContact=1 THEN LastName ELSE cioc_shared.dbo.fn_SHR_GBL_AnonString(LastName) END AS LastName,
		CASE WHEN OrgCanContact=1 THEN Email ELSE cioc_shared.dbo.fn_SHR_GBL_AnonString(Email) END AS Email,
		OrgCanContact
	FROM dbo.VOL_Profile vp
WHERE ProfileID=@ProfileID
	AND MemberID=@MemberID

SELECT	rf.REF_ID,
		rf.ReferralDate, 
		rf.VolunteerName,
		rf.VolunteerEmail,
		rf.VolunteerCity,
		rf.MODIFIED_DATE, 
		rf.FollowUpFlag,
		rf.SuccessfulPlacement,
		vo.VNUM,
		vod.POSITION_TITLE,
		vo.RECORD_OWNER,
		bt.NUM,
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1),btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_SORT_KEY,
		l.LanguageName
	FROM dbo.VOL_OP_Referral rf
	INNER JOIN dbo.STP_Language l
		ON rf.LangID=l.LangID
	INNER JOIN dbo.VOL_Profile vp
		ON rf.ProfileID=vp.ProfileID
	INNER JOIN dbo.VOL_Opportunity vo
		ON rf.VNUM=vo.VNUM
	INNER JOIN dbo.VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM
			AND vod.LangID=(SELECT TOP 1 LangID FROM dbo.VOL_Opportunity_Description WHERE VNUM=vod.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN dbo.GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	LEFT JOIN dbo.GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
			AND btd.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vp.MemberID=@MemberID
	AND rf.MemberID=@MemberID
	AND vp.ProfileID=@ProfileID
ORDER BY rf.MODIFIED_DATE DESC

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_ls_Profile] TO [cioc_login_role]
GO
