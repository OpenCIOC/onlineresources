
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_View_Fb_s]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 04-May-2016
	Action: NO ACTION REQUIRED
*/

SELECT DataUseAuth, DataUseAuthPhone, TermsOfUseURL, FeedbackBlurb, InclusionPolicy
	FROM VOL_View vw
	LEFT JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType AND vwd.LangID=@@LANGID
WHERE vw.ViewType = @ViewType

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_VOL_View_Fb_s] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_View_Fb_s] TO [cioc_vol_search_role]
GO
