
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Stats_DataMgmt] (
	@MemberID int,
	@StartDateRange smalldatetime,
	@EndDateRange smalldatetime,
	@PB_ID int
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.1
	Checked by: KL
	Checked on: 02-Dec-2014
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
	SET @EndDateRange = CONVERT(VARCHAR(25), CAST(DATEADD(dd,1,GETDATE()) AS date),126)
END

IF @StartDateRange IS NULL BEGIN
	SELECT @StartDateRange = MIN(StartDate)
	FROM (
		SELECT MIN(MODIFIED_DATE) AS StartDate FROM dbo.GBL_BaseTable_Description WHERE MODIFIED_DATE IS NOT NULL
		UNION SELECT MIN(CREATED_DATE) AS StartDate FROM dbo.GBL_BaseTable_Description WHERE CREATED_DATE IS NOT NULL
		UNION SELECT MIN(DELETION_DATE) AS StartDate FROM dbo.GBL_BaseTable_Description WHERE DELETION_DATE IS NOT NULL
		UNION SELECT MIN(UPDATE_DATE) AS StartDate FROM dbo.GBL_BaseTable_Description WHERE UPDATE_DATE IS NOT NULL
	) x
END

DECLARE @TheMonth nvarchar(255), @CriteriaBase varchar(1000)
SELECT @TheMonth = cioc_shared.dbo.fn_SHR_GBL_DateString(@StartDateRange) + ' - ' + cioc_shared.dbo.fn_SHR_GBL_DateString(@EndDateRange)

SET @CriteriaBase= 'incDel=on'
			+ CASE WHEN @PB_ID IS NOT NULL THEN '&PBID=' + CAST(@PB_ID AS varchar) ELSE '' END
			+ '&CD1FirstDate=' + REPLACE(CONVERT(VARCHAR(25), CAST(@StartDateRange AS date),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(VARCHAR(25), CAST(@EndDateRange AS date),126),' ','%20')
			+ '&SearchDisplay=on'

SELECT @TheMonth AS Month1

SELECT PubCode, Name
FROM dbo.CIC_Publication pb
LEFT JOIN dbo.CIC_Publication_Name pbn
	ON pbn.PB_ID = pb.PB_ID AND LangID=@@LANGID
WHERE pb.PB_ID=@PB_ID

DECLARE @FieldID int

SELECT @FieldID=FieldID FROM dbo.GBL_FieldOption WHERE FieldName='CREATED_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsCreatedLocal,
		COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsCreatedShared,
		@TheMonth AS TheMonth,
		'Ln=' + sl.Culture + '&CD1DateType=' + CAST(@FieldID AS varchar) + '&' + @CriteriaBase AS Criteria
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
	INNER JOIN STP_Language sl
		ON btd.LangID=sl.LangID
	WHERE (
			bt.MemberID=@MemberID
			OR EXISTS(SELECT * FROM GBL_BT_SharingProfile shp WHERE bt.NUM=shp.NUM AND shp.ShareMemberID_Cache=@MemberID)
		)
		AND (
			btd.CREATED_DATE >= @StartDateRange AND btd.CREATED_DATE < @EndDateRange
		)
		AND (
			@PB_ID IS NULL
			OR EXISTS(SELECT * FROM dbo.CIC_BT_PB pr WHERE pr.NUM=bt.NUM AND PB_ID=@PB_ID)
		)
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

SELECT @FieldID=FieldID FROM dbo.GBL_FieldOption WHERE FieldName='MODIFIED_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsModifiedLocal,
		COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsModifiedShared,
		@TheMonth AS TheMonth,
		'Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar) + '&' + @CriteriaBase AS Criteria
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
	INNER JOIN STP_Language sl
		ON btd.LangID=sl.LangID
	WHERE (
			bt.MemberID=@MemberID
			OR EXISTS(SELECT * FROM GBL_BT_SharingProfile shp WHERE bt.NUM=shp.NUM AND shp.ShareMemberID_Cache=@MemberID)
		)
		AND (
			btd.MODIFIED_DATE >= @StartDateRange AND btd.MODIFIED_DATE < @EndDateRange
		)
		AND (
			@PB_ID IS NULL
			OR EXISTS(SELECT * FROM dbo.CIC_BT_PB pr WHERE pr.NUM=bt.NUM AND PB_ID=@PB_ID)
		)
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

SELECT @FieldID=FieldID FROM dbo.GBL_FieldOption WHERE FieldName='TAX_MODIFIED_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS TaxRecordsModifiedLocal,
		COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS TaxRecordsModifiedShared,
		@TheMonth AS TheMonth,
		'Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar) + '&' + @CriteriaBase AS Criteria
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
	INNER JOIN STP_Language sl
		ON btd.LangID=sl.LangID
	INNER JOIN CIC_BaseTable cbt
		ON bt.NUM=cbt.NUM
	WHERE (
			bt.MemberID=@MemberID
			OR EXISTS(SELECT * FROM GBL_BT_SharingProfile shp WHERE bt.NUM=shp.NUM AND shp.ShareMemberID_Cache=@MemberID)
		)
		AND (
			cbt.TAX_MODIFIED_DATE >= @StartDateRange AND cbt.TAX_MODIFIED_DATE < @EndDateRange
		)
		AND (
			@PB_ID IS NULL
			OR EXISTS(SELECT * FROM dbo.CIC_BT_PB pr WHERE pr.NUM=bt.NUM AND PB_ID=@PB_ID)
		)
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

SELECT @FieldID=FieldID FROM dbo.GBL_FieldOption WHERE FieldName='UPDATE_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsUpdatedLocal,
		COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsUpdatedShared,
		@TheMonth AS TheMonth,
		'Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar) + '&' + @CriteriaBase AS Criteria
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
	INNER JOIN STP_Language sl
		ON btd.LangID=sl.LangID
	WHERE (
			bt.MemberID=@MemberID
			OR EXISTS(SELECT * FROM GBL_BT_SharingProfile shp WHERE bt.NUM=shp.NUM AND shp.ShareMemberID_Cache=@MemberID)
		)
		AND (
			UPDATE_DATE >= @StartDateRange AND UPDATE_DATE < @EndDateRange
		)
		AND (
			@PB_ID IS NULL
			OR EXISTS(SELECT * FROM dbo.CIC_BT_PB pr WHERE pr.NUM=bt.NUM AND PB_ID=@PB_ID)
		)
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

SELECT @FieldID=FieldID FROM dbo.GBL_FieldOption WHERE FieldName='DELETION_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsDeletedLocal,
		COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsDeletedShared,
		@TheMonth AS TheMonth,
		'Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar) + '&' + @CriteriaBase AS Criteria
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
	INNER JOIN STP_Language sl
		ON btd.LangID=sl.LangID
	WHERE (
			bt.MemberID=@MemberID
			OR EXISTS(SELECT * FROM GBL_BT_SharingProfile shp WHERE bt.NUM=shp.NUM AND shp.ShareMemberID_Cache=@MemberID)
		)
		AND (
			DELETION_DATE >= @StartDateRange AND DELETION_DATE < @EndDateRange
		)
		AND (
			@PB_ID IS NULL
			OR EXISTS(SELECT * FROM dbo.CIC_BT_PB pr WHERE pr.NUM=bt.NUM AND PB_ID=@PB_ID)
		)
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

SELECT @FieldID=FieldID FROM dbo.GBL_FieldOption WHERE FieldName='SHARED_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(*) AS SharedWithMe,
		@TheMonth AS TheMonth,
		'Ln=' + sl.Culture
			+ '&CD1DateType=' + CAST(@FieldID AS varchar) + '&' + @CriteriaBase AS Criteria
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
	INNER JOIN STP_Language sl
		ON btd.LangID=sl.LangID
	INNER JOIN GBL_BT_SharingProfile shp 
		ON bt.NUM=shp.NUM AND shp.ShareMemberID_Cache=@MemberID
	WHERE (
			shp.CREATED_DATE >= @StartDateRange	AND shp.CREATED_DATE < @EndDateRange OR @EndDateRange IS NULL
		)
		AND (
			@PB_ID IS NULL
			OR EXISTS(SELECT * FROM dbo.CIC_BT_PB pr WHERE pr.NUM=bt.NUM AND PB_ID=@PB_ID)
		)
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(*) AS SharedByMe,
		@TheMonth AS TheMonth
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
	INNER JOIN STP_Language sl
		ON btd.LangID=sl.LangID
	INNER JOIN GBL_BT_SharingProfile shp
		ON shp.NUM = bt.NUM
	INNER JOIN dbo.GBL_SharingProfile sh
		ON sh.ProfileID = shp.ProfileID AND sh.MemberID=@MemberID
	WHERE (
			shp.CREATED_DATE >= @StartDateRange	AND shp.CREATED_DATE < @EndDateRange OR @EndDateRange IS NULL
		)
		AND (
			@PB_ID IS NULL
			OR EXISTS(SELECT * FROM dbo.CIC_BT_PB pr WHERE pr.NUM=bt.NUM AND PB_ID=@PB_ID)
		)
GROUP BY sl.Culture, sl.LanguageName, sl.LangID
ORDER BY sl.LangID

RETURN @Error

SET NOCOUNT OFF





GO


GRANT EXECUTE ON  [dbo].[sp_CIC_Stats_DataMgmt] TO [cioc_login_role]
GO
