
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GBL_Agency_u]
	@AgencyID int OUTPUT,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@AgencyCode char(3),
	@RecordOwnerCIC bit,
	@UpdateEmailCIC varchar(60),
	@UpdatePhoneCIC varchar(60),
	@InquiryPhoneCIC varchar(60),
	@AgencyNUMCIC varchar(8),
	@RecordOwnerVOL bit,
	@UpdateEmailVOL varchar(60),
	@UpdatePhoneVOL varchar(60),
	@InquiryPhoneVOL varchar(60),
	@AgencyNUMVOL varchar(8),
	@EnforceReqFields bit,
	@UpdateAccountDefault bit,
	@UpdatePasswordDefault bit,
	@UpdateAccountEmail varchar(60),
	@UpdateAccountLangID smallint,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 10-Mar-2016
	Action: NO ACTION REQUIRED
	Notes: SHOULD UPDATE MEMBER ID BE USED FOR GLOBAL SUPER USER USER?
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@AgencyObjectName nvarchar(100),
		@OrganizationObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @AgencyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency')
SET @OrganizationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')

SET @AgencyCode = RTRIM(LTRIM(@AgencyCode))
IF @AgencyCode = '' SET @AgencyCode = NULL
SET @UpdateEmailCIC = RTRIM(LTRIM(@UpdateEmailCIC))
IF @UpdateEmailCIC = '' SET @UpdateEmailCIC = NULL
SET @UpdatePhoneCIC = RTRIM(LTRIM(@UpdatePhoneCIC))
IF @UpdatePhoneCIC = '' SET @UpdatePhoneCIC = NULL
SET @InquiryPhoneCIC = RTRIM(LTRIM(@InquiryPhoneCIC))
IF @InquiryPhoneCIC = '' SET @InquiryPhoneCIC = NULL
SET @AgencyNUMCIC = RTRIM(LTRIM(@AgencyNUMCIC))
IF @AgencyNUMCIC = '' SET @AgencyNUMCIC = NULL
SET @AgencyNUMVOL = RTRIM(LTRIM(@AgencyNUMVOL))
IF @AgencyNUMVOL = '' SET @AgencyNUMVOL = NULL
SET @UpdateEmailVOL = RTRIM(LTRIM(@UpdateEmailVOL))
IF @UpdateEmailVOL = '' SET @UpdateEmailVOL = NULL
SET @UpdatePhoneVOL = RTRIM(LTRIM(@UpdatePhoneVOL))
IF @UpdatePhoneVOL = '' SET @UpdatePhoneVOL = NULL
SET @InquiryPhoneVOL = RTRIM(LTRIM(@InquiryPhoneVOL))
IF @InquiryPhoneVOL = '' SET @InquiryPhoneVOL = NULL
SET @UpdateAccountEmail = RTRIM(LTRIM(@UpdateAccountEmail))
IF @UpdateAccountEmail = '' SET @UpdateAccountEmail = NULL

IF @UpdateAccountLangID IS NULL BEGIN
	SELECT @UpdateAccountLangID = DefaultLangID FROM STP_Member WHERE MemberID=@MemberID
END 

IF EXISTS(SELECT * FROM dbo.GBL_BaseTable WHERE RECORD_OWNER=@AgencyCode) BEGIN
	SET @RecordOwnerCIC=1
END

IF EXISTS(SELECT * FROM dbo.VOL_Opportunity WHERE RECORD_OWNER=@AgencyCode) BEGIN
	SET @RecordOwnerVOL=1
END

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Agency Code given ?
END ELSE IF @AgencyCode IS NULL BEGIN
	SET @Error = 4 -- No Code Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyObjectName, NULL)
-- Agency ID exists ?
END ELSE IF @AgencyID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Agency WHERE AgencyID=@AgencyID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@AgencyID AS varchar), @AgencyObjectName)
-- Agency belongs to Member, or Global Super User ?
END ELSE IF @AgencyID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Agency WHERE AgencyID=@AgencyID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Agency Code in proper format ?	
END ELSE IF LEN(@AgencyCode) <> 3 BEGIN
	SET @Error = 5 -- Invalid Code
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyCode, @AgencyObjectName)
-- Agency Code in use ?
END ELSE IF EXISTS(SELECT * FROM GBL_Agency WHERE (@AgencyID IS NULL OR AgencyID<>@AgencyID) AND AgencyCode=@AgencyCode) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyCode, cioc_shared.dbo.fn_SHR_STP_ObjectName('Code'))
-- Record NUM provided if records are associated with this Agency ?
END ELSE IF EXISTS(SELECT * FROM GBL_BaseTable WHERE RECORD_OWNER=@AgencyCode) AND @AgencyNUMCIC IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Record #'), @AgencyObjectName)
-- Record NUM provided if records are associated with this Agency ?
END ELSE IF EXISTS(SELECT * FROM VOL_Opportunity WHERE RECORD_OWNER=@AgencyCode) AND @AgencyNUMVOL IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Record #'), @AgencyObjectName)
-- Update Email provided if records are associated with this Agency ?
END ELSE IF EXISTS(SELECT * FROM GBL_BaseTable WHERE RECORD_OWNER=@AgencyCode) AND @UpdateEmailCIC IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Email'), @AgencyObjectName)
-- Update Email provided if records are associated with this Agency ?
END ELSE IF EXISTS(SELECT * FROM VOL_Opportunity WHERE RECORD_OWNER=@AgencyCode) AND @UpdateEmailVOL IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Email'), @AgencyObjectName)
-- Update Email provided if records are associated with this Agency ?
END ELSE IF @UpdateAccountEmail IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Email') + cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') + cioc_shared.dbo.fn_SHR_STP_ObjectName('User Account'), @AgencyObjectName)
-- Agency detail record exists ?
END ELSE IF @AgencyNUMCIC IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_BaseTable WHERE NUM=@AgencyNUMCIC) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyNUMCIC, @OrganizationObjectName)
-- Agency detail record exists ?
END ELSE IF @AgencyNUMVOL IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_BaseTable WHERE NUM=@AgencyNUMVOL) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyNUMVOL, @OrganizationObjectName)
END ELSE BEGIN
	IF @AgencyID IS NOT NULL BEGIN
		UPDATE GBL_Agency 
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
	  		AgencyCode			= @AgencyCode,
			RecordOwnerCIC		= @RecordOwnerCIC,
			UpdateEmailCIC		= @UpdateEmailCIC,
			UpdatePhoneCIC		= @UpdatePhoneCIC,
			InquiryPhoneCIC		= @InquiryPhoneCIC,
			AgencyNUMCIC		= @AgencyNUMCIC,
			RecordOwnerVOL		= @RecordOwnerVOL,
			UpdateEmailVOL		= @UpdateEmailVOL,
			UpdatePhoneVOL		= @UpdatePhoneVOL,
			InquiryPhoneVOL		= @InquiryPhoneVOL,
			AgencyNUMVOL		= @AgencyNUMVOL,
			EnforceReqFields	= ISNULL(@EnforceReqFields,EnforceReqFields),
			UpdateAccountDefault	= ISNULL(@UpdateAccountDefault,UpdateAccountDefault),
			UpdatePasswordDefault	= ISNULL(@UpdatePasswordDefault,UpdatePasswordDefault),
			UpdateAccountEmail	= @UpdateAccountEmail,
			UpdateAccountLangID	= @UpdateAccountLangID
		WHERE  AgencyID = @AgencyID
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
	END ELSE BEGIN
		INSERT INTO GBL_Agency (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			AgencyCode,
			RecordOwnerCIC,
			UpdateEmailCIC,
			UpdatePhoneCIC,
			InquiryPhoneCIC	,
			AgencyNUMCIC,
			RecordOwnerVOL,
			UpdateEmailVOL,
			UpdatePhoneVOL,
			InquiryPhoneVOL,
			AgencyNUMVOL,
			EnforceReqFields,
			UpdateAccountDefault,
			UpdatePasswordDefault,
			UpdateAccountEmail,
			UpdateAccountLangID
		)
	 	VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@AgencyCode,
			@RecordOwnerCIC,
			@UpdateEmailCIC,
			@UpdatePhoneCIC,
			@InquiryPhoneCIC	,
			@AgencyNUMCIC,
			@RecordOwnerVOL,
			@UpdateEmailVOL,
			@UpdatePhoneVOL,
			@InquiryPhoneVOL,
			@AgencyNUMVOL,
			ISNULL(@EnforceReqFields,0),
			ISNULL(@UpdateAccountDefault,1),
			ISNULL(@UpdatePasswordDefault,1),
			@UpdateAccountEmail,
			@UpdateAccountLangID
		)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @OrganizationObjectName, @ErrMsg
		SET @AgencyID = SCOPE_IDENTITY()
	END
END

RETURN @Error

SET NOCOUNT OFF

GO

GRANT EXECUTE ON  [dbo].[sp_GBL_Agency_u] TO [cioc_login_role]
GO
