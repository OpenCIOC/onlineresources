SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_THS_Subject_u]
	@Subj_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@Used [bit],
	@UseAll [bit],
	@SubjCat_ID [int],
	@SRC_ID [int],
	@Inactive [bit],
	@Descriptions [xml],
	@UseSubj [xml],
	@BroaderSubj [xml],
	@RelatedSubj [xml],
	@Authorized [bit]=NULL,
	@MakeShared [bit]=0,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 02-Jun-2012
	Action: NO ACTION REQUIRED
*/


DECLARE	@Error		int
SET @Error = 0

DECLARE	@SubjectObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @SubjectObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Subject')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Name nvarchar(200) NULL,
	Notes nvarchar(max) NULL	
)

DECLARE @UseSubjTable TABLE (
	Subj_ID int NOT NULL
)

DECLARE @BroaderSubjTable TABLE (
	Subj_ID int NOT NULL
)

DECLARE @RelatedSubjTable TABLE (
	Subj_ID int NOT NULL
)

DECLARE @UsedNamesDesc nvarchar(max),
		@BadCulturesDesc nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Name,
	Notes
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('Name[1]', 'nvarchar(100)') AS Name,
	N.value('Notes[1]', 'nvarchar(max)') AS Notes
	
FROM @Descriptions.nodes('//DESC') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg

INSERT INTO @UseSubjTable
	( Subj_ID )
SELECT 
	N.value('.', 'int') AS Subj_ID
FROM @UseSubj.nodes('//SUBJ') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg

INSERT INTO @BroaderSubjTable
	( Subj_ID )
SELECT 
	N.value('.', 'int') AS Subj_ID
FROM @BroaderSubj.nodes('//SUBJ') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg

INSERT INTO @RelatedSubjTable
	( Subj_ID )
SELECT 
	N.value('.', 'int') AS Subj_ID
FROM @RelatedSubj.nodes('//SUBJ') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg



SELECT DISTINCT @UsedNamesDesc = COALESCE(@UsedNamesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM THS_Subject subj INNER JOIN THS_Subject_Name subjn ON subj.Subj_ID=subjn.Subj_ID WHERE Name=nt.Name AND LangID=nt.LangID AND (@Subj_ID IS NULL OR subj.Subj_ID<>@Subj_ID))

SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL


IF @Subj_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM THS_Subject WHERE Subj_ID=@Subj_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Subj_ID AS varchar), @SubjectObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE Name IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @SubjectObjectName)
END ELSE IF @UsedNamesDesc IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNamesDesc, @NameObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @SubjectObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE Name IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @SubjectObjectName)
END ELSE IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
END

IF EXISTS(SELECT * FROM CIC_BT_SBJ WHERE Subj_ID=@Subj_ID) BEGIN
	SET @Inactive=0

END

IF @Error = 0 BEGIN
	IF @Subj_ID IS NULL BEGIN
		INSERT INTO THS_Subject (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			Authorized,
			Used,
			UseAll,
			SubjCat_ID,
			SRC_ID
			) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			ISNULL(@Authorized, 0),
			@Used,
			@UseAll,
			@SubjCat_ID,
			@SRC_ID
			)
		SET @Subj_ID = SCOPE_IDENTITY()
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg
		
	END ELSE BEGIN
		UPDATE THS_Subject
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			Authorized = ISNULL(@Authorized, Authorized),
			MemberID = CASE WHEN @MakeShared=1 THEN NULL ELSE MemberID END,
			Used = @Used,
			UseAll = @UseAll,
			SubjCat_ID = @SubjCat_ID,
			SRC_ID = @SRC_ID
		WHERE Subj_ID = @Subj_ID	
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg
	
	END
	

	IF @Error=0 BEGIN
		
		MERGE INTO THS_Subject_Name AS subjn
		USING @DescTable AS nt
		ON @Subj_ID = subjn.Subj_ID AND nt.LangID=subjn.LangID
		WHEN MATCHED AND ISNULL(subjn.Notes,'')<> ISNULL(nt.Notes,'') OR ISNULL(subjn.Name,'')<>ISNULL(nt.Name,'')
			THEN UPDATE SET subjn.Name=nt.Name, subjn.Notes=nt.Notes
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (Subj_ID, LangID, Name, Notes) VALUES (@Subj_ID, nt.LangID, nt.Name, nt.Notes)
		WHEN NOT MATCHED BY SOURCE AND subjn.Subj_ID = @Subj_ID
			THEN DELETE ;
			
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg
			
		IF @Used = 1 BEGIN
			DELETE THS_SBJ_UseInstead WHERE Subj_ID=@Subj_ID
		END ELSE BEGIN
		
		MERGE INTO THS_SBJ_UseInstead as subjr
		USING (SELECT * FROM @UseSubjTable ) AS nt 
		ON @Subj_ID=subjr.Subj_ID AND nt.Subj_ID=subjr.UsedSubj_ID
		WHEN NOT MATCHED BY TARGET 
			THEN INSERT (Subj_ID, UsedSubj_ID) VALUES (@Subj_ID, nt.Subj_ID)
		WHEN NOT MATCHED BY SOURCE AND subjr.Subj_ID = @Subj_ID
			THEN DELETE ;
			
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg
		
		END
			
		MERGE INTO THS_SBJ_BroaderTerm as subjr
		USING (SELECT * FROM @BroaderSubjTable ) AS nt 
		ON @Subj_ID=subjr.Subj_ID AND nt.Subj_ID=subjr.BroaderSubj_ID
		WHEN NOT MATCHED BY TARGET 
			THEN INSERT (Subj_ID, BroaderSubj_ID) VALUES (@Subj_ID, nt.Subj_ID)
		WHEN NOT MATCHED BY SOURCE AND subjr.Subj_ID = @Subj_ID
			THEN DELETE ;
				
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SubjectObjectName, @ErrMsg
		
		MERGE INTO THS_SBJ_RelatedTerm as subjr
		USING (SELECT * FROM @RelatedSubjTable) AS nt
		ON @Subj_ID=subjr.Subj_ID AND nt.Subj_ID=subjr.RelatedSubj_ID
		WHEN NOT MATCHED BY TARGET 
			THEN INSERT (Subj_ID, RelatedSubj_ID) VALUES (@Subj_ID, nt.Subj_ID)
		WHEN NOT MATCHED BY SOURCE AND subjr.Subj_ID = @Subj_ID
			THEN DELETE ;
			
			
		IF @Inactive = 0 BEGIN
			DELETE FROM THS_Subject_InactiveByMember 
			WHERE MemberID=@MemberID AND Subj_ID=@Subj_ID
		END ELSE IF NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember 
			WHERE MemberID=@MemberID AND Subj_ID=@Subj_ID) BEGIN
			INSERT INTO THS_Subject_InactiveByMember 
				(MemberID, Subj_ID) VALUES (@MemberID, @Subj_ID)
		END
	END
END

RETURN @Error

SET NOCOUNT OFF
















GO
GRANT EXECUTE ON  [dbo].[sp_THS_Subject_u] TO [cioc_login_role]
GO
