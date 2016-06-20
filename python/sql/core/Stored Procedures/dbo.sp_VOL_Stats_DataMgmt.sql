
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Stats_DataMgmt] (
	@MemberID int,
	@StartDateRange smalldatetime,
	@EndDateRange smalldatetime
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

IF @EndDateRange IS NULL BEGIN
	SET @EndDateRange = GETDATE()
END

IF @StartDateRange IS NULL BEGIN
	SELECT @StartDateRange = MIN(StartDate)
	FROM (
		SELECT MIN(MODIFIED_DATE) AS StartDate FROM dbo.VOL_Opportunity_Description
		UNION SELECT MIN(CREATED_DATE) AS StartDate FROM dbo.VOL_Opportunity_Description
		UNION SELECT MIN(DELETION_DATE) AS StartDate FROM dbo.VOL_Opportunity_Description
		UNION SELECT MIN(UPDATE_DATE) AS StartDate FROM dbo.VOL_Opportunity_Description
	) x
END

DECLARE @TheMonth nvarchar(255), @CriteriaBase varchar(1000)
SELECT @TheMonth = cioc_shared.dbo.fn_SHR_GBL_DateString(@StartDateRange) + ' - ' + cioc_shared.dbo.fn_SHR_GBL_DateString(@EndDateRange)

SET @CriteriaBase= 'incDel=on'
			+ '&CD1FirstDate=' + REPLACE(CONVERT(VARCHAR(25), CAST(@StartDateRange AS date),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(VARCHAR(25), CAST(@EndDateRange AS date),126),' ','%20')
			+ '&SearchDisplay=on'


SELECT @TheMonth AS Month1

DECLARE @FieldID int

SELECT @FieldID=FieldID FROM dbo.VOL_FieldOption WHERE FieldName='CREATED_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsCreatedLocal,
		COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsCreatedShared,
		@TheMonth AS TheMonth,
		'Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar) + '&' + @CriteriaBase AS Criteria
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
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

SELECT @FieldID=FieldID FROM dbo.VOL_FieldOption WHERE FieldName='MODIFIED_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsModifiedLocal,
		COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsModifiedShared,
		@TheMonth AS TheMonth,
		'Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar) + '&' + @CriteriaBase AS Criteria
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
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

SELECT @FieldID=FieldID FROM dbo.VOL_FieldOption WHERE FieldName='UPDATE_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsUpdatedLocal,
		COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsUpdatedShared,
		@TheMonth AS TheMonth,
		'Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar) + '&' + @CriteriaBase AS Criteria
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
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

SELECT @FieldID=FieldID FROM dbo.VOL_FieldOption WHERE FieldName='DELETION_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsDeletedLocal,
		COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsDeletedShared,
		@TheMonth AS TheMonth,
		'Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar) + '&' + @CriteriaBase AS Criteria
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
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

SELECT @FieldID=FieldID FROM dbo.VOL_FieldOption WHERE FieldName='DISPLAY_UNTIL'

SELECT	sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsExpiredLocal,
		COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsExpiredShared,
		@TheMonth AS TheMonth,
		'Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar) + '&' + @CriteriaBase AS Criteria
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
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(*) AS SharedWithMe,
		@TheMonth AS TheMonth
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
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(*) AS SharedByMe,
		@TheMonth AS TheMonth
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
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Stats_DataMgmt] TO [cioc_login_role]
GO
