SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Banned_Check]
	@IPAddress varchar(20),
	@Banned bit OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 27-Jul-2012
	Action: NO ACTION REQUIRED
*/

IF EXISTS(SELECT * FROM GBL_Banned WHERE IPAddress=@IPAddress AND LoginBanOnly=0) BEGIN
	SET @Banned = 1
END ELSE BEGIN
	SET @Banned = 0
END

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Banned_Check] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Banned_Check] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Banned_Check] TO [cioc_vol_search_role]
GO
