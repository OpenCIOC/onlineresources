SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrintProfile_Msg_s]
	@ProfileID [int],
	@ViewType int,
	@Domain [tinyint]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT DefaultMsg
	FROM GBL_PrintProfile pp
	INNER JOIN GBL_PrintProfile_Description ppd
		ON pp.ProfileID=ppd.ProfileID AND ppd.LangID=@@LangID
WHERE (Domain = @Domain)
	AND (pp.ProfileID = @ProfileID)
	AND (
		(Domain=1 AND EXISTS(SELECT * FROM CIC_View_PrintProfile vw WHERE vw.ViewType=@ViewType AND vw.ProfileID=pp.ProfileID))
		OR (Domain=2 AND EXISTS(SELECT * FROM VOL_View_PrintProfile vw WHERE vw.ViewType=@ViewType AND vw.ProfileID=pp.ProfileID))
	)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrintProfile_Msg_s] TO [cioc_login_role]
GO
