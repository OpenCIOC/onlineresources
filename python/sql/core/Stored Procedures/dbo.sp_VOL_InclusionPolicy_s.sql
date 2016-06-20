SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_InclusionPolicy_s]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT ip.PolicyText
	FROM VOL_View vw
	INNER JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType AND LangID=@@LANGID
	INNER JOIN GBL_InclusionPolicy ip
		ON vwd.InclusionPolicy=ip.InclusionPolicyID
WHERE vw.ViewType=@ViewType

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_InclusionPolicy_s] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_InclusionPolicy_s] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_InclusionPolicy_s] TO [cioc_vol_search_role]
GO
