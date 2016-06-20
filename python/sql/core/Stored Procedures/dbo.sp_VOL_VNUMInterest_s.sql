SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMInterest_s]
	@VNUM varchar(10)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

SELECT ai.AI_ID, CASE WHEN ain.LangID=@@LANGID THEN ain.Name ELSE '[' + ain.Name + ']' END AS InterestName
	FROM VOL_Interest ai
	INNER JOIN VOL_Interest_Name ain
		ON ai.AI_ID=ain.AI_ID AND ain.LangID=(SELECT TOP 1 LangID FROM VOL_Interest_Name WHERE AI_ID=ain.AI_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN VOL_OP_AI pr
		ON ai.AI_ID=pr.AI_ID
WHERE VNUM = @VNUM
ORDER BY ain.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMInterest_s] TO [cioc_login_role]
GO
