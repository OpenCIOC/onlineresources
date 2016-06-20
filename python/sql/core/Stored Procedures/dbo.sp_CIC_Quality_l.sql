
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Quality_l]
	@MemberID [int],
	@ShowHidden [bit],
	@OverrideID [int]
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

SELECT q.RQ_ID, q.Quality, qn.Name AS QualityName
	FROM CIC_Quality q
	LEFT JOIN CIC_Quality_Name qn
		ON q.RQ_ID=qn.RQ_ID AND qn.LangID=@@LANGID
WHERE q.RQ_ID=@OverrideID
	OR (
		(q.MemberID IS NULL OR @MemberID IS NULL OR q.MemberID=@MemberID)
		AND (
			@ShowHidden=1
			OR NOT EXISTS(SELECT * FROM CIC_Quality_InactiveByMember WHERE RQ_ID=q.RQ_ID AND MemberID=@MemberID)
		)
	)
ORDER BY q.DisplayOrder, q.Quality

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Quality_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_Quality_l] TO [cioc_login_role]
GO
