
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Agency_LowestVNUM_l]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 05-May-2016
	Action: TESTING REQUIRED
*/

SELECT a.AgencyCode, dbo.fn_VOL_LowestUnusedVNUM(a.AgencyCode) AS LowestVNUM,
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL
	FROM GBL_Agency a
	LEFT JOIN GBL_BaseTable bt
		ON a.AgencyNUMVOL=bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN STP_Member_ListForeignAgency memf
		ON a.AgencyID=memf.AgencyID AND memf.MemberID=@MemberID
WHERE RecordOwnerVOL = 1
	AND (
		a.MemberID=@MemberID
		OR memf.AgencyID IS NOT NULL
	)
ORDER BY a.AgencyCode

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_GBL_Agency_LowestVNUM_l] TO [cioc_login_role]
GO
