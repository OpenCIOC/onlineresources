SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_GeneralHeading_Group_l]
	@PB_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 06-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT g.GroupID, gn.Name
	FROM CIC_GeneralHeading_Group g
	INNER JOIN CIC_GeneralHeading_Group_Name gn
		ON g.GroupID=gn.GroupID AND LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Group_Name WHERE GroupID=g.GroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE PB_ID = @PB_ID

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_GeneralHeading_Group_l] TO [cioc_login_role]
GO
