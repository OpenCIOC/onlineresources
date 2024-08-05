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

SELECT ppd.PageTitle, ppd.DefaultMsg
	FROM dbo.GBL_PrintProfile pp
	INNER JOIN dbo.GBL_PrintProfile_Description ppd
		ON pp.ProfileID=ppd.ProfileID AND ppd.LangID=@@LangID
WHERE (pp.Domain = @Domain)
	AND (pp.ProfileID = @ProfileID)
	AND (
		(pp.Domain=1 AND EXISTS(SELECT * FROM dbo.CIC_View_PrintProfile vw WHERE vw.ViewType=@ViewType AND vw.ProfileID=pp.ProfileID))
		OR (pp.Domain=2 AND EXISTS(SELECT * FROM dbo.VOL_View_PrintProfile vw WHERE vw.ViewType=@ViewType AND vw.ProfileID=pp.ProfileID))
	)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrintProfile_Msg_s] TO [cioc_login_role]
GO
