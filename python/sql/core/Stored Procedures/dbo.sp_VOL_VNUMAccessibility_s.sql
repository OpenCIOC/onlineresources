
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMAccessibility_s]
	@MemberID int,
	@VNUM varchar(10)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
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

SELECT ac.AC_ID, CASE WHEN acn.LangID=@@LANGID THEN acn.Name ELSE '[' + acn.Name + ']' END AS AccessibilityType, prn.Notes,
		CASE WHEN pr.VNUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM GBL_Accessibility ac
	INNER JOIN GBL_Accessibility_Name acn
		ON ac.AC_ID=acn.AC_ID
			AND acn.LangID=(SELECT TOP 1 LangID FROM GBL_Accessibility_Name WHERE AC_ID=ac.AC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_OP_AC pr 
		ON ac.AC_ID = pr.AC_ID AND pr.VNUM=@VNUM
	LEFT JOIN VOL_OP_AC_Notes prn
		ON pr.OP_AC_ID=prn.OP_AC_ID AND prn.LangID=@@LANGID
	LEFT JOIN VOL_Opportunity vo
		ON pr.VNUM=vo.VNUM
WHERE pr.OP_AC_ID IS NOT NULL
	OR ac.MemberID=vo.MemberID
	OR ac.MemberID=@MemberID
	OR (ac.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM GBL_Accessibility_InactiveByMember WHERE AC_ID=ac.AC_ID AND MemberID=ISNULL(vo.MemberID, @MemberID))
	))
ORDER BY ac.DisplayOrder, acn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMAccessibility_s] TO [cioc_login_role]
GO
