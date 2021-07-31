SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExportProfile_i]
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@ProfileName nvarchar(50),
	@ProfileID int OUTPUT,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ProfileObjectName nvarchar(100),
		@NameObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')

DECLARE @CopyProfileID	int
SET @CopyProfileID = @ProfileID

SET @ProfileName = RTRIM(LTRIM(@ProfileName))

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile Name given ?
END ELSE IF @ProfileName IS NULL OR @ProfileName = '' BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @ProfileObjectName)
-- Copy Profile exists ?
END ELSE IF @CopyProfileID IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_ExportProfile WHERE ProfileID=@CopyProfileID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CopyProfileID AS varchar), @ProfileObjectName)
-- Copy Profile belongs to Member ?
END ELSE IF @CopyProfileID IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_ExportProfile WHERE ProfileID=@CopyProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Name is not already in use ?
END ELSE IF EXISTS (SELECT * FROM CIC_ExportProfile_Description WHERE Name=@ProfileName AND MemberID_Cache=@MemberID) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileName, @NameObjectName)
END ELSE BEGIN
	IF @CopyProfileID IS NULL BEGIN
		INSERT INTO CIC_ExportProfile (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			SubmitChangesToAccessURL
		)
		SELECT
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			MemberID,
			BaseURLCIC
		FROM STP_Member
		WHERE MemberID=@MemberID
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
		SELECT @ProfileID = SCOPE_IDENTITY()
		
		IF @Error=0 AND @ProfileID IS NOT NULL BEGIN
			INSERT INTO CIC_ExportProfile_Description (
				MemberID_Cache,
				ProfileID,
				LangID,
				Name,
				SourceDbName,
				SourceDbURL
			)
			SELECT
				mem.MemberID,
				@ProfileID,
				sl.LangID,
				@ProfileName,
				DatabaseNameCIC,
				ISNULL((SELECT CASE WHEN m.FullSSLCompatible=1 AND t.FullSSLCompatible_Cache=1 THEN 'https://' ELSE 'http://' END FROM GBL_View_DomainMap m INNER JOIN CIC_View vw ON vw.ViewType = ISNULL(m.CICViewType, mem.DefaultViewCIC) INNER JOIN GBL_Template t ON t.Template_ID = vw.Template WHERE m.DomainName=mem.BaseURLCIC), 'http://')
				+ BaseURLCIC + '/?Ln=' + sl.Culture
			FROM STP_Member mem
			INNER JOIN STP_Member_Description memd
				ON mem.MemberID=memd.MemberID
			INNER JOIN STP_Language sl
				ON memd.LangID=sl.LangID AND sl.Active=1
			WHERE mem.MemberID=@MemberID

			EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
			
			IF @Error<>0 BEGIN
				DELETE FROM CIC_ExportProfile WHERE ProfileID=@ProfileID
			END
		END
	END ELSE BEGIN
		INSERT INTO CIC_ExportProfile (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			SubmitChangesToAccessURL,
			IncludePrivacyProfiles,
			ConvertLine1Line2Addresses
		)
		SELECT
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			SubmitChangesToAccessURL,
			IncludePrivacyProfiles,
			ConvertLine1Line2Addresses
		FROM CIC_ExportProfile
		WHERE ProfileID = @CopyProfileID
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
		SELECT @ProfileID = SCOPE_IDENTITY()
		
		IF @Error=0 AND @ProfileID IS NOT NULL BEGIN
			INSERT INTO CIC_ExportProfile_Description (
				ProfileID,
				LangID,
				MemberID_Cache,
				Name,
				SourceDbName,
				SourceDbURL
			) SELECT
				@ProfileID,
				LangID,
				@MemberID,
				@ProfileName,
				SourceDbName,
				SourceDbURL
			FROM CIC_ExportProfile_Description epn
			WHERE epn.ProfileID=@CopyProfileID
			EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
		
			INSERT INTO CIC_ExportProfile_Fld (ProfileID, FieldID)
				SELECT @ProfileID AS ProfileID, FieldID
					FROM CIC_ExportProfile_Fld
				WHERE ProfileID = @CopyProfileID
			EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
			
			INSERT INTO CIC_ExportProfile_Dist (ProfileID, DST_ID)
				SELECT @ProfileID AS ProfileID, DST_ID
					FROM CIC_ExportProfile_Dist
				WHERE ProfileID = @CopyProfileID
			EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
			
			INSERT INTO CIC_ExportProfile_Pub (ProfileID, PB_ID, IncludeHeadings, IncludeDescription)
				SELECT @ProfileID AS ProfileID, PB_ID, IncludeHeadings, IncludeDescription
					FROM CIC_ExportProfile_Pub
				WHERE ProfileID = @CopyProfileID
			EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
			
			INSERT INTO  CIC_View_ExportProfile (ProfileID,ViewType)
				SELECT @ProfileID AS ProfileID, ViewType
					FROM CIC_View_ExportProfile
				WHERE ProfileID = @CopyProfileID
			EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
		END		
	END

END

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_ExportProfile_i] TO [cioc_login_role]
GO
