SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_StreetType_lf]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 21-Jul-2012
	Action: NO ACTION REQUIRED
*/

SELECT st.*, sl.Culture
	FROM GBL_StreetType st
	INNER JOIN STP_Language sl
		ON st.LangID=sl.LangID
ORDER BY CASE WHEN st.LangID=@@LANGID THEN 0 ELSE 1 END, st.LangID, StreetType, AfterName

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetType_lf] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetType_lf] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetType_lf] TO [cioc_vol_search_role]
GO
