SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[sp_STP_OfflineTools_Domains]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: CL
	Checked on: 25-Feb-2013
	Action:	NO ACTION REQUIRED
*/

SELECT MemberID, SecondaryName, DomainName
FROM GBL_View_DomainMap
ORDER BY MemberID, SecondaryName, CASE WHEN RIGHT(DomainName, 8) = '.cioc.ca' AND (LEN(DomainName)-LEN(REPLACE(DomainName, '.', '')) = 2) THEN 0 ELSE 1 END, DomainName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_STP_OfflineTools_Domains] TO [cioc_maintenance_role]
GO
