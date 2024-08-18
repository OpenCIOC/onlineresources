SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Community_l_Children]
	@CM_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SELECT cm.CM_ID,
	ISNULL(cmn.Display,cmn.Name) AS Community,
	CASE WHEN EXISTS(SELECT * FROM dbo.GBL_Community_ParentList cpl WHERE cpl.Parent_CM_ID=cm.CM_ID)
		THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('Community')
		ELSE NULL
		END AS ChildCommunityType
	FROM dbo.GBL_Community cm
INNER JOIN dbo.GBL_Community_Name cmn
	ON cm.CM_ID=cmn.CM_ID
		AND cmn.LangID=(SELECT TOP 1 LangID FROM dbo.GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE cm.ParentCommunity = @CM_ID
ORDER BY cmn.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_l_Children] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_l_Children] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_l_Children] TO [cioc_vol_search_role]
GO
