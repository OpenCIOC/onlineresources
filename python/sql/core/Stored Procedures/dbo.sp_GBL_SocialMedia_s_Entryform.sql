SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_GBL_SocialMedia_s_Entryform]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 22-May-2012
	Action: NO ACTION REQUIRED
*/

SELECT 
	(SELECT sm.SM_ID AS "@ID",
		ISNULL(smn.Name,sm.DefaultName) AS '@Name',
		GeneralURL AS '@GeneralURL',
		IconURL16 AS '@Icon16',
		IconURL24 AS '@Icon24'
	FROM GBL_SocialMedia sm 
		LEFT JOIN GBL_SocialMedia_Name smn 
			ON sm.SM_ID=smn.SM_ID AND smn.LangID=@@LANGID 
	WHERE sm.Active=1 
	ORDER BY ISNULL(smn.Name,sm.DefaultName) 
FOR XML PATH('SM'),ROOT('SOCIAL_MEDIA'), TYPE) AS SOCIAL_MEDIA 

SET NOCOUNT OFF




GO


GRANT EXECUTE ON  [dbo].[sp_GBL_SocialMedia_s_Entryform] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_SocialMedia_s_Entryform] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_SocialMedia_s_Entryform] TO [cioc_vol_search_role]
GO
