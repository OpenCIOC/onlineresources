SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_SRCH_u]
	@VNUM varchar(10) = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

/* Update SRCH_Anywhere */
UPDATE vod
	SET	SRCH_Anywhere_U = 0,
		SRCH_Anywhere = vod.POSITION_TITLE + ' '
		+ ISNULL(btd.SRCH_Org,'') + ' '
		+ ISNULL((SELECT CMP_Name FROM GBL_Contact c WHERE c.VolContactType='CONTACT' AND c.VolVNUM=vod.VNUM AND c.LangID=vod.LangID),'') + ' '
		+ ISNULL(vod.LOCATION,'') + ' '
		+ ISNULL(vod.DUTIES,'') + ' '
		+ ISNULL(vod.BENEFITS,'') + ' '
		+ ISNULL(vod.CLIENTS,'') + ' '
		+ ISNULL(vod.ADDITIONAL_REQUIREMENTS,'') + ' '
		+ ISNULL(vod.SKILLS_NOTES,'') + ' '
		+ ISNULL(vod.CMP_Interests,'')
		+ ISNULL(dbo.fn_VOL_SRCH_EXTRA_TEXT(vo.VNUM,vod.LangID),'')
	FROM VOL_Opportunity_Description vod
	INNER JOIN VOL_Opportunity vo
		ON vod.VNUM=vo.VNUM
	INNER JOIN GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM = btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=vo.NUM ORDER BY CASE WHEN LangID=vod.LangID THEN 0 ELSE 1 END, LangID)
WHERE vod.SRCH_Anywhere_U <> 0 AND (@VNUM IS NULL OR vo.VNUM=@VNUM)

SET NOCOUNT OFF



GO


GRANT EXECUTE ON  [dbo].[sp_VOL_SRCH_u] TO [cioc_login_role]
GO
