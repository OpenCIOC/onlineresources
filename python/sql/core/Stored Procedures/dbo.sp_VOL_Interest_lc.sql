SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_VOL_Interest_lc]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

SELECT ai.AI_ID, ain.Name AS InterestName, COUNT(vo.VNUM) AS NumOpps
	FROM VOL_Interest ai
	INNER JOIN VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID AND ain.LangID=@@LANGID
	INNER JOIN VOL_OP_AI pr
		ON ai.AI_ID=pr.AI_ID
	INNER JOIN VOL_Opportunity vo
		ON pr.VNUM=vo.VNUM
			AND dbo.fn_VOL_RecordInView(vo.VNUM, @ViewType, @@LANGID, 1, GETDATE())=1
			AND (vo.DISPLAY_UNTIL IS NULL OR vo.DISPLAY_UNTIL > GETDATE())
GROUP BY ai.AI_ID, ain.Name
ORDER BY ain.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_lc] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_lc] TO [cioc_vol_search_role]
GO
