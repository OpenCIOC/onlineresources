SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Robot_Name_l]
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
	FROM GBL_Robot
ORDER BY DisplayOrder, DisplayName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Robot_Name_l] TO [cioc_login_role]
GO
