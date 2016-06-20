SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_SocialMedia_s]
	@SM_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT sm.*,
	(SELECT COUNT(*) FROM GBL_BT_SM WHERE SM_ID=sm.SM_ID) AS UsageCount
	FROM GBL_SocialMedia sm
WHERE SM_ID = @SM_ID

SELECT smn.*,
	(SELECT Culture FROM STP_Language WHERE LangID=smn.LangID) AS Culture
FROM GBL_SocialMedia_Name smn
WHERE SM_ID=@SM_ID

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SocialMedia_s] TO [cioc_login_role]
GO
