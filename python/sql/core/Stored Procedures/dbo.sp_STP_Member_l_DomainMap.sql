
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_Member_l_DomainMap]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action: NO ACTION REQUIRED
*/

SELECT m.*,
		 CASE WHEN m.FullSSLCompatible=1 AND ISNULL(
			(
				SELECT t.FullSSLCompatible_Cache
				FROM CIC_View vw  INNER JOIN GBL_Template t
					ON t.Template_ID = vw.Template 
				WHERE vw.ViewType = ISNULL(m.CICViewType, (SELECT DefaultViewCIC FROM STP_Member WHERE MemberID=m.MemberID))
			), 0)= 1 THEN 1 ELSE 0 END AS DefaultViewFullSSLCompatibleCIC,
		 CASE WHEN m.FullSSLCompatible=1 AND ISNULL(
			(
				SELECT t.FullSSLCompatible_Cache
				FROM VOL_View vw  INNER JOIN GBL_Template t
					ON t.Template_ID = vw.Template 
				WHERE vw.ViewType = ISNULL(m.VOLViewType, (SELECT DefaultViewVOL FROM STP_Member WHERE MemberID=m.MemberID))
			), 0)= 1 THEN 1 ELSE 0 END AS DefaultViewFullSSLCompatibleVOL
	FROM GBL_View_DomainMap m

SET NOCOUNT OFF





GO

GRANT EXECUTE ON  [dbo].[sp_STP_Member_l_DomainMap] TO [cioc_login_role]
GO
