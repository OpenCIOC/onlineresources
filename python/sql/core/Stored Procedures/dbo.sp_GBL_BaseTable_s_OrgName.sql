SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_s_OrgName]
	@MemberID int,
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 02-Oct-2013
	Action: NO ACTION REQUIRED
	Notes: Used for creating / suggesting Volunteer Opportunity
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

SELECT dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		CAST(CASE WHEN bt.MemberID=@MemberID THEN 1
				WHEN EXISTS(SELECT * FROM GBL_BT_SharingProfile WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID) THEN 1
				ELSE 0
			END AS bit) AS MEMBER_CAN_USE
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE bt.NUM=@NUM

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_s_OrgName] TO [cioc_login_role]
GO
