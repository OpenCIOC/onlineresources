SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_GBL_Community_Type_l_Admin] 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SELECT ct.Code, ct.Code + CASE WHEN ctn.Name IS NOT NULL THEN ' [' + ctn.Name + ']' ELSE '' END AS Name
	FROM dbo.GBL_Community_Type ct
	LEFT JOIN dbo.GBL_Community_Type_Name ctn
		ON ct.Code=ctn.Code AND ctn.LangID=@@LANGID
ORDER BY ct.Code

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_Type_l_Admin] TO [cioc_login_role]
GO
