
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Vacancy_ServiceTitle_l]
	@MemberID [int],
	@ShowHidden [bit],
	@AllLanguages [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT vst.VST_ID, CASE WHEN vstn.LangID=@@LANGID THEN vstn.Name ELSE '[' + vstn.Name + ']' END AS ServiceTitle
	FROM CIC_Vacancy_ServiceTitle vst
	INNER JOIN CIC_Vacancy_ServiceTitle_Name vstn
		ON vst.VST_ID=vstn.VST_ID
			AND vstn.LangID=CASE
				WHEN @AllLanguages=0 THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM CIC_Vacancy_ServiceTitle_Name WHERE VST_ID=vst.VST_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE (vst.MemberID IS NULL OR @MemberID IS NULL OR vst.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM CIC_Vacancy_ServiceTitle_InactiveByMember WHERE VST_ID=vst.VST_ID AND MemberID=@MemberID)
	)
ORDER BY vst.DisplayOrder, vstn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Vacancy_ServiceTitle_l] TO [cioc_login_role]
GO
