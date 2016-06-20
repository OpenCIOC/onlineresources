SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Source_u]
	@TAX_SRC_ID [int],
	@MODIFIED_BY [varchar](50),
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

DECLARE	@Error		int
SET @Error = 0

DECLARE	@SourceObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @SourceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Source')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	SourceName nvarchar(100) NOT NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	SourceName
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('SourceName[1]', 'nvarchar(100)') AS Source
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + SourceName
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM TAX_Source s INNER JOIN TAX_Source_Name sn ON s.TAX_SRC_ID=sn.TAX_SRC_ID WHERE SourceName=nt.SourceName AND LangID=nt.LangID AND @TAX_SRC_ID<>s.TAX_SRC_ID)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

/* Identify errors that will prevent the record from being updated */
-- Source ID given ?
IF @TAX_SRC_ID IS NULL BEGIN
	SET @Error = 2
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SourceObjectName, NULL)
-- Source exists ?
END ELSE IF NOT EXISTS (SELECT * FROM TAX_Source WHERE TAX_SRC_ID = @TAX_SRC_ID) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@TAX_SRC_ID AS varchar), @SourceObjectName)
-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @SourceObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE SourceName IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @SourceObjectName)
-- Name in use ?
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
-- Invalid language ?
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
/* No errors found that will prevent the record from being updated */
END ELSE BEGIN
	/* Update the entry with the given values */
	UPDATE TAX_Source
	SET	MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= @MODIFIED_BY
	WHERE (TAX_SRC_ID = @TAX_SRC_ID)
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SourceObjectName, @ErrMsg OUTPUT
	
	IF @Error = 0 BEGIN
		MERGE INTO TAX_Source_Name sn
		USING @DescTable nt
			ON sn.TAX_SRC_ID=@TAX_SRC_ID AND sn.LangID=nt.LangID
		WHEN MATCHED THEN
			UPDATE SET SourceName=nt.SourceName
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (TAX_SRC_ID, LangID, SourceName)
				VALUES (@TAX_SRC_ID, nt.LangID, nt.SourceName)
		WHEN NOT MATCHED BY SOURCE AND sn.TAX_SRC_ID=@TAX_SRC_ID THEN
			DELETE
			;
	END
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Source_u] TO [cioc_login_role]
GO
