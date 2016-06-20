SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_DisplayCommunity](
	@CM_ID int,
	@LangID smallint
)
RETURNS nvarchar(200) WITH EXECUTE AS CALLER
AS
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Community	nvarchar(200)

SELECT @Community = ISNULL(cmn.Display,cmn.Name)
	FROM GBL_Community cm
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID = (SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
WHERE cm.CM_ID = @CM_ID

RETURN @Community

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayCommunity] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayCommunity] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayCommunity] TO [cioc_vol_search_role]
GO
