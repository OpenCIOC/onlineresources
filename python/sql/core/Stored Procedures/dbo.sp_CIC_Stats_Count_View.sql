SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Stats_Count_View] (
	@MemberID int,
	@StartDateRange smalldatetime,
	@EndDateRange smalldatetime,
	@PB_ID int
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
	SELECT @StartDateRange = MIN(AccessDate) FROM dbo.CIC_Stats_RSN
END

DECLARE @TheMonth nvarchar(255)
SELECT @TheMonth = cioc_shared.dbo.fn_SHR_GBL_DateString(@StartDateRange) + ' - ' + cioc_shared.dbo.fn_SHR_GBL_DateString(@EndDateRange)

SELECT @TheMonth AS Month1

SELECT PubCode, Name
FROM dbo.CIC_Publication pb
LEFT JOIN dbo.CIC_Publication_Name pbn
	ON pbn.PB_ID = pb.PB_ID AND LangID=@@LANGID
WHERE pb.PB_ID=@PB_ID


SELECT @TheMonth AS TheMonth,
		ISNULL(ViewName,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown')) AS ViewName,
		COUNT(User_ID) AS StaffCount, COUNT(*) AS Total
	FROM CIC_Stats_RSN st
	LEFT JOIN CIC_View vw
		ON st.ViewType=vw.ViewType
	LEFT JOIN CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.GBL_BaseTable bt
		ON bt.RSN=st.RSN
	WHERE st.MemberID=@MemberID
		AND (
			AccessDate >= @StartDateRange AND AccessDate < @EndDateRange
		)
		AND (
			@PB_ID IS NULL
			OR EXISTS(SELECT * FROM dbo.CIC_BT_PB pr WHERE pr.NUM=bt.NUM AND PB_ID=@PB_ID)
		)
	GROUP BY vwd.ViewName
	ORDER BY vwd.ViewName
	
RETURN @Error

SET ANSI_WARNINGS ON
SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Stats_Count_View] TO [cioc_login_role]
GO
