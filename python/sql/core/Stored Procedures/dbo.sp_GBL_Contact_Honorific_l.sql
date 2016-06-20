SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Contact_Honorific_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT Honorific
	FROM GBL_Contact_Honorific
ORDER BY Honorific

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Contact_Honorific_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Contact_Honorific_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Contact_Honorific_l] TO [cioc_vol_search_role]
GO
