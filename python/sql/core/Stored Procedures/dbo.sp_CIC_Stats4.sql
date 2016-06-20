
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CIC_Stats4]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.2
	Checked by: KL
	Checked on: 18-Feb-2015
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

SELECT  bt.RECORD_OWNER,
		COUNT(DISTINCT CASE WHEN bt.MemberID=@MemberID THEN bt.NUM ELSE NULL END) AS RecordCountLocal,
		COUNT(DISTINCT CASE WHEN bt.MemberID<>@MemberID AND shp.Active=1 THEN bt.NUM ELSE NULL END) AS RecordCountOther,
		COUNT(st.[User_ID]) AS StaffUsageCount,
		COUNT(st.Log_ID) AS UsageCount
	FROM CIC_Stats_RSN st
	LEFT JOIN GBL_BaseTable bt
		ON st.RSN=bt.RSN AND st.MemberID=@MemberID
	LEFT JOIN GBL_BT_SharingProfile pr
		ON pr.NUM=bt.NUM AND ShareMemberID_Cache=@MemberID
	LEFT JOIN GBL_SharingProfile shp
		ON pr.ProfileID=shp.ProfileID AND shp.Active=1
WHERE st.MemberID=@MemberID
GROUP BY bt.RECORD_OWNER
HAVING COUNT(st.Log_ID) > 0
ORDER BY RECORD_OWNER

RETURN @Error

SET NOCOUNT OFF

GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Stats4] TO [cioc_login_role]
GO
