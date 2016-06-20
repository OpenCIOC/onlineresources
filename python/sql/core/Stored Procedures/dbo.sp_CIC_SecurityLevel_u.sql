
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_SecurityLevel_u]
	-- Common fields
	@SL_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@MemberID [int],
	@User_ID [int],
	@AgencyCode [char](3),
	@Owner [bit],
	@ViewType [int],
	@CanAddRecord [bit],
	@CanAddSQL [bit],
	@CanAssignFeedback [bit],
	@CanCopyRecord [bit],
	@CanDeleteRecord [int],
	@CanDoBulkOps [bit],
	@CanDoFullUpdate [bit],
	@CanEditRecord [tinyint],
	@CanManageUsers [bit],
	@CanRequestUpdate [bit],
	@CanViewStats [tinyint],
	-- CIC specific fields
	@CanIndexTaxonomy [tinyint],
	@CanUpdatePubs [tinyint],
	@ExportPermission [int],
	@ImportPermission [bit],
	@RecordTypes [varchar](max),
	@ViewTypeOffline [int],
	@CanEditVacancy [tinyint],
	@VacancyEditByViewList [bit],
	@VacancyEditByViewType [varchar](max),
	@VacancyEditAgencies [varchar](MAX),
	-- Common fields
	@EditByViewList [bit],
	@EditByViewType [varchar](max),
	@EditAgencies [varchar](MAX),
	@EditLangs [varchar](max),
	@APIIDs [varchar](max),
	@SuppressNotifyEmail [bit],
	@FeedbackAlert [bit],
	@CommentAlert [bit],
	@WebDeveloper [bit],
	@SuperUser [bit],
	@SuperUserGlobal [bit],
	@Descriptions [xml],
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 28-Sep-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@SecurityLevelObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@ViewObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @SecurityLevelObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User Type')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')

DECLARE @USL_ID int,
		@UseOfflineTools bit
		
SELECT @UseOfflineTools = UseOfflineTools FROM STP_Member WHERE MemberID=@MemberID

DECLARE @RecordTypeTable TABLE (
	RT_ID int PRIMARY KEY NOT NULL
)

DECLARE @ViewTypeTable TABLE (
	ViewType int PRIMARY KEY NOT NULL
)

DECLARE @AgencyTable TABLE (
	AgencyCode char(3) PRIMARY KEY NOT NULL
)

DECLARE @EditLangTable TABLE (
	LangID smallint PRIMARY KEY NOT NULL
)

DECLARE @VacancyAgencyTable TABLE (
	AgencyCode char(3) PRIMARY KEY NOT NULL
)

DECLARE @VacancyViewTypeTable TABLE (
	ViewType int PRIMARY KEY NOT NULL
)


DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	SecurityLevel nvarchar(100) NOT NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	SecurityLevel
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('SecurityLevel[1]', 'nvarchar(100)') AS SecurityLevel
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + SecurityLevel
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM CIC_SecurityLevel_Name sln WHERE SecurityLevel=nt.SecurityLevel AND LangID=nt.LangID AND (SL_ID<>@SL_ID OR @SL_ID IS NULL) AND MemberID_Cache=@MemberID)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

/* If this user is a Global Super User, Super User privilegs are implied
	Flag is added for consistancy */
IF @SuperUserGlobal = 1 BEGIN
	SET @SuperUser = 1
END

/* If this user is a Super User, certain privileges are implied.
	These privileges should be automatically granted by the software based 
	on Super User status, but the flags will be set for consistency */
IF @SuperUser = 1 BEGIN
	SET @CanAddRecord = 1
	SET @CanAddSQL = 1
	SET @CanAssignFeedback = 1
	SET @CanCopyRecord = 1
	SET @CanDeleteRecord = 1
	SET @CanDoBulkOps = 1
	SET @CanDoFullUpdate = 1
	SET @CanEditRecord = 2
	SET @CanEditVacancy = 2
	SET @CanManageUsers = 1
	SET @CanRequestUpdate = 1
	SET @CanIndexTaxonomy = 2
	SET @CanUpdatePubs = 2
	SET @CanViewStats = 2
	SET @FeedbackAlert = 1
	SET @ExportPermission = 2
	SET @ImportPermission = 1
	SET @SuppressNotifyEmail = 1
	SET @EditByViewList = 0
	SET @EditByViewType = NULL
	SET @EditAgencies = NULL
	SET @VacancyEditByViewList = 0
	SET @VacancyEditByViewType = NULL
	SET @VacancyEditAgencies = NULL
	SET @RecordTypes = NULL
	SET @WebDeveloper = 0
	SET @EditLangs = NULL
END

IF @RecordTypes IS NOT NULL BEGIN
	INSERT INTO @RecordTypeTable
	SELECT RT_ID
	FROM CIC_RecordType rt
	INNER JOIN dbo.fn_GBL_ParseIntIDList(@RecordTypes,',') tm
		ON rt.RT_ID=tm.ItemID
END

IF @EditByViewList <> 1 BEGIN
	SET @EditByViewType = NULL
END ELSE IF @EditByViewType IS NOT NULL BEGIN
	INSERT INTO @ViewTypeTable
	SELECT ViewType
	FROM CIC_View vw
	INNER JOIN dbo.fn_GBL_ParseIntIDList(@EditByViewType,',') tm
		ON vw.ViewType=tm.ItemID
END

IF @CanEditRecord <> 3 BEGIN
	SET @EditAgencies = NULL
END ELSE IF @EditAgencies IS NOT NULL BEGIN
	INSERT INTO @AgencyTable
	SELECT AgencyCode
	FROM GBL_Agency a
	INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@EditAgencies,',') tm
		ON a.AgencyCode=tm.ItemID COLLATE Latin1_General_CI_AS
END

IF @EditLangs IS NOT NULL BEGIN
	INSERT INTO @EditLangTable
	SELECT l.LangID 
	FROM STP_Language l
	INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@EditLangs, ',') tm
		ON l.Culture=tm.ItemID COLLATE Latin1_General_CI_AI AND l.ActiveRecord=1
END

IF @VacancyEditByViewList <> 1 BEGIN
	SET @VacancyEditByViewType = NULL
END ELSE IF @VacancyEditByViewType IS NOT NULL BEGIN
	INSERT INTO @VacancyViewTypeTable
	SELECT ViewType
	FROM CIC_View vw
	INNER JOIN dbo.fn_GBL_ParseIntIDList(@VacancyEditByViewType,',') tm
		ON vw.ViewType=tm.ItemID
END

IF @CanEditVacancy <> 3 BEGIN
	SET @VacancyEditAgencies = NULL
END ELSE IF @VacancyEditAgencies IS NOT NULL BEGIN
	INSERT INTO @VacancyAgencyTable
	SELECT AgencyCode
	FROM GBL_Agency a
	INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@VacancyEditAgencies,',') tm
		ON a.AgencyCode=tm.ItemID COLLATE Latin1_General_CI_AS
END

/* Get the current user's User Type */
SELECT @USL_ID=s.SL_ID
	FROM CIC_SecurityLevel s
	INNER JOIN GBL_Users u
		ON s.SL_ID=u.SL_ID_CIC
WHERE u.[User_ID]=@User_ID

-- If Edit Record type provided is invalid, set to "Cannot edit records"
IF @CanEditRecord < 0 OR @CanEditRecord > 3 BEGIN
	SET @CanEditRecord = 0
END

/* Identify errors that will prevent the record from being updated */
-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Security Level exists ?
END ELSE IF @SL_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM CIC_SecurityLevel WHERE SL_ID = @SL_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SL_ID AS varchar), @SecurityLevelObjectName)
-- Security Level belongs to Member ?
END ELSE IF @SL_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM CIC_SecurityLevel WHERE SL_ID=@SL_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND @SL_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_SecurityLevel WHERE SL_ID=@SL_ID AND (Owner=@AgencyCode OR Owner IS NULL)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SecurityLevelObjectName, NULL)
-- Owner is a real Agency for this Member ?
END ELSE IF @Owner=1 AND NOT EXISTS(SELECT * FROM GBL_Agency WHERE AgencyCode=@AgencyCode AND MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyCode, cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency'))
-- View given ?
END ELSE IF @ViewType IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, @SecurityLevelObjectName)
-- View exists ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewType AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- View Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_View
		WHERE ViewType=@ViewType
			AND (MemberID IS NULL OR MemberID=@MemberID)
			AND (
				EXISTS(SELECT * FROM CIC_SecurityLevel WHERE SL_ID=@SL_ID AND ViewType=@ViewType)
				OR (Owner IS NULL OR Owner=@AgencyCode)
			)
		) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- Offline View exists ?
END ELSE IF @ViewTypeOffline IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewTypeOffline) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewTypeOffline AS varchar), @ViewObjectName)
-- Offline View belongs to Member ?
END ELSE IF @ViewTypeOffline IS NOT NULL AND NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewTypeOffline AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Offline View Ownership OK ?
END ELSE IF @ViewTypeOffline IS NOT NULL AND @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_View
		WHERE ViewType=@ViewTypeOffline
			AND (MemberID IS NULL OR MemberID=@MemberID)
			AND (
				EXISTS(SELECT * FROM CIC_SecurityLevel WHERE SL_ID=@SL_ID AND ViewType=@ViewTypeOffline)
				OR (Owner IS NULL OR Owner=@AgencyCode)
			)
		) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @SecurityLevelObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name in use ?
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @SecurityLevelObjectName)
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE SecurityLevel IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @SecurityLevelObjectName)
-- Invalid language ?
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
-- Tries to remove Super User from self ?
END ELSE IF @SL_ID=@USL_ID AND NOT @SuperUser=1 BEGIN
	SET @Error = 24 -- You cannot remove Super User privileges from your own User Type.
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END ELSE BEGIN
	/* We have an ID; update the existing record */
	IF @SL_ID IS NOT NULL BEGIN
		UPDATE CIC_SecurityLevel 
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			Owner				= CASE WHEN @Owner=1 THEN @AgencyCode ELSE NULL END,
			ViewType			= @ViewType,
			CanAddRecord		= ISNULL(@CanAddRecord,CanAddRecord),
			CanAddSQL			= ISNULL(@CanAddSQL,CanAddSQL),
			CanAssignFeedback	= ISNULL(@CanAssignFeedback,CanAssignFeedback),
			CanCopyRecord		= ISNULL(@CanCopyRecord,CanCopyRecord),
			CanDeleteRecord		= ISNULL(@CanDeleteRecord,CanDeleteRecord),
			CanDoBulkOps		= ISNULL(@CanDoBulkOps,CanDoBulkOps),
			CanDoFullUpdate		= ISNULL(@CanDoFullUpdate,CanDoFullUpdate),
			CanEditRecord		= ISNULL(@CanEditRecord,CanEditRecord),
			EditByViewList		= @EditByViewList,
			CanEditVacancy		= ISNULL(@CanEditVacancy,CanEditVacancy),
			VacancyEditByViewList		= @VacancyEditByViewList,
			CanIndexTaxonomy	= ISNULL(@CanIndexTaxonomy,CanIndexTaxonomy),
			CanManageUsers		= ISNULL(@CanManageUsers,CanManageUsers),
			CanRequestUpdate	= ISNULL(@CanRequestUpdate,CanRequestUpdate),
			CanUpdatePubs		= ISNULL(@CanUpdatePubs,CanUpdatePubs),
			CanViewStats		= ISNULL(@CanViewStats,CanViewStats),
			ExportPermission	= @ExportPermission,
			ImportPermission	= @ImportPermission,
			ViewTypeOffline		= CASE WHEN @UseOfflineTools=1 THEN @ViewTypeOffline ELSE ViewTypeOffline END,
			SuppressNotifyEmail	= ISNULL(@SuppressNotifyEmail,SuppressNotifyEmail),
			FeedbackAlert		= ISNULL(@FeedbackAlert,FeedbackAlert),
			CommentAlert		= ISNULL(@CommentAlert,CommentAlert),
			WebDeveloper		= ISNULL(@WebDeveloper,WebDeveloper),
			SuperUser			= ISNULL(@SuperUser,SuperUser),
			SuperUserGlobal		= ISNULL(@SuperUserGlobal, SuperUserGlobal)
		WHERE (SL_ID = @SL_ID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SecurityLevelObjectName, @ErrMsg OUTPUT
	/* No existing ID was given; create a new User Type record*/
	END ELSE BEGIN
		INSERT INTO CIC_SecurityLevel (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			Owner,
			ViewType,
			CanAddRecord,
			CanAddSQL,
			CanAssignFeedback,
			CanCopyRecord,
			CanDeleteRecord,
			CanDoBulkOps,
			CanDoFullUpdate,
			CanEditRecord,
			EditByViewList,
			CanEditVacancy,
			VacancyEditByViewList,
			CanIndexTaxonomy,
			CanManageUsers,			
			CanRequestUpdate,
			CanUpdatePubs,
			CanViewStats,
			ExportPermission,
			ImportPermission,
			ViewTypeOffline,
			SuppressNotifyEmail,
			FeedbackAlert,
			CommentAlert,
			WebDeveloper,
			SuperUser,
			SuperUserGlobal
		) 
 		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			CASE WHEN @Owner=1 THEN @AgencyCode ELSE NULL END,
			@ViewType,
			ISNULL(@CanAddRecord,0),
			ISNULL(@CanAddSQL,0),
			ISNULL(@CanAssignFeedback,0),
			ISNULL(@CanCopyRecord,0),
			ISNULL(@CanDeleteRecord,0),
			ISNULL(@CanDoBulkOps,0),
			ISNULL(@CanDoFullUpdate,0),
			ISNULL(@CanEditRecord,0),
			@EditByViewList,
			ISNULL(@CanEditVacancy,0),
			@VacancyEditByViewList,
			ISNULL(@CanIndexTaxonomy,0),
			ISNULL(@CanManageUsers,0),
			ISNULL(@CanRequestUpdate,0),
			ISNULL(@CanUpdatePubs,0),
			ISNULL(@CanViewStats,0),
			ISNULL(@ExportPermission,0),
			ISNULL(@ImportPermission,0),
			CASE WHEN @UseOfflineTools=1 THEN @ViewTypeOffline ELSE NULL END,
			ISNULL(@SuppressNotifyEmail,0),
			ISNULL(@FeedbackAlert,0),
			ISNULL(@CommentAlert,0),
			ISNULL(@WebDeveloper,0),
			ISNULL(@SuperUser,0),
			ISNULL(@SuperUserGlobal, 0)
		)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SecurityLevelObjectName, @ErrMsg OUTPUT
		/* return the ID of the new User Type to the caller */
		SET @SL_ID = SCOPE_IDENTITY()
	END
	IF @Error = 0 BEGIN
		MERGE INTO CIC_SecurityLevel_Name sln
		USING @DescTable nt
			ON sln.SL_ID=@SL_ID AND sln.LangID=nt.LangID
		WHEN MATCHED AND sln.SecurityLevel <> nt.SecurityLevel THEN
			UPDATE SET SecurityLevel = nt.SecurityLevel
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (SL_ID, LangID, MemberID_Cache, SecurityLevel) VALUES (@SL_ID, nt.LangID, @MemberID, nt.SecurityLevel)
		WHEN NOT MATCHED BY SOURCE AND sln.SL_ID=@SL_ID THEN
			DELETE
			;
			
		IF @UseOfflineTools=1 AND @ViewTypeOffline IS NULL BEGIN
			DELETE FROM CIC_SecurityLevel_Machine WHERE SL_ID=@SL_ID
		END

		DELETE srt
		FROM CIC_SecurityLevel_RecordType srt
		WHERE SL_ID=@SL_ID AND NOT EXISTS(SELECT * FROM @RecordTypeTable rtm WHERE rtm.RT_ID=srt.RT_ID)

		INSERT INTO CIC_SecurityLevel_RecordType (SL_ID, RT_ID)
		SELECT @SL_ID, RT_ID
		FROM @RecordTypeTable rtm
		WHERE NOT EXISTS(SELECT * FROM CIC_SecurityLevel_RecordType srt WHERE srt.SL_ID=@SL_ID AND rtm.RT_ID=srt.RT_ID)

		MERGE INTO CIC_SecurityLevel_EditLang dst
		USING @EditLangTable src
			ON dst.LangID=src.LangID AND dst.SL_ID=@SL_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (SL_ID, LangID)
				VALUES (@SL_ID, src.LangID)
		WHEN NOT MATCHED BY SOURCE AND dst.SL_ID=@SL_ID THEN
			DELETE
			;

		MERGE INTO CIC_SecurityLevel_VacancyEditView dst
		USING @VacancyViewTypeTable src
			ON dst.ViewType=src.ViewType AND dst.SL_ID=@SL_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (SL_ID, ViewType)
				VALUES (@SL_ID, src.ViewType)
		WHEN NOT MATCHED BY SOURCE AND dst.SL_ID=@SL_ID THEN
			DELETE
			;
		
		MERGE INTO CIC_SecurityLevel_EditAgency dst
		USING @AgencyTable src
			ON dst.AgencyCode=src.AgencyCode AND dst.SL_ID=@SL_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (SL_ID, AgencyCode)
				VALUES (@SL_ID, src.AgencyCode)
		WHEN NOT MATCHED BY SOURCE AND dst.SL_ID=@SL_ID THEN
			DELETE
			;

		MERGE INTO CIC_SecurityLevel_VacancyEditAgency dst
		USING @VacancyAgencyTable src
			ON dst.AgencyCode=src.AgencyCode AND dst.SL_ID=@SL_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (SL_ID, AgencyCode)
				VALUES (@SL_ID, src.AgencyCode)
		WHEN NOT MATCHED BY SOURCE AND dst.SL_ID=@SL_ID THEN
			DELETE
			;
		
		MERGE INTO CIC_SecurityLevel_ExternalAPI dst
		USING (SELECT API_ID FROM GBL_ExternalAPI api
				INNER JOIN dbo.fn_GBL_ParseIntIDList(@APIIDs, ',') idl
					ON api.API_ID=idl.ItemID AND api.CIC=1) src
		ON dst.API_ID=src.API_ID AND dst.SL_ID=@SL_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (SL_ID, API_ID) 
				VALUES (@SL_ID, src.API_ID)
		WHEN NOT MATCHED BY SOURCE AND dst.SL_ID=@SL_ID THEN
			DELETE
			;
	END
END

RETURN @Error

SET NOCOUNT OFF






GO




GRANT EXECUTE ON  [dbo].[sp_CIC_SecurityLevel_u] TO [cioc_login_role]
GO
