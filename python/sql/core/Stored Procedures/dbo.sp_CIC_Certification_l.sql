
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Certification_l]
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

SELECT crt.CRT_ID AS CRT_ID, CASE WHEN crtn.LangID=@@LANGID THEN crtn.Name ELSE '[' + crtn.Name + ']' END AS Certification
	FROM CIC_Certification crt
	INNER JOIN CIC_Certification_Name crtn
		ON crt.CRT_ID=crtn.CRT_ID
			AND crtn.LangID=CASE
				WHEN @AllLanguages=0 AND (@OverrideID IS NULL OR crtn.CRT_ID<>@OverrideID) THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM CIC_Certification_Name WHERE CRT_ID=crt.CRT_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE crt.CRT_ID=@OverrideID
	OR (
		(crt.MemberID IS NULL OR @MemberID IS NULL OR crt.MemberID=@MemberID)
		AND (
			@ShowHidden=1
			OR NOT EXISTS(SELECT * FROM CIC_Certification_InactiveByMember WHERE CRT_ID=crt.CRT_ID AND MemberID=@MemberID)
		)
	)
ORDER BY crt.DisplayOrder, crtn.Name

RETURN @Error

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Certification_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_Certification_l] TO [cioc_login_role]
GO
