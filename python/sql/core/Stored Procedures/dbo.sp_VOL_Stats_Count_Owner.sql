SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Stats_Count_Owner] (
	@MemberID int,
	@StartDateRange smalldatetime,
	@EndDateRange smalldatetime
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

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
	RECORD_OWNER, 
	COUNT(User_ID) AS StaffCount, COUNT(*) AS Total
	FROM VOL_Stats_OPID st 
	INNER JOIN VOL_Opportunity vo 
		ON st.OP_ID=vo.OP_ID
	WHERE st.MemberID=@MemberID
		AND (
			AccessDate >= @StartDateRange AND AccessDate < @EndDateRange
		)
	GROUP BY RECORD_OWNER
	ORDER BY RECORD_OWNER

RETURN @Error

SET ANSI_WARNINGS ON
SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Stats_Count_Owner] TO [cioc_login_role]
GO
