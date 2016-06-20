SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunityGroup_lf]
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

SELECT cs.CommunitySetID, SetName
	FROM VOL_CommunitySet cs
	INNER JOIN VOL_CommunitySet_Name csn
		ON cs.CommunitySetID=csn.CommunitySetID AND LangID=(SELECT TOP 1 LangID FROM VOL_CommunitySet_Name WHERE csn.CommunitySetID=CommunitySetID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE cs.MemberID=@MemberID
	AND cs.CommunitySetID=@CommunitySetID

SELECT vcg.*, (SELECT COUNT(*) FROM VOL_CommunityGroup_CM vcgc WHERE vcg.CommunityGroupID=vcgc.CommunityGroupID) AS UsageCount,
	(SELECT vcgn.CommunityGroupName AS [@CommunityGroupName], l.Culture AS [@Culture]
		FROM VOL_CommunityGroup_Name vcgn
		INNER JOIN STP_Language l
			ON vcgn.LangID=l.LangID
		WHERE vcgn.CommunityGroupID=vcg.CommunityGroupID
		FOR XML PATH('DESC'), TYPE) AS Descriptions
	FROM VOL_CommunityGroup vcg
	INNER JOIN VOL_CommunitySet vcs
		ON vcg.CommunitySetID=vcs.CommunitySetID AND vcs.MemberID=@MemberID
WHERE vcs.CommunitySetID=@CommunitySetID
ORDER BY (SELECT TOP 1 CommunityGroupName FROM VOL_CommunityGroup_Name WHERE CommunityGroupID=vcg.CommunityGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_lf] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_lf] TO [cioc_vol_search_role]
GO
