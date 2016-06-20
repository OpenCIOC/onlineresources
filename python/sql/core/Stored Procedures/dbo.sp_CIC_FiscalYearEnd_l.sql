
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_FiscalYearEnd_l]
	@MemberID [int],
	@ShowHidden [bit],
	@AllLanguages [bit],
	@OverrideID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT fye.FYE_ID, CASE WHEN fyen.LangID=@@LANGID THEN fyen.Name ELSE '[' + fyen.Name + ']' END AS FiscalYearEnd
	FROM CIC_FiscalYearEnd fye
	INNER JOIN CIC_FiscalYearEnd_Name fyen
		ON fye.FYE_ID=fyen.FYE_ID
			AND fyen.LangID=CASE
				WHEN @AllLanguages=0 AND (@OverrideID IS NULL OR fyen.FYE_ID<>@OverrideID) THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM CIC_FiscalYearEnd_Name WHERE FYE_ID=fye.FYE_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE fye.FYE_ID=@OverrideID
	OR (
		(fye.MemberID IS NULL OR @MemberID IS NULL OR fye.MemberID=@MemberID)
		AND (
			@ShowHidden=1
			OR NOT EXISTS(SELECT * FROM CIC_FiscalYearEnd_InactiveByMember WHERE FYE_ID=fye.FYE_ID AND MemberID=@MemberID)
		)
	)
ORDER BY fye.DisplayOrder, fyen.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_FiscalYearEnd_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_FiscalYearEnd_l] TO [cioc_login_role]
GO
