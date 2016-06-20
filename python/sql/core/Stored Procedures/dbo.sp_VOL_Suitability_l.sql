
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Suitability_l]
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

SELECT sb.SB_ID, sbn.Name AS SuitableFor
	FROM VOL_Suitability sb
	INNER JOIN VOL_Suitability_Name sbn
		ON sb.SB_ID=sbn.SB_ID AND sbn.LangID=@@LANGID
WHERE (sb.MemberID IS NULL OR @MemberID IS NULL OR sb.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM VOL_Suitability_InactiveByMember WHERE SB_ID=sb.SB_ID AND MemberID=@MemberID)
	)
ORDER BY sb.DisplayOrder, sbn.Name

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Suitability_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Suitability_l] TO [cioc_vol_search_role]
GO
