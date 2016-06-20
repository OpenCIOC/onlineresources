SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Vacancy_l_History]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: CL
	Checked on: 01-May-2015
	Action: NO ACTION REQUIRED
*/

DECLARE @CanSeeHistory bit, @NUM varchar(8), @ServiceTitle nvarchar(100)

SELECT prn.ServiceTitle AS ServiceTitleNow, hst.*,
	dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM, ORG_LEVEL_1, ORG_LEVEL_2, ORG_LEVEL_3, ORG_LEVEL_4, ORG_LEVEL_5, LOCATION_NAME, SERVICE_NAME_LEVEL_1, SERVICE_NAME_LEVEL_2, DISPLAY_LOCATION_NAME, DISPLAY_ORG_NAME) AS OrgName
FROM CIC_BT_VUT_History hst
LEFT JOIN CIC_BT_VUT pr
	ON hst.BT_VUT_ID=pr.BT_VUT_ID
LEFT JOIN CIC_BT_VUT_Notes prn
	ON prn.BT_VUT_ID = pr.BT_VUT_ID AND prn.LangID=@@LANGID
LEFT JOIN GBL_BaseTable bt
	ON bt.NUM=pr.NUM
LEFT JOIN GBL_BaseTable_Description btd
	ON btd.NUM = bt.NUM  AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=bt.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE hst.MemberID=@MemberID
ORDER BY hst.MODIFIED_DATE DESC, hst.MODIFIED_BY, hst.BT_VUT_HIST_ID DESC


SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Vacancy_l_History] TO [cioc_login_role]
GO
