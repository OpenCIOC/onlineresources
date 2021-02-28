SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Unused_u]
	@UT_ID [int],
	@MODIFIED_BY [varchar](50),
	@Code [varchar](21),
	@Term [nvarchar](255),
	@Authorized [bit],
	@Active [bit],
	@LangID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 11-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@TermObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@AlternateTermObjectName nvarchar(100),
		@UseReferenceObjectName nvarchar(100)

SET @TermObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Term')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @AlternateTermObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Alternate name')
SET @UseReferenceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Use Reference (Unused Term)')

/* Trim incoming data for all text-valued fields */
SET @Term = RTRIM(LTRIM(@Term))
IF @Term = '' SET @Term = NULL

/* If an existing term reference is set to null, remove it */
IF @Code IS NULL BEGIN
	SET @Error = 4
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TermObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM TAX_Term WHERE Code = @Code) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Code, @TermObjectName)
END ELSE IF @Term IS NULL AND @UT_ID IS NOT NULL BEGIN
	DELETE FROM TAX_Unused
		WHERE UT_ID=@UT_ID AND Code=@Code
		
/* Update an existing reference or add a new one */
/* Identify errors that will prevent the record from being updated */
END ELSE BEGIN
IF @Term IS NOT NULL AND @Active=1 AND 
		EXISTS (SELECT * FROM TAX_Term tm 
			INNER JOIN TAX_Term_Description tmd 
				ON tm.Code=tmd.Code AND tmd.LangID=@LangID 
			WHERE Term=@Term AND AltTerm IS NULL) BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Term, @TermObjectName)
END ELSE IF @Term IS NOT NULL AND @Active=1 AND 
		EXISTS (SELECT * FROM TAX_Term tm 
			INNER JOIN TAX_Term_Description tmd 
				ON tm.Code=tmd.Code AND tmd.LangID=@LangID 
			WHERE AltTerm=@Term) BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Term, @AlternateTermObjectName)
END ELSE IF @Term IS NOT NULL AND EXISTS (SELECT * FROM TAX_Unused WHERE Term=@Term AND LangID=@LangID AND Code=@Code AND UT_ID<>@UT_ID) BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Term, @UseReferenceObjectName)
END ELSE IF @UT_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM TAX_Unused WHERE UT_ID=@UT_ID) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@UT_ID AS varchar), @UseReferenceObjectName)
END ELSE IF @LangID IS NULL BEGIN
	SET @Error = 2
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
END ELSE IF NOT EXISTS(SELECT * FROM STP_Language WHERE LangID=@LangID AND Active=1) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@LangID AS varchar), @LanguageObjectName)
/* No problems exists that will prevent the addtion / updating of this record, so insert / update the entry */
END ELSE BEGIN
	/* This is an existing Term; update the existing record */
	IF @UT_ID IS NOT NULL BEGIN
		UPDATE TAX_Unused
		SET MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY,
			Term			= @Term,
			Authorized		= @Authorized,
			Active			= @Active,
			LangID			= @LangID
		WHERE (UT_ID = @UT_ID)
	/* This is a new Term; Insert a new record */
	END ELSE BEGIN
		INSERT INTO TAX_Unused (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			Code,
			Term,
			Authorized,
			Active,
			LangID
		)
		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@Code,
			@Term,
			@Authorized,
			@Active,
			@LangID
		)
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @UseReferenceObjectName, @ErrMsg OUTPUT

END

EXEC sp_CIC_SRCH_TAX_u NULL
EXEC sp_CIC_SRCH_TaxPub_u

END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Unused_u] TO [cioc_login_role]
GO
