
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Vacancy_TargetPop_l]
	@MemberID [int],
	@ShowHidden [bit],
	@OverrideID [int]
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

SELECT vtp.VTP_ID, vtpn.Name AS TargetPopulation
	FROM CIC_Vacancy_TargetPop vtp
	INNER JOIN CIC_Vacancy_TargetPop_Name vtpn
		ON vtp.VTP_ID=vtpn.VTP_ID
			AND LangID=(SELECT TOP 1 LangID FROM CIC_Vacancy_TargetPop_Name WHERE VTP_ID=vtp.VTP_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vtp.VTP_ID=@OverrideID
	OR (
		(vtp.MemberID IS NULL OR @MemberID IS NULL OR vtp.MemberID=@MemberID)
		AND (
			@ShowHidden=1
			OR NOT EXISTS(SELECT * FROM CIC_Vacancy_TargetPop_InactiveByMember WHERE VTP_ID=vtp.VTP_ID AND MemberID=@MemberID)
		)
	)
ORDER BY vtp.DisplayOrder, vtpn.Name

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Vacancy_TargetPop_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_Vacancy_TargetPop_l] TO [cioc_login_role]
GO
