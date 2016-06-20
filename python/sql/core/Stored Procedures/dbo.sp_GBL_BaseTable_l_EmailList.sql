
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_l_EmailList]
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
	Checked on: 15-Jul-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE @DefaultView int
SELECT @DefaultView = DefaultViewCIC FROM STP_Member WHERE MemberID=@MemberID

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END ELSE IF @TargetView IS NOT NULL AND @TargetView <> @DefaultView AND NOT EXISTS(SELECT * FROM CIC_View vw INNER JOIN CIC_View_Recurse vr ON vr.CanSee = vw.ViewType WHERE vr.ViewType=@DefaultView AND vr.CanSee=@TargetView) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT bt.NUM, dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
	dbo.fn_CIC_RecordInView(bt.NUM, ISNULL(@TargetView, @DefaultView), @@LANGID, @NoDeleted, GETDATE()) AS IN_VIEW
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE @Error = 0 AND EXISTS(SELECT * FROM fn_GBL_ParseVarCharIDList(@IDList, ',') idlist WHERE idlist.ItemID=bt.NUM COLLATE Latin1_General_CI_AI)
	ORDER BY IN_VIEW DESC, ORG_NAME_FULL

SET NOCOUNT OFF




GO



GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_l_EmailList] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_l_EmailList] TO [cioc_login_role]
GO
