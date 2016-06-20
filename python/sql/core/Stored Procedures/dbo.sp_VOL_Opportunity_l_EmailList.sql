
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_l_EmailList]
	@MemberID int,
	@ViewType int,
	@TargetView int,
	@NoDeleted bit,
	@IDList varchar(MAX)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: CL
	Checked on: 29-Jun-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE @DefaultView int
SELECT @DefaultView = DefaultViewVOL FROM STP_Member WHERE MemberID=@MemberID

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END ELSE IF @TargetView IS NOT NULL AND @TargetView <> @DefaultView AND NOT EXISTS(SELECT * FROM VOL_View vw INNER JOIN VOL_View_Recurse vr ON vr.CanSee = vw.ViewType WHERE vr.ViewType=@DefaultView AND vr.CanSee=@TargetView) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT bt.NUM, vod.POSITION_TITLE + CHAR(13) + CHAR(10) + dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
	dbo.fn_VOL_RecordInView(vo.VNUM, ISNULL(@TargetView, @DefaultView), @@LANGID, @NoDeleted, GETDATE()) AS IN_VIEW
	FROM VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vod.VNUM = vo.VNUM AND vod.LangID=@@LANGID
	INNER JOIN GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=vod.LangID
	WHERE @Error = 0 AND EXISTS(SELECT * FROM fn_GBL_ParseVarCharIDList(@IDList, ',') idlist WHERE idlist.ItemID=vo.VNUM COLLATE Latin1_General_CI_AI)
	ORDER BY IN_VIEW DESC, ORG_NAME_FULL

SET NOCOUNT OFF




GO



GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_l_EmailList] TO [cioc_login_role]
GO
