SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_d_Unverified]
	@MemberID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@VolunteerProfileObjectName nvarchar(100)

SET @VolunteerProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Profile')

DELETE p
	FROM VOL_Profile p
WHERE Verified = 0 AND DATEDIFF(dd, CREATED_DATE, GetDate()) > 14 
	AND NOT EXISTS(SELECT * FROM VOL_OP_Referral r WHERE r.ProfileID=p.ProfileID)
	AND p.MemberID=@MemberID

EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VolunteerProfileObjectName, @ErrMsg

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_d_Unverified] TO [cioc_maintenance_role]
GO
