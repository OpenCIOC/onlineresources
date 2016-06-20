SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMActivity_s]
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT	pr.*,
		prn.ActivityName, prn.ActivityDescription, prn.Notes
	FROM CIC_BT_ACT pr
	LEFT JOIN CIC_BT_ACT_Notes prn
		ON pr.BT_ACT_ID=prn.BT_ACT_ID AND prn.LangID=@@LANGID
WHERE pr.NUM=@NUM

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMActivity_s] TO [cioc_login_role]
GO
