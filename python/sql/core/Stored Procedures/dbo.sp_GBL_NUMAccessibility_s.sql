SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_NUMAccessibility_s]
	@MemberID int,
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT ac.AC_ID, acn.LangID, CASE WHEN acn.LangID=@@LANGID THEN acn.Name ELSE '[' + acn.Name + ']' END AS AccessibilityType, prn.Notes,
		CASE WHEN pr.NUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM GBL_Accessibility ac
	INNER JOIN GBL_Accessibility_Name acn
		ON ac.AC_ID=acn.AC_ID
			AND acn.LangID=(SELECT TOP 1 LangID FROM GBL_Accessibility_Name WHERE AC_ID=ac.AC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_BT_AC pr 
		ON ac.AC_ID = pr.AC_ID AND pr.NUM=@NUM
	LEFT JOIN GBL_BT_AC_Notes prn
		ON pr.BT_AC_ID=prn.BT_AC_ID
			AND prn.LangID=@@LANGID
	LEFT JOIN GBL_BaseTable bt
		ON pr.NUM=bt.NUM
WHERE pr.BT_AC_ID IS NOT NULL
	OR ac.MemberID=bt.MemberID
	OR ac.MemberID=@MemberID
	OR ac.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM GBL_Accessibility_InactiveByMember WHERE AC_ID=ac.AC_ID AND MemberID=@MemberID)
		OR NOT EXISTS(SELECT * FROM GBL_Accessibility_InactiveByMember WHERE AC_ID=ac.AC_ID AND MemberID=bt.MemberID)
	)
ORDER BY ac.DisplayOrder, acn.Name

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_NUMAccessibility_s] TO [cioc_login_role]
GO
