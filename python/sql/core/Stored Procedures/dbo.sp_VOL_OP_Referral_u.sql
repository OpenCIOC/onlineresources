SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_OP_Referral_u]
	@REF_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@MemberID [int],
	@VNUM varchar(10),
	@ReferralDate [smalldatetime],
	@ViewType [int],
	@AccessURL [varchar](160),
	@FollowUpFlag [bit],
	@ProfileID [uniqueidentifier],
	@VolunteerName [nvarchar](100),
	@VolunteerPhone [nvarchar](100),
	@VolunteerEmail [varchar](60),
	@VolunteerAddress [nvarchar](100),
	@VolunteerCity [nvarchar](100),
	@VolunteerPostalCode [varchar](100),
	@VolunteerNotes [nvarchar](4000),
	@NotifyOrgType [int],
	@NotifyOrgDate [smalldatetime],
	@VolunteerContactType [int],
	@VolunteerContactDate [smalldatetime],
	@SuccessfulPlacement [bit],
	@OutcomeNotes [nvarchar](4000),
	@ErrMsg [varchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE @MemberObjectName	nvarchar(100),
		@NameObjectName nvarchar(100),	
		@OpportunityObjectName nvarchar(100),
		@ProfileObjectName nvarchar(100),
		@ReferralObjectName nvarchar(100),
		@VolunteerObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')
SET @OpportunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Opportunity')
SET @ReferralObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer Referral')
SET @VolunteerObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Volunteer')

SET @AccessURL = RTRIM(LTRIM(@AccessURL))
IF @AccessURL = '' SET @AccessURL = NULL
SET @VolunteerName = RTRIM(LTRIM(@VolunteerName))
IF @VolunteerName = '' SET @VolunteerName = NULL
SET @VolunteerPhone = RTRIM(LTRIM(@VolunteerPhone))
IF @VolunteerPhone = '' SET @VolunteerPhone = NULL
SET @VolunteerEmail = RTRIM(LTRIM(@VolunteerEmail))
IF @VolunteerEmail = '' SET @VolunteerEmail = NULL
SET @VolunteerAddress = RTRIM(LTRIM(@VolunteerAddress))
IF @VolunteerAddress = '' SET @VolunteerAddress = NULL
SET @VolunteerCity = RTRIM(LTRIM(@VolunteerCity))
IF @VolunteerCity = '' SET @VolunteerCity = NULL
SET @VolunteerPostalCode = RTRIM(LTRIM(@VolunteerPostalCode))
IF @VolunteerPostalCode = '' SET @VolunteerPostalCode = NULL
SET @VolunteerNotes = RTRIM(LTRIM(@VolunteerNotes))
IF @VolunteerNotes = '' SET @VolunteerNotes = NULL

IF @ReferralDate IS NULL SET @ReferralDate = GETDATE()

IF @FollowUpFlag IS NULL SET @FollowUpFlag = 0

IF @ViewType IS NOT NULL AND NOT EXISTS (SELECT * FROM VOL_View WHERE ViewType = @ViewType) SET @ViewType = NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Opportunity ID given ?
END ELSE IF @VNUM IS NULL BEGIN
	SET @Error = 2
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OpportunityObjectName, NULL)
-- Opportunity ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM VOL_Opportunity WHERE VNUM=@VNUM) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@VNUM AS varchar), @OpportunityObjectName)
-- Volunteer Name given ?
END ELSE IF @VolunteerName IS NULL BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @VolunteerObjectName)
-- Volunteer contact info given ?
END ELSE IF @VolunteerPhone IS NULL AND @VolunteerEmail IS NULL AND @VolunteerAddress IS NULL BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Contact'), @VolunteerObjectName)
-- Referral ID exists ?
END ELSE IF @REF_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM VOL_OP_Referral WHERE REF_ID=@REF_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@REF_ID AS varchar), @ReferralObjectName)
-- Profile ID exists ?
END ELSE IF @ProfileID IS NOT NULL AND NOT EXISTS (SELECT * FROM VOL_Profile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @ProfileObjectName)
END ELSE BEGIN
	IF @REF_ID IS NOT NULL BEGIN
		UPDATE VOL_OP_Referral SET
			MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY,
			ReferralDate		= @ReferralDate,
			FollowUpFlag		= @FollowUpFlag,
			VolunteerName		= @VolunteerName,
			VolunteerPhone		= @VolunteerPhone,
			VolunteerEmail		= @VolunteerEmail,
			VolunteerAddress	= @VolunteerAddress,
			VolunteerCity		= @VolunteerCity,
			VolunteerPostalCode	= @VolunteerPostalCode,
			VolunteerNotes		= @VolunteerNotes,
			NotifyOrgType		= @NotifyOrgType,
			NotifyOrgDate		= @NotifyOrgDate,
			VolunteerContactType	= @VolunteerContactType,
			VolunteerContactDate	= @VolunteerContactDate,
			SuccessfulPlacement	= @SuccessfulPlacement,
			OutcomeNotes		= @OutcomeNotes
		WHERE REF_ID = @REF_ID
	END ELSE BEGIN
		INSERT INTO VOL_OP_Referral (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			VNUM,
			ReferralDate,
			ViewType,
			AccessURL,
			LangID,
			FollowUpFlag,
			ProfileID,
			VolunteerName,
			VolunteerPhone,
			VolunteerEmail,
			VolunteerAddress,
			VolunteerCity,
			VolunteerPostalCode,
			VolunteerNotes,
			NotifyOrgType,
			NotifyOrgDate,
			VolunteerContactType,
			VolunteerContactDate,
			SuccessfulPlacement,
			OutcomeNotes
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@VNUM,
			@ReferralDate,
			@ViewType,
			@AccessURL,
			@@LANGID,
			@FollowUpFlag,
			@ProfileID,
			@VolunteerName,
			@VolunteerPhone,
			@VolunteerEmail,
			@VolunteerAddress,
			@VolunteerCity,
			@VolunteerPostalCode,
			@VolunteerNotes,
			@NotifyOrgType,
			@NotifyOrgDate,
			@VolunteerContactType,
			@VolunteerContactDate,
			@SuccessfulPlacement,
			@OutcomeNotes
		)
		SET @REF_ID = SCOPE_IDENTITY() 
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ReferralObjectName, @ErrMsg OUTPUT
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_u] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_OP_Referral_u] TO [cioc_vol_search_role]
GO
