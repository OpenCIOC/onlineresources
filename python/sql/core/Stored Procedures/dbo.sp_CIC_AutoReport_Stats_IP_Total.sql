
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_AutoReport_Stats_IP_Total] (
	@MemberID int,
	@PB_ID int
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: KL
	Checked on: 16-Apr-2015
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
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

SELECT DATENAME(mm, st.AccessDate) + ' ' + CAST(YEAR(st.AccessDate) AS varchar) AS TheMonth,
	COUNT(DISTINCT IpAddress) AS UniqueIPs
	FROM CIC_Stats_RSN st
	INNER JOIN GBL_BaseTable bt 
		ON st.RSN=bt.RSN
	WHERE st.MemberID=@MemberID
		AND (
			AccessDate >= @StartDateRange AND AccessDate < @EndDateRange
		)
		AND (
			@PB_ID IS NULL
			OR EXISTS(SELECT * FROM dbo.CIC_BT_PB pr WHERE pr.NUM=bt.NUM AND PB_ID=@PB_ID)
		)
	GROUP BY YEAR(AccessDate), MONTH(AccessDate), DATENAME(mm, AccessDate)
	ORDER BY YEAR(st.AccessDate), MONTH(AccessDate)
RETURN @Error

SET NOCOUNT OFF

GO

GRANT EXECUTE ON  [dbo].[sp_CIC_AutoReport_Stats_IP_Total] TO [cioc_login_role]
GO
