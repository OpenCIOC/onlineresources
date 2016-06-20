
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Agency_lf]
	@MemberID [int],
	@ListForeignAgency [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 02-Oct-2013
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT a.AgencyID, a.AgencyCode, a.MemberID,
		dbo.fn_GBL_DisplayFullOrgName_Agency_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2) AS ORG_NAME_FULL
	FROM GBL_Agency a
	LEFT JOIN GBL_BaseTable bt
		ON a.AgencyNUMVOL = bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN STP_Member_ListForeignAgency memf
		ON a.AgencyID=memf.AgencyID AND memf.MemberID=@MemberID
WHERE a.RecordOwnerVOL=1 AND (a.MemberID=@MemberID OR (@ListForeignAgency=1 AND memf.AgencyID IS NOT NULL))
ORDER BY a.AgencyCode

RETURN @Error

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Agency_lf] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Agency_lf] TO [cioc_vol_search_role]
GO
