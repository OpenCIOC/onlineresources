
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Skill_l]
	@MemberID [int],
	@ShowHidden [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 07-Jun-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT sk.SK_ID, skn.Name AS Skill
	FROM VOL_Skill sk
	INNER JOIN VOL_Skill_Name skn
		ON sk.SK_ID=skn.SK_ID AND skn.LangID=@@LANGID
WHERE (sk.MemberID IS NULL OR @MemberID IS NULL OR sk.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM VOL_Skill_InactiveByMember WHERE SK_ID=sk.SK_ID AND MemberID=@MemberID)
	)
ORDER BY sk.DisplayOrder, skn.Name

RETURN @Error

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Skill_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Skill_l] TO [cioc_vol_search_role]
GO
