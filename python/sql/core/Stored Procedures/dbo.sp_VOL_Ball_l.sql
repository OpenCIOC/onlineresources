SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Ball_l]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 16-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT BallID, ISNULL(Colour, BallFileName) AS Colour
	FROM VOL_Ball
ORDER BY Colour

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Ball_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Ball_l] TO [cioc_vol_search_role]
GO
