SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_SocialMedia_l]
	@Inactive bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT sm.SM_ID, ISNULL(smn.Name,sm.DefaultName) AS SocialMediaName
	FROM GBL_SocialMedia sm
	LEFT JOIN GBL_SocialMedia_Name smn
		ON sm.SM_ID=smn.SM_ID AND smn.LangID=@@LANGID
WHERE @Inactive=1 OR sm.Active=1
ORDER BY ISNULL(smn.Name,sm.DefaultName)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SocialMedia_l] TO [cioc_login_role]
GO
