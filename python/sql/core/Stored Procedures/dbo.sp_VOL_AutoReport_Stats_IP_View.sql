
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_AutoReport_Stats_IP_View] (
	@MemberID int
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

SELECT DATENAME(mm, st.AccessDate) + ' ' + CAST(YEAR(st.AccessDate) AS varchar) AS TheMonth,
	ISNULL(ViewName,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown')) AS ViewName,
	COUNT(DISTINCT IpAddress) AS UniqueIPs
	FROM VOL_Stats_OPID st
	LEFT JOIN VOL_View vw
		ON st.ViewType=vw.ViewType
	LEFT JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE  st.MemberID=@MemberID
		AND (
			AccessDate >= @StartDateRange AND AccessDate < @EndDateRange
		)
GROUP BY vwd.ViewName, YEAR(AccessDate), MONTH(AccessDate), DATENAME(mm, AccessDate)
ORDER BY YEAR(st.AccessDate), MONTH(AccessDate), vwd.ViewName

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_VOL_AutoReport_Stats_IP_View] TO [cioc_login_role]
GO
