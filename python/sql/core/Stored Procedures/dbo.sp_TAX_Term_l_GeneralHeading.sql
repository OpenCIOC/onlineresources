SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_TAX_Term_l_GeneralHeading]
	@Codes varchar(max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 11-May-2012
	Action: NO ACTION REQUIRED
*/

SELECT DISTINCT tm.Code, ISNULL(tmd.AltTerm, tmd.Term) Term
	FROM TAX_Term tm
	INNER JOIN TAX_Term_Description tmd
		ON tm.Code=tmd.Code AND LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE Code=tm.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@Codes, ',') tml
		ON tm.Code=tml.ItemID COLLATE Latin1_General_100_CI_AI
ORDER BY Code

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Term_l_GeneralHeading] TO [cioc_login_role]
GO
