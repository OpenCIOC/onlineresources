SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_SeeAlso_lsa]
	@Code [varchar](21)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 08-Apr-2012
	Action: NO ACTION REQUIRED
*/

SELECT sa.SA_ID, tm.Code, tm.Code, tm.Active, sa.Authorized,
		CASE WHEN @@LANGID=tmd.LangID THEN tmd.Term ELSE '[' + tmd.Term + ']'
		END AS Term
	FROM TAX_SeeAlso sa
	INNER JOIN TAX_Term tm
		ON tm.Code = sa.SA_Code
	INNER JOIN TAX_Term_Description tmd
		ON tm.Code = tmd.Code AND tmd.LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE tmd.Code=Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE     (sa.Code = @Code)
ORDER BY tmd.Term

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_SeeAlso_lsa] TO [cioc_login_role]
GO
