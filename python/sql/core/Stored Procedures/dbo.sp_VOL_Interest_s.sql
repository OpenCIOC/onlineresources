SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Interest_s]
	@AI_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT ai.*,
	(SELECT COUNT(*) FROM VOL_OP_AI WHERE AI_ID=ai.AI_ID) AS UsageCount
	FROM VOL_Interest ai
WHERE AI_ID = @AI_ID

SELECT ain.*,
	(SELECT Culture FROM STP_Language WHERE LangID=ain.LangID) AS Culture
FROM VOL_Interest_Name ain
WHERE AI_ID=@AI_ID

SELECT IG_ID 
	FROM VOL_AI_IG
WHERE AI_ID=@AI_ID

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_s] TO [cioc_login_role]
GO
