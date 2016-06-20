
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Accessibility_l]
	@MemberID [int],
	@ShowHidden [bit],
	@AllLanguages [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT ac.AC_ID, CASE WHEN acn.LangID=@@LANGID THEN acn.Name ELSE '[' + acn.Name + ']' END AS AccessibilityType
	FROM GBL_Accessibility ac
	INNER JOIN GBL_Accessibility_Name acn
		ON ac.AC_ID=acn.AC_ID
			AND acn.LangID=CASE
				WHEN @AllLanguages=0 THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM GBL_Accessibility_Name WHERE AC_ID=ac.AC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE (ac.MemberID IS NULL OR @MemberID IS NULL OR ac.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM GBL_Accessibility_InactiveByMember WHERE AC_ID=ac.AC_ID AND MemberID=@MemberID)
	)
ORDER BY ac.DisplayOrder, acn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_GBL_Accessibility_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Accessibility_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Accessibility_l] TO [cioc_vol_search_role]
GO
