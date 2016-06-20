
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_InterestGroup_l]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 23-Feb-2015
	Action: NO ACTION REQUIRED
*/

SELECT ig.IG_ID, ign.Name AS InterestGroupName
	FROM VOL_InterestGroup ig
	INNER JOIN VOL_InterestGroup_Name ign
		ON ig.IG_ID=ign.IG_ID AND ign.LangID=@@LANGID
WHERE EXISTS(SELECT * FROM VOL_AI_IG ai WHERE ai.IG_ID=ig.IG_ID AND NOT EXISTS(SELECT * FROM VOL_Interest_InactiveByMember WHERE ai.AI_ID=AI_ID AND MemberID=@MemberID))
ORDER BY InterestGroupName

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_VOL_InterestGroup_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_InterestGroup_l] TO [cioc_vol_search_role]
GO
