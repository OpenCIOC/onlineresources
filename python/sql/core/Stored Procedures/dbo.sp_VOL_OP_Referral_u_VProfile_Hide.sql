SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_Referral_u_VProfile_Hide]
	@ProfileID [uniqueidentifier],
	@REF_ID int,
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

DECLARE	@VolunteerProfileObjectName nvarchar(100),
		@ReferralObjectName nvarchar(100)

SET @VolunteerProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Profile')
SET @ReferralObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Referral')

-- Profile ID given ?
IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VolunteerProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @VolunteerProfileObjectName)
-- Referral ID given ?
END ELSE IF @REF_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ReferralObjectName, NULL)
-- Referral exists ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_OP_Referral WHERE ProfileID=@ProfileID AND REF_ID=@REF_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@REF_ID AS varchar), @ReferralObjectName)
END ELSE BEGIN
	UPDATE VOL_OP_Referral
		SET VolunteerHideReferral=1
	WHERE REF_ID=@REF_ID AND ProfileID=@ProfileID
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_u_VProfile_Hide] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_u_VProfile_Hide] TO [cioc_vol_search_role]
GO
