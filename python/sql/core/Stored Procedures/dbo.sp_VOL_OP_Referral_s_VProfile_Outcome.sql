SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_Referral_s_VProfile_Outcome]
	@ProfileID [uniqueidentifier],
	@REF_ID [int],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
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
	SELECT	rf.REF_ID,
			rf.ReferralDate,
			rf.VolunteerOutcomeNotes,
			rf.VolunteerSuccessfulPlacement,
			vod.POSITION_TITLE
		FROM VOL_OP_Referral rf
		INNER JOIN VOL_Opportunity_Description vod
			ON rf.VNUM=vod.VNUM AND vod.LangID=(SELECT TOP 1 LangID FROM VOL_Opportunity_Description WHERE vod.VNUM=VNUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE REF_ID=@REF_ID
		AND ProfileID=@ProfileID
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_s_VProfile_Outcome] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_s_VProfile_Outcome] TO [cioc_vol_search_role]
GO
