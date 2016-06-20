SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunityGroup_l]
	@MemberID int,
	@CommunitySetID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Jan-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT vcg.CommunityGroupID, CommunityGroupName
	FROM VOL_CommunityGroup vcg
	INNER JOIN VOL_CommunityGroup_Name vcgn
		ON vcg.CommunityGroupID=vcgn.CommunityGroupID AND vcgn.LangID=(SELECT TOP 1 LangID FROM VOL_CommunityGroup_Name WHERE CommunityGroupID=vcgn.CommunityGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN VOL_CommunitySet vcs
		ON vcg.CommunitySetID=vcs.CommunitySetID AND vcs.MemberID=@MemberID
WHERE vcs.CommunitySetID=@CommunitySetID
ORDER BY CommunityGroupName

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_l] TO [cioc_vol_search_role]
GO
