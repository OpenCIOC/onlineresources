SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[sp_GBL_SignatureStatus_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT *
	FROM GBL_SignatureStatus sig
	INNER JOIN GBL_SignatureStatus_Name [sign]
		ON sig.SIG_ID=[sign].SIG_ID AND [sign].LangID=(SELECT TOP 1 LangID FROM GBL_SignatureStatus_Name WHERE SIG_ID=sig.SIG_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY [sign].Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SignatureStatus_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_SignatureStatus_l] TO [cioc_login_role]
GO
