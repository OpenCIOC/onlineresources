
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Seasons_l]
	@MemberID [int],
	@ShowHidden [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT ssn.SSN_ID, ssnn.Name AS Season
	FROM VOL_Seasons ssn
	INNER JOIN VOL_Seasons_Name ssnn
		ON ssn.SSN_ID=ssnn.SSN_ID AND ssnn.LangID=@@LANGID
WHERE (ssn.MemberID IS NULL OR @MemberID IS NULL OR ssn.MemberID=@MemberID)
		AND (
			@ShowHidden=1
			OR NOT EXISTS(SELECT * FROM VOL_Seasons_InactiveByMember WHERE SSN_ID=ssn.SSN_ID AND MemberID=@MemberID)
		)
ORDER BY ssn.DisplayOrder, ssnn.Name
	
RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Seasons_l] TO [cioc_login_role]
GO
