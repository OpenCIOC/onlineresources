
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommitmentLength_l]
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

SELECT cl.CL_ID, cln.Name AS CommitmentLength
	FROM VOL_CommitmentLength cl
	INNER JOIN VOL_CommitmentLength_Name cln
		ON cl.CL_ID=cln.CL_ID AND cln.LangID=@@LANGID
WHERE (cl.MemberID IS NULL OR @MemberID IS NULL OR cl.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM VOL_CommitmentLength_InactiveByMember WHERE CL_ID=cl.CL_ID AND MemberID=@MemberID)
	)
ORDER BY cl.DisplayOrder, cln.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_VOL_CommitmentLength_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_CommitmentLength_l] TO [cioc_vol_search_role]
GO
