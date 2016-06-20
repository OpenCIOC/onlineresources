
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CCR_TypeOfProgram_l] (
	@MemberID [int],
	@ShowHidden [bit],
	@AllLanguages [bit],
	@OverrideID [int]
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

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT [top].TOP_ID, CASE WHEN topn.LangID=@@LANGID THEN topn.Name ELSE '[' + topn.Name + ']' END AS TypeOfProgram
	FROM CCR_TypeOfProgram [top]
	INNER JOIN CCR_TypeOfProgram_Name topn
		ON [top].TOP_ID=topn.TOP_ID
			AND topn.LangID=CASE
				WHEN @AllLanguages=0 AND (@OverrideID IS NULL OR topn.TOP_ID<>@OverrideID) THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM CCR_TypeOfProgram_Name WHERE TOP_ID=[top].TOP_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE [top].TOP_ID=@OverrideID
	OR (
		([top].MemberID IS NULL OR @MemberID IS NULL OR [top].MemberID=@MemberID)
		AND (
			@ShowHidden=1
			OR NOT EXISTS(SELECT * FROM CCR_TypeOfProgram_InactiveByMember WHERE TOP_ID=[top].TOP_ID AND MemberID=@MemberID)
		)
	)
ORDER BY [top].DisplayOrder, topn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CCR_TypeOfProgram_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CCR_TypeOfProgram_l] TO [cioc_login_role]
GO
