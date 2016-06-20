
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Interest_s_FormLists]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.1
	Checked by: CL
	Checked on: 18-Oct-2014
	Action: NO ACTION REQUIRED
*/

SELECT ig.IG_ID, ign.Name
	FROM VOL_InterestGroup ig
	INNER JOIN VOL_InterestGroup_Name ign
		ON ign.IG_ID = ig.IG_ID AND ign.LangID=(SELECT TOP 1 LangID FROM VOL_InterestGroup_Name WHERE IG_ID=ign.IG_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END,LangID)
	ORDER BY ign.Name

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_s_FormLists] TO [cioc_login_role]
GO
