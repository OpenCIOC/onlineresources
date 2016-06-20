
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_AutoReport_DataMgmt] (
	@MemberID int
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.1
	Checked by: KL
	Checked on: 01-Dec-2014
	Action:	NO ACTION REQUIRED
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

DECLARE	@StartDateRange	smalldatetime,
		@EndDateRange	smalldatetime,
		@Month2		smalldatetime,
		@Month3		smalldatetime

SET @EndDateRange = DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0)
SET @Month3 = DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0)
SET @Month2 = DATEADD(m, -2, @EndDateRange)
SET @StartDateRange = DATEADD(m, -3, @EndDateRange)

SELECT DATENAME(mm, @StartDateRange) + ' ' + DATENAME(yyyy, @StartDateRange) AS Month1, DATENAME(mm, @Month2) + ' ' + DATENAME(yyyy, @Month2) AS Month2, DATENAME(mm, @Month3) + ' ' + DATENAME(yyyy, @Month3) AS Month3

DECLARE @FieldID int

SELECT @FieldID=FieldID FROM dbo.VOL_FieldOption WHERE FieldName='CREATED_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsCreatedLocal,
		COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsCreatedShared,
		DATENAME(mm, vod.CREATED_DATE) + ' ' + CAST(YEAR(vod.CREATED_DATE) AS varchar) AS TheMonth,
		'incDel=on&Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar)
			+ '&CD1FirstDate=' + REPLACE(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(vod.CREATED_DATE)-1),CAST(vod.CREATED_DATE AS date)),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,vod.CREATED_DATE))-1),DATEADD(mm,1,CAST(vod.CREATED_DATE AS date))),126),' ','%20')
			+ '&SearchDisplay=on'
			AS Criteria
	FROM VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM
	INNER JOIN STP_Language sl
		ON vod.LangID=sl.LangID
	WHERE (
			vo.MemberID=@MemberID
			OR EXISTS(SELECT * FROM VOL_OP_SharingProfile shp WHERE vo.VNUM=shp.VNUM AND shp.ShareMemberID_Cache=@MemberID)
		)
		AND (
			vod.CREATED_DATE >= @StartDateRange AND vod.CREATED_DATE < @EndDateRange
		)
GROUP BY DATENAME(mm, vod.CREATED_DATE) + ' ' + CAST(YEAR(vod.CREATED_DATE) AS varchar), YEAR(vod.CREATED_DATE), MONTH(vod.CREATED_DATE),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(vod.CREATED_DATE)-1),CAST(vod.CREATED_DATE AS date)),126),
	CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,vod.CREATED_DATE))-1),DATEADD(mm,1,CAST(vod.CREATED_DATE AS date))),126),
	sl.Culture, sl.LanguageName
ORDER BY YEAR(vod.CREATED_DATE), MONTH(vod.CREATED_DATE), sl.LanguageName

SELECT @FieldID=FieldID FROM dbo.VOL_FieldOption WHERE FieldName='MODIFIED_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsModifiedLocal,
		COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsModifiedShared,
		DATENAME(mm, vod.MODIFIED_DATE) + ' ' + CAST(YEAR(vod.MODIFIED_DATE) AS varchar) AS TheMonth,
		'incDel=on&Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar)
			+ '&CD1FirstDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(vod.MODIFIED_DATE)-1),CAST(vod.MODIFIED_DATE AS date)),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,vod.MODIFIED_DATE))-1),DATEADD(mm,1,CAST(vod.MODIFIED_DATE AS date))),126),' ','%20')
			+ '&SearchDisplay=on'
			AS Criteria
	FROM VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM
	INNER JOIN STP_Language sl
		ON vod.LangID=sl.LangID
	WHERE (
			vo.MemberID=@MemberID
			OR EXISTS(SELECT * FROM VOL_OP_SharingProfile shp WHERE vo.VNUM=shp.VNUM AND shp.ShareMemberID_Cache=@MemberID)
		)
		AND (
			vod.MODIFIED_DATE >= @StartDateRange AND vod.MODIFIED_DATE < @EndDateRange
		)
GROUP BY DATENAME(mm, vod.MODIFIED_DATE) + ' ' + CAST(YEAR(vod.MODIFIED_DATE) AS varchar), YEAR(vod.MODIFIED_DATE), MONTH(vod.MODIFIED_DATE),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(vod.MODIFIED_DATE)-1),CAST(vod.MODIFIED_DATE AS date)),126),
	CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,vod.MODIFIED_DATE))-1),DATEADD(mm,1,CAST(vod.MODIFIED_DATE AS date))),126),
	sl.Culture, sl.LanguageName
ORDER BY YEAR(vod.MODIFIED_DATE), MONTH(vod.MODIFIED_DATE), sl.LanguageName

SELECT @FieldID=FieldID FROM dbo.VOL_FieldOption WHERE FieldName='UPDATE_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsUpdatedLocal,
		COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsUpdatedShared,
		DATENAME(mm, UPDATE_DATE) + ' ' + CAST(YEAR(UPDATE_DATE) AS varchar) AS TheMonth,
		'incDel=on&Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar)
			+ '&CD1FirstDate=' + REPLACE(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(vod.UPDATE_DATE)-1),CAST(vod.UPDATE_DATE AS date)),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,vod.UPDATE_DATE))-1),DATEADD(mm,1,CAST(vod.UPDATE_DATE AS date))),126),' ','%20')
			+ '&SearchDisplay=on'
			AS Criteria
	FROM VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM
	INNER JOIN STP_Language sl
		ON vod.LangID=sl.LangID
	WHERE (
			vo.MemberID=@MemberID
			OR EXISTS(SELECT * FROM VOL_OP_SharingProfile shp WHERE vo.VNUM=shp.VNUM AND shp.ShareMemberID_Cache=@MemberID)
		)
		AND (
			UPDATE_DATE >= @StartDateRange AND UPDATE_DATE < @EndDateRange
		)
GROUP BY DATENAME(mm, UPDATE_DATE) + ' ' + CAST(YEAR(UPDATE_DATE) AS varchar), YEAR(UPDATE_DATE), MONTH(UPDATE_DATE),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(vod.UPDATE_DATE)-1),CAST(vod.UPDATE_DATE AS date)),126),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,vod.UPDATE_DATE))-1),DATEADD(mm,1,CAST(vod.UPDATE_DATE AS date))),126),
	sl.Culture, sl.LanguageName
ORDER BY YEAR(UPDATE_DATE), MONTH(UPDATE_DATE), sl.LanguageName

SELECT @FieldID=FieldID FROM dbo.VOL_FieldOption WHERE FieldName='DELETION_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsDeletedLocal,
		COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsDeletedShared,
		DATENAME(mm, DELETION_DATE) + ' ' + CAST(YEAR(DELETION_DATE) AS varchar) AS TheMonth,
		'incDel=on&Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar)
			+ '&CD1FirstDate=' + REPLACE(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(vod.DELETION_DATE)-1),CAST(vod.DELETION_DATE AS date)),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,vod.DELETION_DATE))-1),DATEADD(mm,1,CAST(vod.DELETION_DATE AS date))),126),' ','%20')
			+ '&SearchDisplay=on'
			AS Criteria
	FROM VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM
	INNER JOIN STP_Language sl
		ON vod.LangID=sl.LangID
	WHERE (
			vo.MemberID=@MemberID
			OR EXISTS(SELECT * FROM VOL_OP_SharingProfile shp WHERE vo.VNUM=shp.VNUM AND shp.ShareMemberID_Cache=@MemberID)
		)
		AND (
			DELETION_DATE >= @StartDateRange AND DELETION_DATE < @EndDateRange
		)
GROUP BY DATENAME(mm, DELETION_DATE) + ' ' + CAST(YEAR(DELETION_DATE) AS varchar), YEAR(DELETION_DATE), MONTH(DELETION_DATE),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(vod.DELETION_DATE)-1),CAST(vod.DELETION_DATE AS date)),126),
	CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,vod.DELETION_DATE))-1),DATEADD(mm,1,CAST(vod.DELETION_DATE AS date))),126),
	sl.Culture, sl.LanguageName
ORDER BY YEAR(DELETION_DATE), MONTH(DELETION_DATE), sl.LanguageName

SELECT @FieldID=FieldID FROM dbo.VOL_FieldOption WHERE FieldName='DISPLAY_UNTIL'

SELECT	sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsExpiredLocal,
		COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsExpiredShared,
		DATENAME(mm, DISPLAY_UNTIL) + ' ' + CAST(YEAR(DISPLAY_UNTIL) AS varchar) AS TheMonth,
		'incDel=on&Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar)
			+ '&CD1FirstDate=' + REPLACE(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DISPLAY_UNTIL)-1),CAST(DISPLAY_UNTIL AS date)),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,DISPLAY_UNTIL))-1),DATEADD(mm,1,CAST(DISPLAY_UNTIL AS date))),126),' ','%20')
			+ '&SearchDisplay=on'
			AS Criteria
	FROM VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM
	INNER JOIN STP_Language sl
		ON vod.LangID=sl.LangID
	WHERE (
			vo.MemberID=@MemberID
			OR EXISTS(SELECT * FROM VOL_OP_SharingProfile shp WHERE vo.VNUM=shp.VNUM AND shp.ShareMemberID_Cache=@MemberID)
		)
		AND (
			DISPLAY_UNTIL >= @StartDateRange AND DISPLAY_UNTIL < @EndDateRange
		)
	GROUP BY DATENAME(mm, DISPLAY_UNTIL) + ' ' + CAST(YEAR(DISPLAY_UNTIL) AS varchar), YEAR(DISPLAY_UNTIL), MONTH(DISPLAY_UNTIL),
		CONVERT(varchar(25),DATEADD(dd,-(DAY(DISPLAY_UNTIL)-1),CAST(DISPLAY_UNTIL AS date)),126),
		CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,DISPLAY_UNTIL))-1),DATEADD(mm,1,CAST(DISPLAY_UNTIL AS date))),126),
	sl.Culture, sl.LanguageName
	ORDER BY YEAR(DISPLAY_UNTIL), MONTH(DISPLAY_UNTIL), sl.LanguageName

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(*) AS SharedWithMe,
		DATENAME(mm, shp.CREATED_DATE) + ' ' + CAST(YEAR(shp.CREATED_DATE) AS varchar) AS TheMonth
	FROM VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM
	INNER JOIN STP_Language sl
		ON vod.LangID=sl.LangID
	INNER JOIN VOL_OP_SharingProfile shp 
		ON vo.VNUM=shp.VNUM AND shp.ShareMemberID_Cache=@MemberID
	WHERE (
			shp.CREATED_DATE >= @StartDateRange	AND shp.CREATED_DATE < @EndDateRange OR @EndDateRange IS NULL
		)
GROUP BY DATENAME(mm, shp.CREATED_DATE) + ' ' + CAST(YEAR(shp.CREATED_DATE) AS varchar), YEAR(shp.CREATED_DATE), MONTH(shp.CREATED_DATE), sl.Culture, sl.LanguageName
ORDER BY YEAR(shp.CREATED_DATE), MONTH(shp.CREATED_DATE), sl.LanguageName

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(*) AS SharedByMe,
		DATENAME(mm, shp.CREATED_DATE) + ' ' + CAST(YEAR(shp.CREATED_DATE) AS varchar) AS TheMonth
	FROM VOL_Opportunity vo
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM
	INNER JOIN STP_Language sl
		ON vod.LangID=sl.LangID
	INNER JOIN VOL_OP_SharingProfile shp
		ON shp.VNUM = vo.VNUM
	INNER JOIN dbo.GBL_SharingProfile sh
		ON sh.ProfileID = shp.ProfileID AND sh.MemberID=@MemberID
	WHERE (
			shp.CREATED_DATE >= @StartDateRange	AND shp.CREATED_DATE < @EndDateRange OR @EndDateRange IS NULL
		)
GROUP BY DATENAME(mm, shp.CREATED_DATE) + ' ' + CAST(YEAR(shp.CREATED_DATE) AS varchar), YEAR(shp.CREATED_DATE), MONTH(shp.CREATED_DATE), sl.Culture, sl.LanguageName
ORDER BY YEAR(shp.CREATED_DATE), MONTH(shp.CREATED_DATE), sl.LanguageName

RETURN @Error

SET NOCOUNT OFF


GO


GRANT EXECUTE ON  [dbo].[sp_VOL_AutoReport_DataMgmt] TO [cioc_login_role]
GO
