
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Accreditation_l]
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

DECLARE 	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT acr.ACR_ID AS ACR_ID, CASE WHEN acrn.LangID=@@LANGID THEN acrn.Name ELSE '[' + acrn.Name + ']' END AS Accreditation
	FROM CIC_Accreditation acr
	INNER JOIN CIC_Accreditation_Name acrn
		ON acr.ACR_ID=acrn.ACR_ID
			AND acrn.LangID=CASE
				WHEN @AllLanguages=0 AND (@OverrideID IS NULL OR acrn.ACR_ID<>@OverrideID) THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM CIC_Accreditation_Name WHERE ACR_ID=acr.ACR_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE acr.ACR_ID=@OverrideID
	OR (
		(acr.MemberID IS NULL OR @MemberID IS NULL OR acr.MemberID=@MemberID)
		AND (
			@ShowHidden=1
			OR NOT EXISTS(SELECT * FROM CIC_Accreditation_InactiveByMember WHERE ACR_ID=acr.ACR_ID AND MemberID=@MemberID)
		)
	)
ORDER BY acr.DisplayOrder, acrn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Accreditation_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_Accreditation_l] TO [cioc_login_role]
GO
