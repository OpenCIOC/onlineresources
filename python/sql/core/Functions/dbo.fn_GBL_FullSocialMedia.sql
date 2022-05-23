SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GBL_FullSocialMedia](
	@Value xml
)
RETURNS xml WITH EXECUTE AS CALLER
AS 
BEGIN 

DECLARE	@returnStr xml

SET @returnStr = (SELECT 
	(SELECT sm.SM_ID AS "@ID", 
		ISNULL(smn.Name,sm.DefaultName) AS '@Name', 
		IconURL16 AS '@Icon16',
		IconURL24 AS '@Icon24',
		GeneralURL AS '@GeneralURL', 
		URL AS '@URL',
		Proto AS '@Proto'
	FROM GBL_SocialMedia sm 
		INNER JOIN (SELECT N.value('@SM_ID', 'int') AS SM_ID, N.value('@URL', 'nvarchar(255)') AS URL, N.value('@Proto', 'varchar(10)') AS Proto FROM @Value.nodes('//SM') AS T(N)) AS pr 
			ON pr.SM_ID=sm.SM_ID
		LEFT JOIN GBL_SocialMedia_Name smn 
			ON sm.SM_ID=smn.SM_ID AND smn.LangID=@@LANGID
	WHERE pr.SM_ID IS NOT NULL
	ORDER BY ISNULL(smn.Name,sm.DefaultName) FOR XML PATH('SM'), TYPE) FOR XML PATH('SOCIAL_MEDIA'),TYPE) 

RETURN @returnStr

END



GO



GRANT EXECUTE ON  [dbo].[fn_GBL_FullSocialMedia] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullSocialMedia] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullSocialMedia] TO [cioc_vol_search_role]
GO
