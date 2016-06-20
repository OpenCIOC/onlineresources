SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Facet_i]
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

DECLARE	@Error	int
SET @Error = 0

DECLARE	@FacetObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @FacetObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Facet')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Facet nvarchar(100) NOT NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Facet
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('Facet[1]', 'nvarchar(100)') AS Facet
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Facet
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM TAX_Facet f INNER JOIN TAX_Facet_Name fn ON f.FC_ID=fn.FC_ID WHERE Facet=nt.Facet AND LangID=nt.LangID)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

/* Identify errors that will prevent the record from being added */
-- At least one language used ?
IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @FacetObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE Facet IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @FacetObjectName)
-- Name in use ?
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
-- Invalid language ?
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
/* No errors found that will prevent the record from being added */
END ELSE BEGIN
	DECLARE @FC_ID int
	/* Add a new entry to TAX_Facet with the given values */
	INSERT INTO TAX_Facet (
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY
	)
	VALUES (
		GETDATE(),
		@MODIFIED_BY,
		GETDATE(),
		@MODIFIED_BY
	)
	SET @FC_ID = SCOPE_IDENTITY()
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FacetObjectName, @ErrMsg OUTPUT
	
	IF @Error = 0 BEGIN
		INSERT INTO TAX_Facet_Name
		SELECT @FC_ID, nt.LangID, nt.Facet
		FROM @DescTable nt
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FacetObjectName, @ErrMsg OUTPUT
	END
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Facet_i] TO [cioc_login_role]
GO
