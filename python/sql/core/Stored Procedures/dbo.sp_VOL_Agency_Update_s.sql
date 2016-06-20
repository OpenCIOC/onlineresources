SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Agency_Update_s]
	@AgencyCode char(3)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 02-Oct-2013
	Action: NO ACTION REQUIRED
*/

SELECT dbo.fn_GBL_DisplayFullOrgName_Agency_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2) AS ORG_NAME_FULL,
		btd.FAX, 
		ISNULL(a.UpdateEmailVOL, btd.E_MAIL) AS UPDATE_EMAIL, 
		ISNULL(a.UpdatePhoneVOL, btd.OFFICE_PHONE) AS UPDATE_PHONE,
		CMP_SiteAddress AS SITE_ADDRESS,
		CMP_MailAddress AS MAIL_ADDRESS
	FROM GBL_Agency a
	LEFT JOIN GBL_BaseTable bt
		ON a.AgencyNUMVOL = bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE a.AgencyCode=@AgencyCode

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Agency_Update_s] TO [cioc_login_role]
GO
