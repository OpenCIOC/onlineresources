
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_sf]
	@MemberID [int],
	@ProfileID [uniqueidentifier],
	@ErrMsg [nvarchar](500) OUTPUT
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

DECLARE	@MemberObjectName	nvarchar(60),
		@VolunteerProfileObjectName	nvarchar(50)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @VolunteerProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Profile')

DECLARE @DefaultView int,
		@BaseURL varchar(100),
		@BaseFullSSLCompatible bit
		
-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
	SET @MemberID = NULL
END

SELECT	@DefaultView=DefaultViewVOL,
		@BaseURL=BaseURLVOL,
		@BaseFullSSLCompatible=ISNULL(FullSSLCompatible,0)
	FROM STP_Member m 
	LEFT JOIN dbo.GBL_View_DomainMap mp
		ON m.BaseURLVOL=mp.DomainName
WHERE m.MemberID=@MemberID

-- Profile ID given ?
IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
-- Profile exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @VolunteerProfileObjectName)
	SET @ProfileID = NULL
-- Login active ?
END ELSE IF EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID AND MemberID=@MemberID AND Active=0) BEGIN
	SET @Error = 18 -- Login not active.
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
	SET @ProfileID = NULL
-- Login blocked ?
END ELSE IF EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID AND MemberID=@MemberID AND Blocked=1) BEGIN
	SET @Error = 19 -- Login blocked.
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
	SET @ProfileID = NULL
END

SELECT *
	FROM VOL_Profile
WHERE ProfileID=@ProfileID

SELECT cm.CM_ID, cmn.Name AS Community,
	CASE WHEN EXISTS(SELECT * FROM VOL_Profile_CM vpc WHERE cm.CM_ID=vpc.CM_ID AND vpc.ProfileID=@ProfileID) THEN 1 ELSE 0 END AS IS_SELECTED
	FROM GBL_Community cm
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE EXISTS(SELECT * FROM VOL_CommunityGroup_CM cgc
	INNER JOIN VOL_CommunityGroup cg
		ON cgc.CommunityGroupID=cg.CommunityGroupID
	INNER JOIN VOL_View vw
		ON vw.CommunitySetID=cg.CommunitySetID
	WHERE vw.MemberID=@MemberID
		AND cgc.CM_ID=cm.CM_ID
		AND vw.UseProfilesView=1)
ORDER BY cmn.Name

SELECT ai.AI_ID, ain.Name AS InterestName
	FROM VOL_Profile_AI vpa
	INNER JOIN VOL_Interest ai
		ON vpa.AI_ID=ai.AI_ID
	INNER JOIN VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID AND ain.LangID=(SELECT TOP 1 LangID FROM VOL_Interest_Name WHERE AI_ID=ai.AI_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vpa.ProfileID=@ProfileID
ORDER BY ain.Name

SELECT CASE WHEN vw.ViewType=@DefaultView OR DomainName IS NOT NULL THEN NULL ELSE vw.ViewType END AS ViewType,
		ISNULL(DomainName, @BaseURL) + ISNULL(PathToStart,'') COLLATE Latin1_General_100_CI_AI AS AccessURL,
		CASE WHEN vw.ViewType=@DefaultView THEN 1 ELSE 0 END AS DEFAULT_VIEW,
		t.FullSSLCompatible_Cache AS FullSSLCompatible,
		ISNULL(mp.FullSSLCompatible, @BaseFullSSLCompatible) AS DomainFullSSLCompatible
	FROM VOL_View vw
	INNER JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType AND vwd.LangID=(SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN dbo.GBL_Template t
		ON vw.Template=t.Template_ID
	LEFT JOIN (SELECT * FROM GBL_View_DomainMap WHERE SecondaryName = 0) mp
		ON vw.ViewType = mp.VOLViewType
WHERE vw.MemberID=@MemberID
	AND vw.UseProfilesView=1
	AND (
		EXISTS(SELECT * FROM VOL_View_Recurse vr WHERE vr.ViewType=@DefaultView AND vr.CanSee=vw.ViewType)
		OR vw.ViewType=@DefaultView
	)
ORDER BY CASE WHEN vw.ViewType=@DefaultView THEN 0 ELSE 1 END, ViewName

SELECT rf.REF_ID, rf.ReferralDate, rf.ViewType, rf.AccessURL, rf.VolunteerSuccessfulPlacement, rf.VolunteerOutcomeNotes, 
		vo.VNUM, vod.POSITION_TITLE,
		bt.NUM, dbo.fn_GBL_DisplayFullOrgName_2(btd.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL
	FROM VOL_OP_Referral rf
	INNER JOIN VOL_Opportunity vo
		ON rf.VNUM=vo.VNUM
	LEFT JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vo.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE rf.ProfileID=@ProfileID
		AND VolunteerHideReferral=0
ORDER BY ReferralDate DESC

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_sf] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_sf] TO [cioc_vol_search_role]
GO
