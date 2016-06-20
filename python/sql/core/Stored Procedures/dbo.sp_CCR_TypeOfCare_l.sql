
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CCR_TypeOfCare_l] (
	@MemberID [int],
	@ShowHidden [bit],
	@AllLanguages [bit]
)
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

SELECT toc.TOC_ID, CASE WHEN tocn.LangID=@@LANGID THEN tocn.Name ELSE '[' + tocn.Name + ']' END AS TypeOfCare
	FROM CCR_TypeOfCare toc
	INNER JOIN CCR_TypeOfCare_Name tocn
		ON toc.TOC_ID=tocn.TOC_ID
			AND tocn.LangID=CASE
				WHEN @AllLanguages=0 THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM CCR_TypeOfCare_Name WHERE TOC_ID=toc.TOC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE (toc.MemberID IS NULL OR @MemberID IS NULL OR toc.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM CCR_TypeOfCare_InactiveByMember WHERE TOC_ID=toc.TOC_ID AND MemberID=@MemberID)
	)
ORDER BY toc.DisplayOrder, tocn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CCR_TypeOfCare_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CCR_TypeOfCare_l] TO [cioc_login_role]
GO
