SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_GetInvolved_Enabled]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 27-Jun-2012
	Action:	NO ACTION REQUIRED
*/

SELECT MemberID, GetInvolvedUser, GetInvolvedToken, GetInvolvedSite FROM GBL_Agency
WHERE GetInvolvedUser IS NOT NULL AND GetInvolvedToken IS NOT NULL
GROUP BY MemberID, GetInvolvedUser, GetInvolvedToken, GetInvolvedSite


SET NOCOUNT OFF







GO
GRANT EXECUTE ON  [dbo].[sp_VOL_GetInvolved_Enabled] TO [cioc_maintenance_role]
GO
