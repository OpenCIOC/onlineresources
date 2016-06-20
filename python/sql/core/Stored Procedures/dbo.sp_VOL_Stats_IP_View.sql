SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Stats_IP_View] (
	@MemberID int,
	@StartDateRange smalldatetime,
	@EndDateRange smalldatetime
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

IF @EndDateRange IS NULL BEGIN
	SET @EndDateRange = CONVERT(VARCHAR(25), CAST(DATEADD(dd,1,GETDATE()) AS date),126)
END

IF @StartDateRange IS NULL BEGIN
	SELECT @StartDateRange = MIN(AccessDate) FROM dbo.VOL_Stats_OPID
END

DECLARE @TheMonth nvarchar(255)
SELECT @TheMonth = cioc_shared.dbo.fn_SHR_GBL_DateString(@StartDateRange) + ' - ' + cioc_shared.dbo.fn_SHR_GBL_DateString(@EndDateRange)

SELECT @TheMonth AS Month1

SELECT @TheMonth AS TheMonth,
	ISNULL(ViewName,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown')) AS ViewName,
	COUNT(DISTINCT IpAddress) AS UniqueIPs
	FROM VOL_Stats_OPID st
	LEFT JOIN VOL_View vw
		ON st.ViewType=vw.ViewType
	LEFT JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE st.MemberID=@MemberID
		AND (
			AccessDate >= @StartDateRange AND AccessDate < @EndDateRange
		)
GROUP BY vwd.ViewName
ORDER BY vwd.ViewName

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Stats_IP_View] TO [cioc_login_role]
GO
