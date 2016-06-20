
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_AutoReport_DataMgmt] (
	@MemberID int,
	@PB_ID int
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
		DATENAME(mm, btd.CREATED_DATE) + ' ' + CAST(YEAR(btd.CREATED_DATE) AS varchar) AS TheMonth,
		'incDel=on&Ln=' + sl.Culture
			+ CASE WHEN @PB_ID IS NOT NULL THEN '&PBID=' + CAST(@PB_ID AS varchar) ELSE '' END
			+ '&CD1DateType=' + CAST(@FieldID AS varchar)
			+ '&CD1FirstDate=' + REPLACE(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(btd.CREATED_DATE)-1),CAST(btd.CREATED_DATE AS date)),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,btd.CREATED_DATE))-1),DATEADD(mm,1,CAST(btd.CREATED_DATE AS date))),126),' ','%20')
			+ '&SearchDisplay=on'
			AS Criteria
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
GROUP BY DATENAME(mm, btd.CREATED_DATE) + ' ' + CAST(YEAR(btd.CREATED_DATE) AS varchar), YEAR(btd.CREATED_DATE), MONTH(btd.CREATED_DATE), 
	CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(btd.CREATED_DATE)-1),CAST(btd.CREATED_DATE AS date)),126),
	CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,btd.CREATED_DATE))-1),DATEADD(mm,1,CAST(btd.CREATED_DATE AS date))),126),
	sl.Culture, sl.LanguageName
ORDER BY YEAR(btd.CREATED_DATE), MONTH(btd.CREATED_DATE), sl.LanguageName

SELECT @FieldID=FieldID FROM dbo.GBL_FieldOption WHERE FieldName='MODIFIED_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsModifiedLocal,
		COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsModifiedShared,
		DATENAME(mm, btd.MODIFIED_DATE) + ' ' + CAST(YEAR(btd.MODIFIED_DATE) AS varchar) AS TheMonth,
		'incDel=on&Ln=' + sl.Culture
			+ CASE WHEN @PB_ID IS NOT NULL THEN '&PBID=' + CAST(@PB_ID AS varchar) ELSE '' END
			+ '&CD1DateType=' + CAST(@FieldID AS varchar)
			+ '&CD1FirstDate=' + REPLACE(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(btd.MODIFIED_DATE)-1),CAST(btd.MODIFIED_DATE AS date)),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,btd.MODIFIED_DATE))-1),DATEADD(mm,1,CAST(btd.MODIFIED_DATE AS date))),126),' ','%20')
			+ '&SearchDisplay=on'
			AS Criteria
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
GROUP BY DATENAME(mm, btd.MODIFIED_DATE) + ' ' + CAST(YEAR(btd.MODIFIED_DATE) AS varchar), YEAR(btd.MODIFIED_DATE), MONTH(btd.MODIFIED_DATE),
	CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(btd.MODIFIED_DATE)-1),CAST(btd.MODIFIED_DATE AS date)),126),
	CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,btd.MODIFIED_DATE))-1),DATEADD(mm,1,CAST(btd.MODIFIED_DATE AS date))),126),
	sl.Culture, sl.LanguageName
ORDER BY YEAR(btd.MODIFIED_DATE), MONTH(btd.MODIFIED_DATE), sl.LanguageName

SELECT @FieldID=FieldID FROM dbo.GBL_FieldOption WHERE FieldName='TAX_MODIFIED_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS TaxRecordsModifiedLocal,
		COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS TaxRecordsModifiedShared,
		DATENAME(mm, cbt.TAX_MODIFIED_DATE) + ' ' + CAST(YEAR(cbt.TAX_MODIFIED_DATE) AS varchar) AS TheMonth,
		'incDel=on&Ln=' + sl.Culture
			+ CASE WHEN @PB_ID IS NOT NULL THEN '&PBID=' + CAST(@PB_ID AS varchar) ELSE '' END
			+ '&CD1DateType=' + CAST(@FieldID AS varchar)
			+ '&CD1FirstDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(cbt.TAX_MODIFIED_DATE)-1),CAST(cbt.TAX_MODIFIED_DATE AS date)),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,cbt.TAX_MODIFIED_DATE))-1),DATEADD(mm,1,CAST(cbt.TAX_MODIFIED_DATE AS date))),126),' ','%20')
			+ '&SearchDisplay=on'
			AS Criteria
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
GROUP BY DATENAME(mm, cbt.TAX_MODIFIED_DATE) + ' ' + CAST(YEAR(cbt.TAX_MODIFIED_DATE) AS varchar), YEAR(cbt.TAX_MODIFIED_DATE), MONTH(cbt.TAX_MODIFIED_DATE),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(cbt.TAX_MODIFIED_DATE)-1),CAST(cbt.TAX_MODIFIED_DATE AS date)),126),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,cbt.TAX_MODIFIED_DATE))-1),DATEADD(mm,1,CAST(cbt.TAX_MODIFIED_DATE AS date))),126),
	sl.Culture, sl.LanguageName
ORDER BY YEAR(cbt.TAX_MODIFIED_DATE), MONTH(cbt.TAX_MODIFIED_DATE), sl.LanguageName

SELECT @FieldID=FieldID FROM dbo.GBL_FieldOption WHERE FieldName='UPDATE_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsUpdatedLocal,
		COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsUpdatedShared,
		DATENAME(mm, UPDATE_DATE) + ' ' + CAST(YEAR(UPDATE_DATE) AS varchar) AS TheMonth,
		'incDel=on&Ln=' + sl.Culture
			+ CASE WHEN @PB_ID IS NOT NULL THEN '&PBID=' + CAST(@PB_ID AS varchar) ELSE '' END
			+ '&CD1DateType=' + CAST(@FieldID AS varchar)
			+ '&CD1FirstDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(UPDATE_DATE)-1),CAST(UPDATE_DATE AS date)),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,UPDATE_DATE))-1),DATEADD(mm,1,CAST(UPDATE_DATE AS date))),126),' ','%20')
			+ '&SearchDisplay=on'
			AS Criteria
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
GROUP BY DATENAME(mm, UPDATE_DATE) + ' ' + CAST(YEAR(UPDATE_DATE) AS varchar), YEAR(UPDATE_DATE), MONTH(UPDATE_DATE),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(UPDATE_DATE)-1),CAST(UPDATE_DATE AS date)),126),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,UPDATE_DATE))-1),DATEADD(mm,1,CAST(UPDATE_DATE AS date))),126),
	sl.Culture, sl.LanguageName
ORDER BY YEAR(UPDATE_DATE), MONTH(UPDATE_DATE), sl.LanguageName

SELECT @FieldID=FieldID FROM dbo.GBL_FieldOption WHERE FieldName='DELETION_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS RecordsDeletedLocal,
		COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS RecordsDeletedShared,
		DATENAME(mm, DELETION_DATE) + ' ' + CAST(YEAR(DELETION_DATE) AS varchar) AS TheMonth,
		'incDel=on&Ln=' + sl.Culture
			+ CASE WHEN @PB_ID IS NOT NULL THEN '&PBID=' + CAST(@PB_ID AS varchar) ELSE '' END
			+ '&CD1DateType=' + CAST(@FieldID AS varchar)
			+ '&CD1FirstDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(DELETION_DATE)-1),CAST(DELETION_DATE AS date)),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,DELETION_DATE))-1),DATEADD(mm,1,CAST(DELETION_DATE AS date))),126),' ','%20')
			+ '&SearchDisplay=on'
			AS Criteria
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
GROUP BY DATENAME(mm, DELETION_DATE) + ' ' + CAST(YEAR(DELETION_DATE) AS varchar), YEAR(DELETION_DATE), MONTH(DELETION_DATE),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(DELETION_DATE)-1),CAST(DELETION_DATE AS date)),126),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,DELETION_DATE))-1),DATEADD(mm,1,CAST(DELETION_DATE AS date))),126),
	sl.Culture, sl.LanguageName
ORDER BY YEAR(DELETION_DATE), MONTH(DELETION_DATE), sl.LanguageName

SELECT @FieldID=FieldID FROM dbo.GBL_FieldOption WHERE FieldName='SHARED_DATE'

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(*) AS SharedWithMe,
		DATENAME(mm, shp.CREATED_DATE) + ' ' + CAST(YEAR(shp.CREATED_DATE) AS varchar) AS TheMonth,
		'incDel=on&Ln=' + sl.Culture
			+ CASE WHEN @PB_ID IS NOT NULL THEN '&PBID=' + CAST(@PB_ID AS varchar) ELSE '' END
			+ '&CD1DateType=' + CAST(@FieldID AS varchar)
			+ '&CD1FirstDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(shp.CREATED_DATE)-1),CAST(shp.CREATED_DATE AS date)),126),' ','%20')
			+ '&CD1LastDate=' + REPLACE(CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,shp.CREATED_DATE))-1),DATEADD(mm,1,CAST(shp.CREATED_DATE AS date))),126),' ','%20')
			+ '&SearchDisplay=on'
			AS Criteria
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
GROUP BY DATENAME(mm, shp.CREATED_DATE) + ' ' + CAST(YEAR(shp.CREATED_DATE) AS varchar), YEAR(shp.CREATED_DATE), MONTH(shp.CREATED_DATE),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(shp.CREATED_DATE)-1),CAST(shp.CREATED_DATE AS date)),126),
	CONVERT(varchar(25),DATEADD(dd,-(DAY(DATEADD(mm,1,shp.CREATED_DATE))-1),DATEADD(mm,1,CAST(shp.CREATED_DATE AS date))),126),
	sl.Culture, sl.LanguageName
ORDER BY YEAR(shp.CREATED_DATE), MONTH(shp.CREATED_DATE), sl.LanguageName

SELECT sl.Culture,
		sl.LanguageName,
		COUNT(*) AS SharedByMe,
		DATENAME(mm, shp.CREATED_DATE) + ' ' + CAST(YEAR(shp.CREATED_DATE) AS varchar) AS TheMonth
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
GROUP BY DATENAME(mm, shp.CREATED_DATE) + ' ' + CAST(YEAR(shp.CREATED_DATE) AS varchar), YEAR(shp.CREATED_DATE), MONTH(shp.CREATED_DATE), sl.Culture, sl.LanguageName
ORDER BY YEAR(shp.CREATED_DATE), MONTH(shp.CREATED_DATE), sl.LanguageName

RETURN @Error

SET NOCOUNT OFF




GO




GRANT EXECUTE ON  [dbo].[sp_CIC_AutoReport_DataMgmt] TO [cioc_login_role]
GO
