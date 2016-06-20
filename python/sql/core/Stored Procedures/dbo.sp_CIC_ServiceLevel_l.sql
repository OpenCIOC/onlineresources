
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ServiceLevel_l]
	@MemberID [int],
	@ShowHidden [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 19-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT sl.SL_ID, sl.ServiceLevelCode, sln.Name AS ServiceLevel
	FROM CIC_ServiceLevel sl
	LEFT JOIN CIC_ServiceLevel_Name sln
		ON sl.SL_ID=sln.SL_ID AND sln.LangID=@@LANGID
WHERE (sl.MemberID IS NULL OR @MemberID IS NULL OR sl.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM CIC_ServiceLevel_InactiveByMember WHERE SL_ID=sl.SL_ID AND MemberID=@MemberID)
	)
ORDER BY ServiceLevelCode

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_ServiceLevel_l] TO [cioc_login_role]
GO
