
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PaymentTerms_l]
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

SELECT pyt.PYT_ID, CASE WHEN pytn.LangID=@@LANGID THEN pytn.Name ELSE '[' + pytn.Name + ']' END AS PaymentTerms
	FROM GBL_PaymentTerms pyt
	INNER JOIN GBL_PaymentTerms_Name pytn
		ON pyt.PYT_ID=pytn.PYT_ID
			AND pytn.LangID=CASE
				WHEN @AllLanguages=0 AND (@OverrideID IS NULL OR pytn.PYT_ID<>@OverrideID) THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM GBL_PaymentTerms_Name WHERE PYT_ID=pyt.PYT_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE pyt.PYT_ID=@OverrideID
	OR (
		(pyt.MemberID IS NULL OR @MemberID IS NULL OR pyt.MemberID=@MemberID)
		AND (
			@ShowHidden=1
			OR NOT EXISTS(SELECT * FROM GBL_PaymentTerms_InactiveByMember WHERE PYT_ID=pyt.PYT_ID AND MemberID=@MemberID)
		)
	)
ORDER BY pyt.DisplayOrder, pytn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_GBL_PaymentTerms_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_PaymentTerms_l] TO [cioc_login_role]
GO
