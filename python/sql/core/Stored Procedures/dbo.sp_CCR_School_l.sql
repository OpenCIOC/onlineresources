
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CCR_School_l] (
	@MemberID [int],
	@ShowHidden [bit]
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT sch.SCH_ID, schn.Name AS SchoolName, sch.SchoolBoard, 
	CASE WHEN EXISTS(SELECT * FROM CCR_School_Name schn2 
		WHERE schn2.SCH_ID <> schn.SCH_ID AND schn2.Name = schn.Name 
			AND schn2.LangID=(SELECT TOP 1 LangID FROM CCR_School_Name WHERE SCH_ID=schn2.SCH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		) THEN 1 ELSE 0 END AS NEEDS_BOARD
	FROM CCR_School sch
	INNER JOIN CCR_School_Name schn
		ON sch.SCH_ID=schn.SCH_ID AND LangID=(SELECT TOP 1 LangID FROM CCR_School_Name WHERE SCH_ID=sch.SCH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE (sch.MemberID IS NULL OR @MemberID IS NULL OR sch.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM CCR_School_InactiveByMember WHERE SCH_ID=sch.SCH_ID AND MemberID=@MemberID)
	)
ORDER BY SchoolName

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CCR_School_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CCR_School_l] TO [cioc_login_role]
GO
