
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Language_l]
	@MemberID [int],
	@ShowHidden [bit],
	@OnlyShowOnForm [bit]
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

SELECT ln.LN_ID, lnn.Name AS LanguageName
	FROM GBL_Language ln
	INNER JOIN GBL_Language_Name lnn
		ON ln.LN_ID=lnn.LN_ID
			AND lnn.LangID=(SELECT TOP 1 LangID FROM GBL_Language_Name WHERE LN_ID=ln.LN_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE (ln.MemberID IS NULL OR @MemberID IS NULL OR ln.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM GBL_Language_InactiveByMember WHERE LN_ID=ln.LN_ID AND MemberID=@MemberID)
	)
	AND (
		@OnlyShowOnForm=0
		OR ln.ShowOnForm=1
	)
ORDER BY ln.DisplayOrder, lnn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_GBL_Language_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Language_l] TO [cioc_login_role]
GO
