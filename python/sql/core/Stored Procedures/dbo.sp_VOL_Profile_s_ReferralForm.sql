SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Profile_s_ReferralForm]
	@ProfileID [uniqueidentifier],
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

-- Profile ID given ?
IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID AND Active=1 AND Blocked=0) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @VolunteerProfileObjectName)
END ELSE BEGIN
	SELECT FirstName, LastName, Phone, Address, City, PostalCode, Province
		FROM VOL_Profile
	WHERE ProfileID=@ProfileID

END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_s_ReferralForm] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Profile_s_ReferralForm] TO [cioc_vol_search_role]
GO
