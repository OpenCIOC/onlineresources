SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_StandardEmailUpdate_u]
	@EmailID int OUTPUT,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@Domain int,
	@StdForMultipleRecords bit,
	@DefaultMsg bit,
	@StdSubjectBilingual varchar(150),
	@Descriptions xml,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 02-Aug-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@EmailUpdateTextObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @EmailUpdateTextObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Standard Email Update Text')

SET @StdSubjectBilingual = RTRIM(LTRIM(@StdSubjectBilingual))
IF @StdSubjectBilingual = '' SET @StdSubjectBilingual = NULL

IF @EmailID IS NOT NULL BEGIN
	SELECT @DefaultMsg = CASE WHEN @DefaultMsg=1 OR DefaultMsg=1 THEN 1 ELSE 0 END
		FROM GBL_StandardEmailUpdate seu
	WHERE EmailID=@EmailID
END

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL PRIMARY KEY,
	LangID smallint NULL,
	Name nvarchar(200) NULL,
	StdSubject nvarchar(100) NULL,
	StdGreetingStart nvarchar(100) NULL,
	StdGreetingEnd nvarchar(100) NULL,
	StdMessageBody nvarchar(1500) NULL,
	StdDetailDesc nvarchar(100) NULL,
	StdFeedbackDesc nvarchar(100) NULL,
	StdSuggestOppDesc nvarchar(150) NULL,
	StdOrgOppsDesc nvarchar(150) NULL,
	StdContact nvarchar(255) NULL
)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Name,
	StdSubject,
	StdGreetingStart,
	StdGreetingEnd,
	StdMessageBody,
	StdDetailDesc,
	StdFeedbackDesc,
	StdSuggestOppDesc,
	StdOrgOppsDesc,
	StdContact
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('Name[1]', 'nvarchar(200)') AS Name,
	N.value('StdSubject[1]', 'nvarchar(100)') AS StdSubject,
	N.value('StdGreetingStart[1]', 'nvarchar(100)') AS StdGreetingStart,
	N.value('StdGreetingEnd[1]', 'nvarchar(100)') AS StdGreetingEnd,
	N.value('StdMessageBody[1]', 'nvarchar(1500)') AS StdMessageBody,
	N.value('StdDetailDesc[1]', 'nvarchar(100)') AS StdDetailDesc,
	N.value('StdFeedbackDesc[1]', 'nvarchar(100)') AS StdFeedbackDesc,
	N.value('StdSuggestOppDesc[1]', 'nvarchar(150)') AS StdSuggestOppDesc,
	N.value('StdOrgOppsDesc[1]', 'nvarchar(150)') AS StdOrgOppsDesc,
	N.value('StdContact[1]', 'nvarchar(255)') AS StdContact
FROM @Descriptions.nodes('//DESC') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @EmailUpdateTextObjectName, @ErrMsg

DECLARE @UsedNamesDesc nvarchar(max), @BadCulturesDesc nvarchar(max)

SELECT @UsedNamesDesc = COALESCE(@UsedNamesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM GBL_StandardEmailUpdate se INNER JOIN GBL_StandardEmailUpdate_Description sed ON se.EmailID=sed.EmailID WHERE Name=nt.Name AND LangID=nt.LangID AND MemberID=@MemberID AND (@EmailID IS NULL OR se.EmailID<>@EmailID))

SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- EmailID exists
END IF @EmailID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_StandardEmailUpdate WHERE EmailID=@EmailID AND Domain=@Domain AND StdForMultipleRecords=@StdForMultipleRecords) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@EmailID AS varchar), @EmailUpdateTextObjectName)
-- Security
END IF @EmailID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_StandardEmailUpdate WHERE EmailID=@EmailID AND Domain=@Domain AND StdForMultipleRecords=@StdForMultipleRecords AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @EmailUpdateTextObjectName, NULL)
-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @EmailUpdateTextObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE Name IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @EmailUpdateTextObjectName)
-- Name in use ?
END ELSE IF @UsedNamesDesc IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNamesDesc, @NameObjectName)
-- Invalid language ?
END ELSE IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
END ELSE BEGIN
	IF @EmailID IS NULL BEGIN
		INSERT INTO GBL_StandardEmailUpdate (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			Domain,
			StdForMultipleRecords,
			DefaultMsg,
			StdSubjectBilingual
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@Domain,
			ISNULL(@StdForMultipleRecords,0),
			ISNULL(@DefaultMsg,0),
			@StdSubjectBilingual
		)
		
		SET @EmailID = SCOPE_IDENTITY()
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @EmailUpdateTextObjectName, @ErrMsg
	END ELSE BEGIN
		UPDATE GBL_StandardEmailUpdate
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			DefaultMsg			= ISNULL(@DefaultMsg,DefaultMsg),
			StdSubjectBilingual	= @StdSubjectBilingual
		WHERE EmailID = @EmailID
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @EmailUpdateTextObjectName, @ErrMsg
	END
	
	IF @EmailID IS NOT NULL BEGIN
		MERGE INTO GBL_StandardEmailUpdate_Description sed
		USING @DescTable nt
			ON sed.EmailID=@EmailID AND nt.LangID=sed.LangID
		WHEN MATCHED THEN
			UPDATE SET 
				Name				= nt.Name,
				StdSubject			= nt.StdSubject,
				StdGreetingStart	= nt.StdGreetingStart,
				StdGreetingEnd		= nt.StdGreetingEnd,
				StdMessageBody		= nt.StdMessageBody,
				StdDetailDesc		= nt.StdDetailDesc,
				StdFeedbackDesc		= nt.StdFeedbackDesc,
				StdOrgOppsDesc		= nt.StdOrgOppsDesc,
				StdSuggestOppDesc	= nt.StdSuggestOppDesc,
				StdContact	 		= nt.StdContact
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				EmailID,
				LangID,
				MemberID_Cache,
				Name,
				StdSubject,
				StdGreetingStart,
				StdGreetingEnd,
				StdMessageBody,
				StdDetailDesc,
				StdFeedbackDesc,
				StdOrgOppsDesc,
				StdSuggestOppDesc,
				StdContact
			) VALUES (
				@EmailID,
				nt.LangID,
				@MemberID,
				nt.Name,
				nt.StdSubject,
				nt.StdGreetingStart,
				nt.StdGreetingEnd,
				nt.StdMessageBody,
				nt.StdDetailDesc,
				nt.StdFeedbackDesc,
				nt.StdOrgOppsDesc,
				nt.StdSuggestOppDesc,
				nt.StdContact
			)
		WHEN NOT MATCHED BY SOURCE AND sed.EmailID=@EmailID THEN
			DELETE
				
			;
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @EmailUpdateTextObjectName, @ErrMsg	
	END
	
	IF @Error=0 AND @DefaultMsg=1 AND @EmailID IS NOT NULL BEGIN
		UPDATE seu
			SET MODIFIED_DATE	= GETDATE(),
				MODIFIED_BY		= @MODIFIED_BY,
				DefaultMsg		= 0
		FROM GBL_StandardEmailUpdate seu
			WHERE DefaultMsg=1
				AND EmailID<>@EmailID
				AND MemberID=@MemberID
				AND Domain=@Domain
				AND StdForMultipleRecords=@StdForMultipleRecords
	END
END

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_GBL_StandardEmailUpdate_u] TO [cioc_login_role]
GO
