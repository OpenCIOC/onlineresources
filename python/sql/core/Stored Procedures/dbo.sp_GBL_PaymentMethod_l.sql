
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PaymentMethod_l]
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

SELECT pay.PAY_ID, CASE WHEN payn.LangID=@@LANGID THEN payn.Name ELSE '[' + payn.Name + ']' END AS PaymentMethod
	FROM GBL_PaymentMethod pay
	INNER JOIN GBL_PaymentMethod_Name payn
		ON pay.PAY_ID=payn.PAY_ID
			AND payn.LangID=CASE
				WHEN @AllLanguages=0 AND (@OverrideID IS NULL OR payn.PAY_ID<>@OverrideID) THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM GBL_PaymentMethod_Name WHERE PAY_ID=pay.PAY_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE pay.PAY_ID=@OverrideID
	OR (
		(pay.MemberID IS NULL OR @MemberID IS NULL OR pay.MemberID=@MemberID)
		AND (
			@ShowHidden=1
			OR NOT EXISTS(SELECT * FROM GBL_PaymentMethod_InactiveByMember WHERE PAY_ID=pay.PAY_ID AND MemberID=@MemberID)
		)
	)
ORDER BY pay.DisplayOrder, payn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_GBL_PaymentMethod_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_PaymentMethod_l] TO [cioc_login_role]
GO
