
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_SharingProfile_u]
	@ProfileID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@MemberID [int],
	@ShareMemberID int,
	@CanUseAnyView bit,
	@CanUpdateRecords bit,
	@CanUsePrint bit,
	@CanUseExport bit,
	@CanUpdatePubs bit,
	@CanViewFeedback bit,
	@CanViewPrivate bit,
	@RevocationPeriod smallint,
	@NotifyEmailAddresses varchar(1000),
	@Descriptions xml,
	@Views [xml],
	@Fields [xml],
	@EditLangs varchar(1000),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 05-Mar-2015
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE @OnlyAdd bit

SELECT @OnlyAdd = CASE WHEN Active=1 OR ReadyToAccept=1 OR RevokedDate IS NOT NULL THEN 1 ELSE 0 END 
FROM GBL_SharingProfile
WHERE ProfileID=@ProfileID

IF @OnlyAdd IS NULL SET @OnlyAdd=0

IF @OnlyAdd = 1 BEGIN
SELECT @CanUseAnyView=CASE WHEN @CanUseAnyView=1 THEN 1 ELSE CanUseAnyView END FROM GBL_SharingProfile WHERE ProfileID=@ProfileID
END

DECLARE	@MemberObjectName	nvarchar(100),
		@SharingProfileObjectName nvarchar(100),
		@FieldObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SharingProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Sharing Profile')
SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Name nvarchar(100) NULL
)

DECLARE @ViewTable TABLE (
	ViewType int NOT NULL
)

DECLARE @FieldTable TABLE (
	FieldID int NOT NULL
)

DECLARE @EditLangTable TABLE (
	LangID smallint NOT NULL
)

DECLARE @UsedNamesDesc nvarchar(max),
		@BadCulturesDesc nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Name
)
SELECT
	N.query('Culture').value('/', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.query('Culture').value('/', 'varchar(5)') AND Active=1) AS LangID,
	CASE WHEN N.exist('Name')=1 THEN N.query('Name').value('/', 'nvarchar(100)') ELSE NULL END AS Name
FROM @Descriptions.nodes('//DESC') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SharingProfileObjectName, @ErrMsg

IF @CanUseAnyView=0 BEGIN
	INSERT INTO @ViewTable
		( ViewType )
	SELECT 
		N.value('.', 'int') AS ViewType
	FROM @Views.nodes('//VIEW') as T(N)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg
END

INSERT INTO @FieldTable (
	FieldID
)
SELECT
	N.value('.', 'int') AS FieldID
FROM @Fields.nodes('//FIELD') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

IF @CanUpdateRecords=1 AND @EditLangs IS NOT NULL BEGIN
	INSERT INTO @EditLangTable
	SELECT l.LangID
	FROM dbo.fn_GBL_ParseVarCharIDList(@EditLangs, ',') nt
	INNER JOIN STP_Language l
		ON nt.ItemID=l.Culture COLLATE Latin1_General_100_CI_AI
END

UPDATE @DescTable
	SET Name = (SELECT TOP 1 Name FROM @DescTable WHERE Name IS NOT NULL ORDER BY LangID)
WHERE Name IS NULL

SELECT @UsedNamesDesc = COALESCE(@UsedNamesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM GBL_SharingProfile ep INNER JOIN GBL_SharingProfile_Name epn ON ep.ProfileID=epn.ProfileID WHERE Name=nt.Name AND LangID=nt.LangID AND ep.ProfileID<>@ProfileID)

SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @SharingProfileObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile ID exists ?
END ELSE IF @ProfileID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE ProfileID=@ProfileID AND Domain=2) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @SharingProfileObjectName)
-- Profile belongs to member ?
END ELSE IF @ProfileID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_SharingProfile WHERE MemberID=@MemberID AND ProfileID=@ProfileID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @SharingProfileObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE Name IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @SharingProfileObjectName)
-- Name in use ?
END ELSE IF @UsedNamesDesc IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNamesDesc, @NameObjectName)
-- Invalid language ?
END ELSE IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	DECLARE @ShareNotifyEmailAddresses nvarchar(1000)
	IF @ProfileID IS NULL OR @OnlyAdd = 0 BEGIN
		SELECT @ShareNotifyEmailAddresses = STUFF(
			   (SELECT	', ' + u.Email FROM (SELECT DISTINCT Email
					FROM	GBL_Users u
					INNER JOIN VOL_SecurityLevel sl
						ON sl.SL_ID = u.SL_ID_VOL
					WHERE	(sl.SuperUser = 1 OR sl.SuperUserGlobal = 1)
								AND sl.MemberID = m.MemberID AND u.Email IS NOT NULL
					) u ORDER BY u.Email
				FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 2, '') 
		FROM STP_Member m
		WHERE m.MemberID=@ShareMemberID
	END

	IF @ProfileID IS NULL BEGIN
		INSERT INTO GBL_SharingProfile (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			Domain,
			ShareMemberID,
			CanUseAnyView,
			CanUpdateRecords,
			CanUsePrint,
			CanUseExport,
			CanUpdatePubs,
			CanViewFeedback,
			CanViewPrivate,
			RevocationPeriod,
			NotifyEmailAddresses,
			ShareNotifyEmailAddresses
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			2,
			@ShareMemberID,
			@CanUseAnyView,
			@CanUpdateRecords,
			@CanUsePrint,
			@CanUseExport,
			@CanUpdatePubs,
			@CanViewFeedback,
			@CanViewPrivate,
			@RevocationPeriod,
			@NotifyEmailAddresses,
			@ShareNotifyEmailAddresses
		)
		SELECT @ProfileID = SCOPE_IDENTITY()
	END ELSE IF @OnlyAdd=0 BEGIN
		UPDATE GBL_SharingProfile
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			CanUseAnyView		= ISNULL(@CanUseAnyView, CanUseAnyView),
			CanUpdateRecords	= @CanUpdateRecords,
			CanUsePrint			= @CanUsePrint,
			CanUseExport		= @CanUseExport,
			CanUpdatePubs		= @CanUpdatePubs,
			CanViewFeedback		= @CanViewFeedback,
			CanViewPrivate		= @CanViewPrivate,
			RevocationPeriod	= @RevocationPeriod,
			ShareMemberID		= @ShareMemberID,
			ShareNotifyEmailAddresses = @ShareNotifyEmailAddresses,
			NotifyEmailAddresses = ISNULL(@NotifyEmailAddresses, NotifyEmailAddresses)

		WHERE ProfileID = @ProfileID	
	END ELSE BEGIN
		UPDATE GBL_SharingProfile
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			CanUseAnyView		= ISNULL(@CanUseAnyView, CanUseAnyView),
			NotifyEmailAddresses = ISNULL(@NotifyEmailAddresses, NotifyEmailAddresses)
		WHERE ProfileID = @ProfileID	
		
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SharingProfileObjectName, @ErrMsg
	

	IF @Error=0 AND @ProfileID IS NOT NULL BEGIN
		MERGE INTO GBL_SharingProfile_Name spn
		USING @DescTable nt
			ON spn.LangID=nt.LangID AND spn.ProfileID=@ProfileID
		WHEN MATCHED THEN
			UPDATE SET Name=nt.Name
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ProfileID, LangID, Name) VALUES (@ProfileID, nt.LangID, nt.Name)
		WHEN NOT MATCHED BY SOURCE AND spn.ProfileID=@ProfileID THEN
			DELETE
			
			;
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SharingProfileObjectName, @ErrMsg
	
		
		IF @CanUseAnyView=1 BEGIN
			DELETE FROM GBL_SharingProfile_VOL_View WHERE ProfileID=@ProfileID
		END ELSE BEGIN
			MERGE INTO GBL_SharingProfile_VOL_View vw
			USING (SELECT nt.ViewType FROM @ViewTable nt
					INNER JOIN VOL_View vw
						ON vw.ViewType=nt.ViewType AND vw.MemberID=@ShareMemberID) nt
				ON vw.ViewType=nt.ViewType AND vw.ProfileID=@ProfileID
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (ViewType, ProfileID) VALUES (nt.ViewType, @ProfileID)
			WHEN NOT MATCHED BY SOURCE AND vw.ProfileID=@ProfileID AND @OnlyAdd=0 THEN
				DELETE
				
				;
		END
			
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg

		
		MERGE INTO GBL_SharingProfile_VOL_Fld fld
		USING (SELECT nt.FieldID FROM @FieldTable nt
				INNER JOIN VOL_FieldOption fo
					ON fo.FieldID=nt.FieldID AND fo.CanShare=1) nt
			ON fld.FieldID=nt.FieldID AND fld.ProfileID=@ProfileID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (FieldID, ProfileID) VALUES (nt.FieldID, @ProfileID)
		WHEN NOT MATCHED BY SOURCE AND fld.ProfileID=@ProfileID AND @OnlyAdd=0 THEN
			DELETE
			
			;
			
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

		MERGE INTO GBL_SharingProfile_EditLang dst
		USING (SELECT nt.LangID, @ProfileID AS ProfileID
			FROM @EditLangTable nt) src
		ON src.LangID=dst.LangID AND src.ProfileID=dst.ProfileID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ProfileID, LangID) VALUES (src.ProfileID, src.LangID)
		WHEN NOT MATCHED BY SOURCE AND dst.ProfileID=@ProfileID THEN
			DELETE
			;

	END
END

RETURN @Error

SET NOCOUNT OFF





















GO




GRANT EXECUTE ON  [dbo].[sp_VOL_SharingProfile_u] TO [cioc_login_role]
GO
