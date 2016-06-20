SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Unused_lsa]
	@Code [varchar](21)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 11-May-2012
	Action: NO ACTION REQUIRED
*/

SELECT ut.UT_ID, ut.Active, ut.Authorized, Term, LangID
	FROM TAX_Unused ut
WHERE (ut.Code = @Code)
ORDER BY LangID, Term

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Unused_lsa] TO [cioc_login_role]
GO
