SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_Notify]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked by: KL
	Checked on: 02-May-2018
	Action:	CHECK THAT THIS ALLOWS SHARED RECORDS
*/

DECLARE @LastVolProfileEmailDate smalldatetime

DECLARE @TodayAtMidnight smalldatetime
SET @TodayAtMidnight = CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, GETDATE())))

DECLARE @MinLastDate DATE, @MinExpDate DATE
SET @MinLastDate = DATEADD(d,-14,GETDATE())
SET @MinExpDate = DATEADD(d,5,GETDATE())

SELECT @LastVolProfileEmailDate=ISNULL(LastVolProfileEmailDate,@MinLastDate) FROM STP_Member WHERE MemberID=@MemberID
IF (@LastVolProfileEmailDate < @MinLastDate OR @LastVolProfileEmailDate IS NULL) SET @LastVolProfileEmailDate = @MinLastDate

DECLARE @Opportunities TABLE (
	VNUM varchar(10),
	MemberID int,
	AccessURL nvarchar(500),
	SCH_M_Morning bit,
	SCH_M_Afternoon bit,
	SCH_M_Evening bit,
	SCH_TU_Morning bit,
	SCH_TU_Afternoon bit,
	SCH_TU_Evening bit,
	SCH_W_Morning bit,
	SCH_W_Afternoon bit,
	SCH_W_Evening bit,
	SCH_TH_Morning bit,
	SCH_TH_Afternoon bit,
	SCH_TH_Evening bit,
	SCH_F_Morning bit,
	SCH_F_Afternoon bit,
	SCH_F_Evening bit,
	SCH_ST_Morning bit,
	SCH_ST_Afternoon bit,
	SCH_ST_Evening bit,
	SCH_SN_Morning bit,
	SCH_SN_Afternoon bit,
	SCH_SN_Evening bit,
	MIN_AGE decimal(5,2),
	MAX_AGE decimal(5,2),
	COMMUNITIES nvarchar(MAX),
	INTERESTS nvarchar(MAX),
	OP_NAME xml,
	ORG_NAME xml,
	ViewInfo xml
)

INSERT INTO @Opportunities
SELECT 	vo.VNUM,
		vo.MemberID,
		NULL AS AccessURL,
		SCH_M_Morning, SCH_M_Afternoon, SCH_M_Evening,
		SCH_TU_Morning, SCH_TU_Afternoon, SCH_TU_Evening,
		SCH_W_Morning, SCH_W_Afternoon, SCH_W_Evening,
		SCH_TH_Morning, SCH_TH_Afternoon, SCH_TH_Evening,
		SCH_F_Morning, SCH_F_Afternoon, SCH_F_Evening,
		SCH_ST_Morning, SCH_ST_Afternoon, SCH_ST_Evening,
		SCH_SN_Morning, SCH_SN_Afternoon, SCH_SN_Evening,
		MIN_AGE,
		MAX_AGE,
		dbo.fn_VOL_VNUMToCommSrchList(vo.VNUM) AS COMMUNITIES,
		dbo.fn_VOL_VNUMToInterestSrchList(vo.VNUM) AS INTERESTS,
		(SELECT vod.POSITION_TITLE AS [@POSITION_TITLE], l.Culture AS [@Culture],
			CASE WHEN (
				CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, vod.CREATED_DATE))) >= @LastVolProfileEmailDate
				AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, vod.CREATED_DATE))) < @TodayAtMidnight
				) THEN 1 ELSE '' END AS [@NEWLY_CREATED],
			CASE WHEN vod.UPDATE_DATE >= @LastVolProfileEmailDate AND vod.UPDATE_DATE < @TodayAtMidnight THEN 1 ELSE '' END AS [@CHANGED]
			
			FROM VOL_Opportunity_Description vod
			INNER JOIN STP_Language l
				ON vod.LangID=l.LangID
			WHERE vod.VNUM=vo.VNUM
			FOR XML PATH('DESC'), ROOT('DESCS'), TYPE) AS OP_NAME,
		(SELECT btd.ORG_LEVEL_1 AS [@ORG_LEVEL_1], 
				btd.ORG_LEVEL_2 AS [@ORG_LEVEL_2], 
				btd.ORG_LEVEL_3 AS [@ORG_LEVEL_3], 
				btd.ORG_LEVEL_4 AS [@ORG_LEVEL_4], 
				btd.ORG_LEVEL_5 AS [@ORG_LEVEL_5], 
				l.Culture AS [@Culture] 
			FROM GBL_BaseTable_Description btd
			INNER JOIN STP_Language l
				ON btd.LangID=l.LangID
			WHERE btd.NUM=vo.NUM
			FOR XML PATH('DESC'), ROOT('DESCS'), TYPE) AS ORG_NAME,
		(SELECT CASE WHEN vw.ViewType=DefaultViewVOL OR DomainName IS NOT NULL THEN NULL ELSE vw.ViewType END AS [@ViewType],
			ISNULL(DomainName, BaseURLVOL) + ISNULL(PathToStart,'') COLLATE Latin1_General_100_CI_AI AS [@AccessURL],
			l.Culture AS [@Culture]
			FROM VOL_View vw
			INNER JOIN VOL_View_Description vwd
				ON vwd.ViewType=vw.ViewType
			INNER JOIN STP_Language l
				ON vwd.LangID=l.LangID AND EXISTS(SELECT * FROM VOL_Opportunity_Description WHERE vwd.LangID=LangID)
			LEFT JOIN (SELECT * FROM GBL_View_DomainMap WHERE SecondaryName = 0) mp
				ON vw.ViewType = mp.VOLViewType
			WHERE vw.UseProfilesView=1
				AND (EXISTS(SELECT * FROM VOL_View_Recurse vr WHERE vr.ViewType=DefaultViewVOL AND vr.CanSee=vw.ViewType)
				OR vw.ViewType=DefaultViewVOL)
				AND dbo.fn_VOL_RecordInView(vo.VNUM,vwd.ViewType,vwd.LangID,0,GETDATE())=1
			ORDER BY CASE WHEN vw.ViewType=DefaultViewVOL THEN 0 ELSE 1 END
		FOR XML PATH('DESC'),ROOT('DESCS'),TYPE)AS ViewInfo
	FROM VOL_Opportunity vo
	INNER JOIN GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	INNER JOIN STP_Member mem
		ON vo.MemberID=mem.MemberID
WHERE vo.MemberID=@MemberID
	AND (vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL >= @MinExpDate)
	AND EXISTS(SELECT * FROM dbo.VOL_Opportunity_Description vod WHERE vod.VNUM=vo.VNUM AND (vod.DELETION_DATE IS NULL OR vod.DELETION_DATE >= @MinExpDate))
	AND dbo.fn_VOL_VNUMToCommSrchList(vo.VNUM) IS NOT NULL
	AND EXISTS(SELECT * FROM VOL_Opportunity_Description vod WHERE vod.VNUM=vo.VNUM AND (
			(
			CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, vod.CREATED_DATE))) >= @LastVolProfileEmailDate
			AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, vod.CREATED_DATE))) < @TodayAtMidnight
			)
			OR (
			vod.UPDATE_DATE >= @LastVolProfileEmailDate
			AND vod.UPDATE_DATE < @TodayAtMidnight
			)
		)
	)
ORDER BY CASE WHEN EXISTS(SELECT * FROM VOL_Opportunity_Description vod WHERE vod.VNUM=vo.VNUM AND
			CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, vod.CREATED_DATE))) >= @LastVolProfileEmailDate
			AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, vod.CREATED_DATE))) < @TodayAtMidnight
			) THEN 1 ELSE 0 END DESC, (SELECT MAX(vod.UPDATE_DATE) FROM VOL_Opportunity_Description vod WHERE vod.VNUM=vo.VNUM)


DELETE FROM @Opportunities
WHERE ViewInfo IS NULL

SELECT * FROM @Opportunities

SELECT MemberID, ProfileID, FirstName, LastName, Email, NotifyUpdated,
		SCH_M_Morning, SCH_M_Afternoon, SCH_M_Evening,
		SCH_TU_Morning, SCH_TU_Afternoon, SCH_TU_Evening,
		SCH_W_Morning, SCH_W_Afternoon, SCH_W_Evening,
		SCH_TH_Morning, SCH_TH_Afternoon, SCH_TH_Evening,
		SCH_F_Morning, SCH_F_Afternoon, SCH_F_Evening,
		SCH_ST_Morning, SCH_ST_Afternoon, SCH_ST_Evening,
		SCH_SN_Morning, SCH_SN_Afternoon, SCH_SN_Evening,
		CAST(DATEDIFF(mm, BirthDate, GETDATE())/12.0 AS decimal(5,2)) AS AGE,
		dbo.fn_VOL_ProfileIDToCommSrchList(ProfileID) AS COMMUNITIES,
		dbo.fn_VOL_ProfileIDToInterestSrchList(ProfileID) AS INTERESTS,
		(SELECT Culture FROM STP_Language WHERE vp.LangID=LangID) AS Culture
	FROM VOL_Profile vp
WHERE vp.MemberID=@MemberID
	AND Verified=1
	AND Active=1
	AND Blocked=0
	AND (NotifyNew=1 OR NotifyUpdated=1)
	AND EXISTS(SELECT * FROM @Opportunities)

SELECT BaseURLVOL AS BaseURL,
		DefaultEmailVOL,
		DefaultEmailNameVOL,
		DefaultEmailVOLProfile
FROM STP_Member WHERE MemberID=@MemberID

SET NOCOUNT OFF








GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_Notify] TO [cioc_maintenance_role]
GO
