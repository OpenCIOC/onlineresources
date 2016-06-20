SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Stats_Month_l]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT DATENAME(m, AccessDate) + ' ' + CAST(YEAR(AccessDate) AS varchar) AS STAT_MONTH, COUNT(*) As UsageCount
	FROM CIC_Stats_RSN st
WHERE st.MemberID=@MemberID
GROUP BY DATENAME(m, AccessDate) + ' ' + CAST(YEAR(AccessDate) AS varchar)
ORDER BY CAST(DATENAME(m, AccessDate) + ' ' + CAST(YEAR(AccessDate) AS varchar) AS smalldatetime)

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Stats_Month_l] TO [cioc_login_role]
GO
