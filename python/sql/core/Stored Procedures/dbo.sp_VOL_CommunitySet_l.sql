SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunitySet_l]
	@MemberID int
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
ORDER BY SetName

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunitySet_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunitySet_l] TO [cioc_vol_search_role]
GO
