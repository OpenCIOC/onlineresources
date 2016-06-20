SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_StreetType_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT st.*, sl.LanguageName,
		CAST(CASE WHEN EXISTS(SELECT * FROM GBL_StreetType
			WHERE SType_ID<>st.SType_ID AND AfterName<>st.AfterName
				AND StreetType=st.StreetType AND LangID=st.LangID)
		THEN 1 ELSE 0 END AS bit) AS MULTIPLE_ORIENTATIONS
	FROM GBL_StreetType st
	INNER JOIN STP_Language sl
		ON st.LangID=sl.LangID
ORDER BY CASE WHEN st.LangID=@@LANGID THEN 0 ELSE 1 END, st.LangID, StreetType, AfterName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetType_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetType_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetType_l] TO [cioc_vol_search_role]
GO
