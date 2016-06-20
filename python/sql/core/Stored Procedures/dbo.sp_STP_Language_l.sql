SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_Language_l]
	@Active bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action: NO ACTION REQUIRED
*/

SELECT LangID, LanguageName
	FROM STP_Language
WHERE @Active=0 OR Active=1
ORDER BY LanguageName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_STP_Language_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_STP_Language_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_STP_Language_l] TO [cioc_vol_search_role]
GO
