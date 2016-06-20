
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Vacancy_UnitType_l]
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

SELECT vut.VUT_ID, vutn.Name AS UnitTypeName
	FROM CIC_Vacancy_UnitType vut
	INNER JOIN CIC_Vacancy_UnitType_Name vutn
		ON vut.VUT_ID=vutn.VUT_ID AND LangID=(SELECT TOP 1 LangID FROM CIC_Vacancy_UnitType_Name WHERE VUT_ID=vutn.VUT_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE (vut.MemberID IS NULL OR @MemberID IS NULL OR vut.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM CIC_Vacancy_UnitType_InactiveByMember WHERE VUT_ID=vut.VUT_ID AND MemberID=@MemberID)
	)
ORDER BY vut.DisplayOrder, vutn.Name

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Vacancy_UnitType_l] TO [cioc_login_role]
GO
