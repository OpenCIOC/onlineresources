SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_NAICS_u]
	@Code [varchar](6),
	@MODIFIED_BY [varchar](50),
	@NewCode [varchar](6),
	@Parent [varchar](6),
	@CompUS [bit],
	@CompMEX [bit],
	@Source [varchar](255),
	@Descriptions [xml],
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

DECLARE	@NaicsObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@ParentObjectName nvarchar(100)

SET @NaicsObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('NAICS')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @ParentObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Parent')

SET @Code = RTRIM(LTRIM(@Code))
IF @Code = '' SET @Code = NULL
SET @NewCode = RTRIM(LTRIM(@NewCode))
IF @NewCode = '' SET @NewCode = NULL
SET @Parent = RTRIM(LTRIM(@Parent))
IF @Parent = '' SET @Parent = NULL

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Classification nvarchar(255) NULL,
	Description nvarchar(max) NULL
)
DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Classification,
	Description
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('Classification[1]', 'nvarchar(255)') AS Name,
	N.value('Description[1]', 'nvarchar(max)') AS Display
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
	FROM @DescTable nt
WHERE LangID IS NULL

IF @Code IS NULL AND @NewCode IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Code'), @NaicsObjectName)
END ELSE IF @Code IS NULL AND EXISTS(SELECT * FROM NAICS WHERE Code=@NewCode) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NewCode, @NaicsObjectName)
END ELSE IF @Code IS NOT NULL AND NOT EXISTS(SELECT * FROM NAICS WHERE Code=@Code) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Parent, @ParentObjectName)
END ELSE IF @Code IS NOT NULL AND @Code <> @NewCode AND EXISTS(SELECT * FROM NAICS WHERE Code=@NewCode) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NewCode, @NaicsObjectName)
END ELSE IF @Parent = @NewCode BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Parent, @ParentObjectName)
END ELSE IF NOT (@Parent IS NULL OR EXISTS(SELECT * FROM NAICS WHERE Code=@Parent)) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Parent, @ParentObjectName)
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END ELSE IF EXISTS(SELECT * FROM @DescTable WHERE Classification IS NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Classification'), @NaicsObjectName)
END ELSE BEGIN
	IF @Code IS NULL BEGIN
			INSERT INTO NAICS (
				CREATED_DATE,
				CREATED_BY,
				MODIFIED_DATE,
				MODIFIED_BY,
				Code,
				Parent,
				CompUS,
				CompMEX,
				Source
			)
			VALUES (
				GETDATE(),
				@MODIFIED_BY,
				GETDATE(),
				@MODIFIED_BY,
				@NewCode,
				@Parent,
				@CompUS,
				@CompMEX,
				@Source
			)
			
	END ELSE BEGIN
		UPDATE NAICS
			SET	MODIFIED_DATE	= GETDATE(),
				MODIFIED_BY		= @MODIFIED_BY,
				Code			= @NewCode,
				Parent			= @Parent,
				CompUS			= @CompUS,
				CompMEX			= @CompMEX,
				Source			= @Source
		WHERE Code=@Code
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @NaicsObjectName, @ErrMsg
	
	IF @Error = 0 BEGIN
		MERGE INTO NAICS_Description ncd
		USING @DescTable nt
			ON @NewCode=ncd.Code AND ncd.LangID=nt.LangID
		WHEN MATCHED AND (ncd.Classification<>nt.Classification OR ISNULL(ncd.Description, 'NULLNULLNULL')<>ISNULL(nt.Description,'NULLNULLNULL'))
			THEN UPDATE SET Classification=nt.Classification, Description=nt.Description
		WHEN NOT MATCHED BY TARGET 
			THEN INSERT ( CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY, Code, LangID, Classification, Description)
				VALUES (GETDATE(), @MODIFIED_BY, GETDATE(), @MODIFIED_BY, @NewCode, nt.LangID, nt.Classification, nt.Description)
				
		WHEN NOT MATCHED BY SOURCE AND ncd.Code=@NewCode
			THEN DELETE
		;
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @NaicsObjectName, @ErrMsg
	END
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_NAICS_u] TO [cioc_login_role]
GO
