
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Currency_l]
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

SELECT cur.CUR_ID, cur.Currency, curn.Name AS CurrencyName
	FROM GBL_Currency cur
	LEFT JOIN GBL_Currency_Name curn
		ON cur.CUR_ID=curn.CUR_ID AND curn.LangID=@@LANGID
WHERE (cur.MemberID IS NULL OR @MemberID IS NULL OR cur.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM GBL_Currency_InactiveByMember WHERE CUR_ID=cur.CUR_ID AND MemberID=@MemberID)
	)
ORDER BY DisplayOrder, Currency

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_GBL_Currency_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Currency_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Currency_l] TO [cioc_vol_search_role]
GO
