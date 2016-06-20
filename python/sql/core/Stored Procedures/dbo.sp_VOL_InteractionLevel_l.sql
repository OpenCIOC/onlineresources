
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_InteractionLevel_l]
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

SELECT il.IL_ID, iln.Name AS InteractionLevel
	FROM VOL_InteractionLevel il
	INNER JOIN VOL_InteractionLevel_Name iln
		ON il.IL_ID=iln.IL_ID AND iln.LangID=@@LANGID
WHERE (il.MemberID IS NULL OR @MemberID IS NULL OR il.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM VOL_InteractionLevel_InactiveByMember WHERE IL_ID=il.IL_ID AND MemberID=@MemberID)
	)
ORDER BY il.DisplayOrder, iln.Name

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_VOL_InteractionLevel_l] TO [cioc_login_role]
GO
