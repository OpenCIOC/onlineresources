SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_TaxCode_Finder]
	@MemberID int,
	@searchStr varchar(100)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT TOP 15 tax.Code, taxn.Term
	FROM TAX_Term tax
	LEFT JOIN TAX_Term_Description taxn
		ON tax.Code=taxn.Code
			AND taxn.LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE Code=tax.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE /* (tax.MemberID IS NULL OR tax.MemberID=@MemberID)
			AND NOT EXISTS(SELECT * FROM CIC_Distribution_InactiveByMember WHERE DST_ID=tax.DST_ID AND MemberID=@MemberID)
	AND */ (
		tax.Code LIKE @searchStr + '%'
	)
ORDER BY tax.CdLvl,  tax.Code

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_TaxCode_Finder] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_CIC_TaxCode_Finder] TO [cioc_login_role]
GO
