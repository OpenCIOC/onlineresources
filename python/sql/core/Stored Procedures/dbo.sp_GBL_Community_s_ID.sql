SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Community_s_ID]
	@Community nvarchar(200),
	@CM_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT TOP 1 @CM_ID=cm.CM_ID
	FROM GBL_Community cm
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
WHERE cmn.Name=@Community
	AND cmn.LangID = (SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_s_ID] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Community_s_ID] TO [cioc_login_role]
GO
