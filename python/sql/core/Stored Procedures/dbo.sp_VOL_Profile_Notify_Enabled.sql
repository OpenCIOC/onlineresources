SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Profile_Notify_Enabled]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 21-Apr-2012
	Action:	NO ACTION REQUIRED
*/

SELECT MemberID, UseVolunteerProfiles FROM STP_Member

SET NOCOUNT OFF






GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_Notify_Enabled] TO [cioc_maintenance_role]
GO
