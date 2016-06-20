SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMMarkedDeleted_s]
	@ViewType int,
	@Agency [varchar](3),
	@IdList varchar(MAX)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberID int
		
SELECT	@MemberID=MemberID
FROM VOL_View
WHERE ViewType=@ViewType

-- View ID given ?
IF @ViewType IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ViewType = NULL
-- View exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ViewType = NULL
END

SET @Agency = LTRIM(RTRIM(@Agency))
IF @Agency = '' SET @Agency = NULL

DECLARE @LimitList TABLE (OPD_ID int)

INSERT INTO @LimitList
SELECT ItemID
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm

SELECT vo.VNUM, vod.OPD_ID, vod.LangID, vo.MemberID,
	vod.POSITION_TITLE,
	dbo.fn_GBL_DisplayFullOrgName(vo.NUM,vod.LangID) AS ORG_NAME_FULL,
	cioc_shared.dbo.fn_SHR_GBL_DateString(vod.DELETION_DATE) AS DELETION_DATE,
	dbo.fn_VOL_RecordInView(vo.VNUM,@ViewType,vod.LangID,0,GETDATE()) AS CAN_SEE, vo.RECORD_OWNER,
	sl.LanguageName, sl.Culture, sl.Active AS LangActive,
	(SELECT COUNT(*) FROM VOL_OP_Referral rf WHERE rf.VNUM=vo.VNUM) AS REFERRALS,
	(SELECT cioc_shared.dbo.fn_SHR_GBL_DateString(MAX(CREATED_DATE)) FROM VOL_OP_Referral rf WHERE rf.VNUM=vo.VNUM) AS LAST_REFERRAL,
	CASE
		WHEN vo.MemberID<>@MemberID THEN 'S'
		WHEN EXISTS(SELECT * FROM VOL_OP_Referral WHERE VNUM=vo.VNUM) THEN 'R'
		ELSE NULL
	END AS CAN_DELETE
	FROM VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM
	INNER JOIN STP_Language sl
		ON vod.LangID=sl.LangID
WHERE vod.DELETION_DATE IS NOT NULL
	AND (@Agency IS NULL OR vo.RECORD_OWNER = @Agency)
	AND (vo.MemberID=@MemberID OR EXISTS(SELECT * FROM VOL_OP_SharingProfile shp WHERE shp.VNUM=vo.VNUM AND shp.ShareMemberID_Cache=@MemberID))
	AND (
		NOT EXISTS(SELECT * FROM @LimitList)
		OR (
			EXISTS(SELECT * FROM @LimitList WHERE OPD_ID=vod.OPD_ID)
		)
	)
ORDER BY vod.DELETION_DATE

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMMarkedDeleted_s] TO [cioc_login_role]
GO
