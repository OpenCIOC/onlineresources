SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GBL_Community_Search_rst](
	@CMList varchar(max)
)
RETURNS @communitiesTable TABLE (
	[CM_ID] int NOT NULL PRIMARY KEY
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 22-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @startTable TABLE (
	[CM_ID] int NOT NULL PRIMARY KEY
)

INSERT INTO @startTable
	SELECT DISTINCT cm.CM_ID
	FROM fn_GBL_ParseIntIDList(@CMList, ',') tm
	INNER JOIN GBL_Community cm
		ON tm.itemID = cm.CM_ID
		
INSERT INTO @communitiesTable
	-- Given Communities (in the given group(s))
	SELECT CM_ID
		FROM @startTable
	-- Children of Given Communities
	UNION SELECT cmpl.CM_ID
		FROM GBL_Community_ParentList cmpl
		INNER JOIN @startTable tm
			ON cmpl.Parent_CM_ID=tm.CM_ID
	-- Parents of Given Communities
	UNION SELECT Parent_CM_ID
		FROM GBL_Community_ParentList cmpl
		INNER JOIN @startTable tm
			ON cmpl.CM_ID=tm.CM_ID
RETURN

END


GO
GRANT SELECT ON  [dbo].[fn_GBL_Community_Search_rst] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_GBL_Community_Search_rst] TO [cioc_login_role]
GO
