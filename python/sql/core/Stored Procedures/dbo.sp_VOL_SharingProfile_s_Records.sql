SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_SharingProfile_s_Records]
	@MemberID [int],
	@ProfileID [int],
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 06-Oct-2013
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@SharingProfileObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SharingProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Sharing Profile')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID AND Domain=2) BEGIN
	SET @Error = 3 -- No Such Record
-- Profile belongs to member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE (MemberID=@MemberID or ShareMemberID=@MemberID) AND ProfileID=@ProfileID) BEGIN
	SET @Error = 8 -- Security Failure
END 
SELECT	vo.VNUM, vod.LangID, vo.MemberID,
		dbo.fn_VOL_RecordInView(vo.VNUM,@ViewType,vod.LangID,0,GETDATE()) AS CAN_SEE,
		vod.POSITION_TITLE,
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		shpr.RevokedDate
	FROM VOL_Opportunity vo
	INNER JOIN VOL_OP_SharingProfile shp 
		ON shp.VNUM=vo.VNUM AND shp.ProfileID=@ProfileID
	LEFT JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE VNUM=vod.VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	LEFT JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN STP_Language sl
		ON vod.LangID=sl.LangID
	LEFT JOIN VOL_OP_SharingProfile_Revoked shpr
		ON shp.OP_ShareProfile_ID = shpr.OP_ShareProfile_ID
WHERE shp.ProfileID=@ProfileID AND (shpr.RevokedDate IS NULL OR shpr.RevokedDate > GETDATE())
ORDER BY ISNULL(btd.SORT_AS,btd.ORG_LEVEL_1), btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5,
		STUFF(
			CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('AGENCY') WHERE pr.NUM=btd.NUM)
				THEN NULL
				ELSE COALESCE(', ' + btd.LOCATION_NAME,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
					COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')
				 END,
			1, 2, ''
		),
		vod.POSITION_TITLE,
		vod.VNUM

RETURN @Error

SET NOCOUNT OFF










GO
GRANT EXECUTE ON  [dbo].[sp_VOL_SharingProfile_s_Records] TO [cioc_login_role]
GO
