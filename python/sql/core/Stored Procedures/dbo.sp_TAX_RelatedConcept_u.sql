SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_RelatedConcept_u]
	@RC_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@Code [varchar](6),
	@Source [int],
	@Authorized [bit],
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

DECLARE	@RelatedConceptObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@CodeObjectName nvarchar(100),
		@SourceObjectName nvarchar(100)

SET @RelatedConceptObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Related Concept')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @CodeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Code')
SET @SourceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Source')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	ConceptName nvarchar(255) NOT NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	ConceptName
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('ConceptName[1]', 'nvarchar(255)') AS RelatedConcept
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ConceptName
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM TAX_RelatedConcept s INNER JOIN TAX_RelatedConcept_Name sn ON s.RC_ID=sn.RC_ID WHERE ConceptName=nt.ConceptName AND LangID=nt.LangID AND @RC_ID<>s.RC_ID)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL


/* Trim incoming data for all text-valued fields */
SET @Code = RTRIM(LTRIM(@Code))
IF @Code = '' SET @Code = NULL

/* Identify errors that will prevent the record from being updated */
-- Code given ?
IF @Code IS NULL BEGIN
	SET @Error = 10
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CodeObjectName, @RelatedConceptObjectName)
-- Code in correct format ?
END ELSE IF NOT (@Code LIKE '[A-Z][A-Z]' OR @Code LIKE '[A-Z][A-Z]-[0-9][0-9][0-9]') BEGIN
	SET @Error = 22
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Code, @RelatedConceptObjectName)
-- Code in use ?
END ELSE IF EXISTS (SELECT * FROM TAX_RelatedConcept WHERE Code=@Code AND (@RC_ID IS NULL OR RC_ID<>@RC_ID)) BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Code, @RelatedConceptObjectName)
-- Concept exists ?
END ELSE IF @RC_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM TAX_RelatedConcept WHERE RC_ID=@RC_ID) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @RC_ID, @NameObjectName)
-- Source exists ?
END ELSE IF @Source IS NOT NULL AND NOT EXISTS (SELECT * FROM TAX_Source WHERE TAX_SRC_ID = @Source) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Source, @SourceObjectName)
-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @RelatedConceptObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE ConceptName IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @RelatedConceptObjectName)
-- Name in use ?
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
-- Invalid language ?
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
/* No problems exists that will prevent the addtion / updating of this record, so insert / update the entry */
END ELSE BEGIN
	/* This is an existing Concept; update the existing record */
	IF @RC_ID IS NOT NULL BEGIN
		UPDATE TAX_RelatedConcept
		SET MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY,
		 	Code			= @Code,
			Source			= @Source,
			Authorized		= @Authorized
		WHERE (RC_ID = @RC_ID)
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @RelatedConceptObjectName, @ErrMsg OUTPUT
	/* This is a new Concept; Insert a new record */
	END ELSE BEGIN
		INSERT INTO TAX_RelatedConcept (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			Code,
			Source,
			Authorized
		)
		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@Code,
			@Source,
			@Authorized
		)
		SET @RC_ID = @@IDENTITY
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @RelatedConceptObjectName, @ErrMsg OUTPUT
	END
	IF @Error = 0 BEGIN
		MERGE INTO TAX_RelatedConcept_Name rcn
		USING @DescTable nt
			ON rcn.RC_ID=@RC_ID AND rcn.LangID=nt.LangID
		WHEN MATCHED AND nt.ConceptName <> rcn.ConceptName THEN
			UPDATE SET ConceptName = nt.ConceptName
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (RC_ID, LangID, ConceptName)
				VALUES (@RC_ID, nt.LangID, nt.ConceptName)
		WHEN NOT MATCHED BY SOURCE AND rcn.RC_ID=@RC_ID THEN
			DELETE
			;
	END
END

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_TAX_RelatedConcept_u] TO [cioc_login_role]
GO
