SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_u_Q]
	@MemberID int,
	@EF_ID int,
	@MODIFIED_BY varchar(50),
	@QBy varchar(50),
	@QOwnerConflict smallint,
	@QImportSourceDbInfo bit,
	@QUnmappedPrivacySkipFields bit,
	@QPrivacyProfileConflict smallint,
	@QPublicConflict smallint,
	@QDeletedConflict smallint,
	@QPrivacyMap varchar(max),
	@QAutoAddPubs varchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.1
	Checked by: CL
	Checked on: 23-Feb-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@ImportEntryObjectName nvarchar(100),
		@MemberObjectName	nvarchar(100)

SET @ImportEntryObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Import File')
SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
	SET @MemberID = NULL
-- Import Entry exists ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_ImportEntry WHERE EF_ID=@EF_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@EF_ID AS varchar), @ImportEntryObjectName)
	SET @EF_ID = NULL
-- Import Entry belongs to Member ?
END ELSE IF EXISTS(SELECT * FROM CIC_ImportEntry WHERE EF_ID=@EF_ID AND MemberID<>@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE BEGIN
	IF @QUnmappedPrivacySkipFields IS NULL BEGIN
		SET @QUnmappedPrivacySkipFields = 0
	END

	IF @QBy IS NULL BEGIN
		UPDATE CIC_ImportEntry SET
			MODIFIED_DATE				= GETDATE(),
			MODIFIED_BY					= @MODIFIED_BY,
			QBy							= NULL,
			QDate						= NULL,
			QOwnerConflict				= NULL,
			QImportSourceDbInfo			= 0,
			QUnmappedPrivacySkipFields	= 0,
			QPrivacyProfileConflict		= NULL,
			QPublicConflict				= NULL,
			QDeletedConflict			= NULL,
			QAutoAddPubs				= NULL
		WHERE EF_ID = @EF_ID
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ImportEntryObjectName, @ErrMsg
		UPDATE CIC_ImportEntry_PrivacyProfile SET
			QPrivacyMap = NULL
		WHERE EF_ID = @EF_ID
			
	END ELSE BEGIN
		UPDATE CIC_ImportEntry SET
			MODIFIED_DATE				= GETDATE(),
			MODIFIED_BY					= @MODIFIED_BY,
			QBy							= @QBy,
			QDate						= GETDATE(),
			QOwnerConflict				= @QOwnerConflict,
			QImportSourceDbInfo			= @QImportSourceDbInfo,
			QUnmappedPrivacySkipFields	= @QUnmappedPrivacySkipFields,
			QPrivacyProfileConflict		= @QPrivacyProfileConflict,
			QPublicConflict				= @QPublicConflict,
			QDeletedConflict			= @QDeletedConflict,
			QAutoAddPubs				= @QAutoAddPubs
		
		WHERE EF_ID = @EF_ID
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ImportEntryObjectName, @ErrMsg
		UPDATE CIC_ImportEntry_PrivacyProfile SET
			QPrivacyMap = RightID
		FROM CIC_ImportEntry_PrivacyProfile ipp
			INNER JOIN dbo.fn_GBL_ParseIntIDPairList(@QPrivacyMap, ';', ',') ipl
				ON ipl.LeftID = ipp.ER_ID
			INNER JOIN GBL_PrivacyProfile pp
				ON ipl.RightID = pp.ProfileID
		WHERE EF_ID = @EF_ID

	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_u_Q] TO [cioc_login_role]
GO
