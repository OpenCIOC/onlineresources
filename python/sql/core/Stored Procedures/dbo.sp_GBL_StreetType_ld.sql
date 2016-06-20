SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_StreetType_ld]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT DISTINCT StreetType
	FROM GBL_StreetType st
ORDER BY StreetType

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetType_ld] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetType_ld] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_StreetType_ld] TO [cioc_vol_search_role]
GO
