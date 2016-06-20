SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMMarkedDeleted_s]
	@ViewType int,
	@Agency [varchar](3),
	@IdList varchar(MAX)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 25-Apr-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberID int
		
SELECT	@MemberID=MemberID
FROM CIC_View
WHERE ViewType=@ViewType

-- View ID given ?
IF @ViewType IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ViewType = NULL
-- View exists ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ViewType = NULL
END

SET @Agency = LTRIM(RTRIM(@Agency))
IF @Agency = '' SET @Agency = NULL

DECLARE @LimitList TABLE (BTD_ID int)

INSERT INTO @LimitList
SELECT ItemID
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm

SELECT	bt.NUM, btd.BTD_ID, btd.LangID, bt.MemberID,
		dbo.fn_CIC_RecordInView(bt.NUM,@ViewType,btd.LangID,0,GETDATE()) AS CAN_SEE, bt.RECORD_OWNER,
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		cioc_shared.dbo.fn_SHR_GBL_DateString(btd.DELETION_DATE) AS DELETION_DATE,
		sl.LanguageName, sl.Culture, sl.Active AS LangActive,
		(SELECT COUNT(*) FROM VOL_Opportunity vo WHERE vo.NUM=btd.NUM) AS OPPORTUNITIES,
		CASE
			WHEN bt.MemberID<>@MemberID THEN 'S'
			WHEN EXISTS(SELECT * FROM VOL_Member vm WHERE vm.NUM=bt.NUM)
				AND NOT EXISTS(SELECT * FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=bt.NUM AND btd2.LangID<>btd.LangID) THEN 'M'
			WHEN EXISTS(SELECT * FROM VOL_Opportunity vo WHERE vo.NUM=bt.NUM)
				AND NOT EXISTS(SELECT * FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=bt.NUM AND btd2.LangID<>btd.LangID) THEN 'V'
			WHEN EXISTS(SELECT * FROM GBL_Agency a WHERE a.AgencyNUMCIC=bt.NUM OR a.AgencyNUMVOL=bt.NUM)
				AND NOT EXISTS(SELECT * FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=bt.NUM AND btd2.LangID<>btd.LangID) THEN 'A'
			WHEN EXISTS(SELECT * FROM GBL_BaseTable bt2 WHERE bt2.ORG_NUM=bt.NUM)
				AND NOT EXISTS(SELECT * FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=bt.NUM AND btd2.LangID<>btd.LangID) THEN 'P'
			WHEN EXISTS(SELECT * FROM GBL_BT_LOCATION_SERVICE btls WHERE btls.LOCATION_NUM=bt.NUM)
				AND NOT EXISTS(SELECT * FROM GBL_BaseTable_Description btd2 WHERE btd2.NUM=bt.NUM AND btd2.LangID<>btd.LangID) THEN 'L'
			ELSE NULL
		END AS CAN_DELETE
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
	INNER JOIN STP_Language sl
		ON btd.LangID=sl.LangID
WHERE btd.DELETION_DATE IS NOT NULL
	AND (@Agency IS NULL OR bt.RECORD_OWNER=@Agency)
	AND (bt.MemberID=@MemberID OR EXISTS(SELECT * FROM GBL_BT_SharingProfile shp WHERE shp.NUM=bt.NUM AND shp.ShareMemberID_Cache=@MemberID))
	AND (
		NOT EXISTS(SELECT * FROM @LimitList)
		OR (
			EXISTS(SELECT * FROM @LimitList WHERE BTD_ID=btd.BTD_ID)
		)
	)
ORDER BY btd.DELETION_DATE, ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
		STUFF(
			CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)
				THEN NULL
				ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')
				 END,
			1, 2, ''
		)

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMMarkedDeleted_s] TO [cioc_login_role]
GO
