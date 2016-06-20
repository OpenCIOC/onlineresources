
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_FeeType_l]
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

SELECT ft.FT_ID, CASE WHEN ftn.LangID=@@LANGID THEN ftn.Name ELSE '[' + ftn.Name + ']' END AS FeeType
	FROM CIC_FeeType ft
	INNER JOIN CIC_FeeType_Name ftn
		ON ft.FT_ID=ftn.FT_ID
			AND ftn.LangID=CASE
				WHEN @AllLanguages=0 THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM CIC_FeeType_Name WHERE FT_ID=ft.FT_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE (ft.MemberID IS NULL OR @MemberID IS NULL OR ft.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM CIC_FeeType_InactiveByMember WHERE FT_ID=ft.FT_ID AND MemberID=@MemberID)
	)
ORDER BY ft.DisplayOrder, ftn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_FeeType_l] TO [cioc_login_role]
GO
