SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_MinHoursPer_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 16-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT hp.HPER_ID, Name
	FROM VOL_MinHoursPer hp
	INNER JOIN VOL_MinHoursPer_Name hpn
		ON hp.HPER_ID=hpn.HPER_ID AND LangID=@@LANGID
ORDER BY hpn.HPER_ID

SET NOCOUNT OFF


GO
DENY EXECUTE ON  [dbo].[sp_VOL_MinHoursPer_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_MinHoursPer_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_MinHoursPer_l] TO [cioc_vol_search_role]
GO
