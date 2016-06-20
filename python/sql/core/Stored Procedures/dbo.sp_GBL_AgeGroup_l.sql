SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_AgeGroup_l]
	@MemberID int,
	@CCR bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 13-Jan-2012
	Action: NO ACTION REQUIRED
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

SELECT ag.AgeGroup_ID, agn.Name AS AgeGroupName
	FROM GBL_AgeGroup ag
	INNER JOIN GBL_AgeGroup_Name agn
		ON ag.AgeGroup_ID=agn.AgeGroup_ID AND LangID=@@LANGID
WHERE (MemberID=@MemberID OR MemberID IS NULL OR @MemberID IS NULL)
	AND NOT EXISTS(SELECT * FROM GBL_AgeGroup_InactiveByMember WHERE AgeGroup_ID=ag.AgeGroup_ID AND MemberID=@MemberID)
	AND (@CCR=0 OR CCR=1)
ORDER BY MinAge, MaxAge

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_AgeGroup_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_AgeGroup_l] TO [cioc_login_role]
GO
