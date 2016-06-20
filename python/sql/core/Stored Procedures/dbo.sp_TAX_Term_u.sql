SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Term_u]
	@TM_ID [int],
	@Code [varchar](21) OUTPUT,
	@MODIFIED_BY [varchar](50),
	@CdLvl1 [char](1),
	@CdLvl2 [varchar](1),
	@CdLvl3 [varchar](4),
	@CdLvl4 [varchar](4),
	@CdLvl5 [varchar](3),
	@CdLvl6 [varchar](2),
	@Source [int],
	@Authorized [bit],
	@Facet [int],
	@IconURL [varchar](150),
	@Active [bit],
	@SeeAlsoTCList [varchar](max),
	@SeeAlsoAuthList [varchar](max),
	@RelatedConceptList [varchar](max),
	@RelatedConceptAuthList [varchar](max),
	@Descriptions [xml],
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
		@CodeObjectName nvarchar(100),
		@FacetObjectName nvarchar(100),
		@UseReferenceObjectName nvarchar(100),
		@SourceObjectName nvarchar(100)

SET @TermObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Term')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @CodeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Code')
SET @FacetObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Facet')
SET @UseReferenceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Use Reference (Unused Term)')
SET @SourceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Source')

DECLARE @tmpTCs TABLE(Code varchar(21))
DECLARE @tmpRCIDs TABLE(RC_ID int)

DECLARE	@FullCode	varchar(21),
		@CdLvl		tinyint,
		@CdLocal	varchar(1)
SET @CdLocal = CASE WHEN @Authorized=1 THEN NULL ELSE 'L' END

/* Trim incoming data for Code parts */
SET @CdLvl1 = RTRIM(LTRIM(@CdLvl1))
IF @CdLvl1 = '' SET @CdLvl1 = NULL
SET @CdLvl2 = RTRIM(LTRIM(@CdLvl2))
IF @CdLvl2 = '' SET @CdLvl2 = NULL
SET @CdLvl3 = RTRIM(LTRIM(@CdLvl3))
IF @CdLvl3 = '' SET @CdLvl3 = NULL
SET @CdLvl4 = RTRIM(LTRIM(@CdLvl4))
IF @CdLvl4 = '' SET @CdLvl4 = NULL
SET @CdLvl5 = RTRIM(LTRIM(@CdLvl5))
IF @CdLvl5 = '' SET @CdLvl5 = NULL
SET @CdLvl6 = RTRIM(LTRIM(@CdLvl6))
IF @CdLvl6 = '' SET @CdLvl6 = NULL

/* Get the formatted version of the full code based on the given Code parts */
SET @FullCode = cioc_shared.dbo.fn_SHR_TAX_FullCode (@CdLvl1,@CdLvl2,@CdLvl3,@CdLvl4,@CdLvl5,@CdLvl6,@CdLocal)

/* Old Code */
SELECT @Code = Code FROM TAX_Term WHERE TM_ID=@TM_ID

/* Determine the Code Level based on the given Code parts */
SET @CdLvl = CASE
	WHEN @CdLvl2 IS NULL THEN 1
	WHEN @CdLvl3 IS NULL THEN 2
	WHEN @CdLvl4 IS NULL THEN 3
	WHEN @CdLvl5 IS NULL THEN 4
	WHEN @CdLvl6 IS NULL THEN 5
	ELSE 6
END

/* Trim incoming data for all text-valued fields */
SET @IconURL = RTRIM(LTRIM(@IconURL))
IF @IconURL = '' SET @IconURL = NULL

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Term nvarchar(255) NULL,
	Definition nvarchar(max) NULL,
	Comments nvarchar(max) NULL,
	AltTerm nvarchar(255) NULL,
	AltDefinition nvarchar(max) NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max),
		@UsedNamesUseref nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Term,
	Definition,
	Comments,
	AltTerm,
	AltDefinition
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('Term[1]', 'nvarchar(255)'),
	N.value('Definition[1]', 'nvarchar(max)'),
	N.value('Comments[1]', 'nvarchar(max)'),
	N.value('AltTerm[1]', 'nvarchar(255)'),
	N.value('AltDefinition[1]', 'nvarchar(max)')
FROM @Descriptions.nodes('//DESC') as T(N)
WHERE NULLIF(N.value('Term[1]', 'nvarchar(255)'), '') IS NOT NULL

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Term
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM TAX_Term tm INNER JOIN TAX_Term_Description tmd ON tm.Code=tmd.Code WHERE Term=nt.Term AND LangID=nt.LangID AND (@TM_ID IS NULL OR @TM_ID<>tm.TM_ID))

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + AltTerm
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM TAX_Term tm INNER JOIN TAX_Term_Description tmd ON tm.Code=tmd.Code WHERE Term=nt.AltTerm AND LangID=nt.LangID AND (@TM_ID IS NULL OR @TM_ID<>tm.TM_ID))

SELECT @UsedNamesUseref = COALESCE(@UsedNamesUseref + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Term
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM TAX_Unused WHERE Term=nt.Term AND LangID=nt.LangID AND Active=1)

SELECT @UsedNamesUseref = COALESCE(@UsedNamesUseref + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + AltTerm
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM TAX_Unused WHERE Term=nt.AltTerm AND LangID=nt.LangID AND Active=1)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

IF @CdLvl=1 BEGIN
	SET @Active=0
END

IF @Active IS NULL AND NOT EXISTS(SELECT * FROM TAX_Term WHERE @Code LIKE Code+'%' AND @Code<>Code AND Active=1) BEGIN
	SET @Active=0
END

IF EXISTS(SELECT * FROM CIC_BT_TAX_TM WHERE Code=@Code) BEGIN
	SET @Active=1
END

/* Identify errors that will prevent the record from being updated */
IF @FullCode IS NULL BEGIN
	SET @Error = 4
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @TermObjectName, NULL)
END ELSE IF EXISTS(SELECT * FROM TAX_Term WHERE Code = @FullCode AND (@TM_ID IS NULL OR TM_ID<>@TM_ID)) BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FullCode, @TermObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @TermObjectName)
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
END ELSE IF @UsedNamesUseref IS NOT NULL BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @UseReferenceObjectName)
END ELSE IF @TM_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM TAX_Term WHERE TM_ID = @TM_ID) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@TM_ID AS varchar), @TermObjectName)
END ELSE IF @Source IS NOT NULL AND NOT EXISTS (SELECT * FROM TAX_Source WHERE TAX_SRC_ID = @Source) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Source AS varchar), @SourceObjectName)
END ELSE IF @Facet IS NOT NULL AND NOT EXISTS (SELECT * FROM TAX_Facet WHERE FC_ID = @Facet) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Facet AS varchar), @FacetObjectName)
/* No problems exists that will prevent the addtion / updating of this record, so insert / update the entry */
END ELSE BEGIN
	/* This is an existing Term; update the existing record */
	BEGIN TRAN UpdateTermTran

	IF @Code <> @FullCode BEGIN
		DELETE FROM TAX_SeeAlso WHERE Code=@Code
	END	

	IF @TM_ID IS NOT NULL BEGIN
		UPDATE TAX_Term
		SET  	MODIFIED_DATE	= GETDATE(),
				MODIFIED_BY		= @MODIFIED_BY,
				CdLvl1			= @CdLvl1,
				CdLvl2			= @CdLvl2,
				CdLvl3			= @CdLvl3,
				CdLvl4			= @CdLvl4,
				CdLvl5			= @CdLvl5,
				CdLocal			= @CdLocal,
				Source			= @Source,
				Authorized		= @Authorized,
				Facet			= @Facet,
				IconURL			= @IconURL,
				Active			= @Active
		WHERE (TM_ID = @TM_ID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @TermObjectName, @ErrMsg OUTPUT
	/* This is a new Term; Insert a new record */
	END ELSE BEGIN
		INSERT INTO TAX_Term (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			CdLvl1,
			CdLvl2,
			CdLvl3,
			CdLvl4,
			CdLvl5,
			CdLvl6,
			CdLocal,
			CdLvl,
			Code,
			Source,
			Authorized,
			Facet,
			IconURL,
			Active
		)
		VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@CdLvl1,
			@CdLvl2,
			@CdLvl3,
			@CdLvl4,
			@CdLvl5,
			@CdLvl6,
			@CdLocal,
			@CdLvl,
			@FullCode,
			@Source,
			@Authorized,
			@Facet,
			@IconURL,
			@Active
		)
		SET @TM_ID = SCOPE_IDENTITY()
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @TermObjectName, @ErrMsg OUTPUT
			
		SET @Code=@FullCode
	END

	IF @Error <> 0 BEGIN
		ROLLBACK TRAN
	END ELSE BEGIN
		COMMIT TRAN UpdateTermTran
	END

	/* Update the Descriptions (language-specific) data */
	IF @Error = 0 BEGIN
		SELECT @Code=Code FROM TAX_Term WHERE TM_ID=@TM_ID
		
		MERGE INTO TAX_Term_Description tmd
		USING @DescTable nt
			ON tmd.Code=@Code AND tmd.LangID=nt.LangID
		WHEN MATCHED THEN
			UPDATE SET 
				Term			= nt.TERM,
				Definition		= nt.Definition,
				Comments		= nt.Comments,
				AltTerm			= nt.AltTerm,
				AltDefinition	= nt.AltDefinition
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT (Code, LangID, Term, Definition, Comments, AltTerm, AltDefinition)
				VALUES (@Code, nt.LangID, nt.Term, nt.Definition, nt.Comments, nt.AltTerm, nt.AltDefinition)
		WHEN NOT MATCHED BY SOURCE AND tmd.Code=@Code THEN
			DELETE
			;
			
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @TermObjectName, @ErrMsg OUTPUT
	END

	/* Update the Related Terms ("See Also") list */
	IF @Error = 0 BEGIN
		/* Get the list of valid Related Term Codes for this record */
		DELETE FROM @tmpTCs
		
		INSERT INTO @tmpTCs
		SELECT DISTINCT tl.*
			FROM dbo.fn_GBL_ParseVarCharIDList(@SeeAlsoTCList,',') tl
			INNER JOIN TAX_Term tm
				ON tl.ItemID=tm.Code COLLATE Latin1_General_100_CI_AI
			WHERE tl.ItemID<>@Code

		/* Delete any Related Terms not in the new list */
		DELETE sa
			FROM TAX_SeeAlso sa
			LEFT JOIN @tmpTCs tl
				ON sa.SA_Code = tl.Code COLLATE Latin1_General_100_CI_AI
		WHERE tl.Code IS NULL AND sa.Code=@Code
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @TermObjectName, @ErrMsg OUTPUT

		/* Insert any Related Terms that are in the new list but not yet in the record */
		INSERT INTO TAX_SeeAlso (Code, SA_Code) SELECT @Code, tl.Code
			FROM @tmpTCs tl
		WHERE NOT EXISTS(SELECT * FROM TAX_SeeAlso sa WHERE sa.Code=@Code AND sa.SA_Code=tl.Code COLLATE Latin1_General_100_CI_AI)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @TermObjectName, @ErrMsg OUTPUT

		/* Get the list of authorized valid Related Term Codes for this record */
		DELETE FROM @tmpTCs
		
		INSERT INTO @tmpTCs
		SELECT DISTINCT tl.*
			FROM dbo.fn_GBL_ParseVarCharIDList(@SeeAlsoAuthList,',') tl
			INNER JOIN TAX_Term tm
				ON tl.ItemID=tm.Code COLLATE Latin1_General_100_CI_AI
			WHERE tl.ItemID <> @Code

		/* Update the authorized status of all Related Terms in this record */
		UPDATE sa
			SET Authorized = CASE WHEN tl.Code IS NULL THEN 0 ELSE 1 END
			FROM TAX_SeeAlso sa
			LEFT JOIN @tmpTCs tl
				ON sa.SA_Code=tl.Code COLLATE Latin1_General_100_CI_AI
			WHERE sa.Code=@Code
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @TermObjectName, @ErrMsg OUTPUT
	END
	
	/* Update the Related Concept list */
	IF @Error = 0 BEGIN

		/* Get the list of valid Related Concept IDs for this record */
		DELETE FROM @tmpRCIDs
		INSERT INTO @tmpRCIDs SELECT DISTINCT tm.*
			FROM dbo.fn_GBL_ParseIntIDList(@RelatedConceptList,',') tm
			INNER JOIN TAX_RelatedConcept rc ON tm.ItemID = rc.RC_ID

		/* Delete any Concepts that are not in the new list */
		DELETE pr
			FROM TAX_TM_RC pr
			LEFT JOIN @tmpRCIDs tm
				ON pr.RC_ID = tm.RC_ID
		WHERE tm.RC_ID IS NULL AND pr.Code=@Code
		
		/* Insert any Concepts that are in the new list but not yet in the record */
		INSERT INTO TAX_TM_RC (Code, RC_ID) SELECT @Code, tm.RC_ID
			FROM @tmpRCIDs tm
		WHERE NOT EXISTS(SELECT * FROM TAX_TM_RC pr WHERE Code=@Code AND pr.RC_ID=tm.RC_ID)

		/* Get the list of authorized valid Related Concept IDs for this record */
		DELETE FROM @tmpRCIDs
		INSERT INTO @tmpRCIDs SELECT DISTINCT tm.*
			FROM dbo.fn_GBL_ParseIntIDList(@RelatedConceptAuthList,',') tm
			INNER JOIN TAX_RelatedConcept rc ON tm.ItemID = rc.RC_ID

		/* Update the authorized status of all Concepts in this record */
		UPDATE pr
			SET Authorized = CASE WHEN tm.RC_ID IS NULL THEN 0 ELSE 1 END
			FROM TAX_TM_RC pr
			LEFT JOIN @tmpRCIDs tm
				ON pr.RC_ID=tm.RC_ID
			WHERE pr.Code=@Code
	END
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @TermObjectName, @ErrMsg OUTPUT

	/* Synchronize a local activation in one-member database */
	IF (SELECT COUNT(*) FROM STP_Member WHERE Active=1)=1 BEGIN
		DECLARE @TmpMemberID int
		SELECT TOP 1 @TmpMemberID=MemberID FROM STP_Member WHERE Active=1
		
		MERGE INTO TAX_Term_ActivationByMember tac
		USING (SELECT Code FROM TAX_Term WHERE Active=1) nt
			ON nt.Code=tac.Code AND tac.MemberID=@TmpMemberID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (Code, MemberID) VALUES (nt.Code, @TmpMemberID)
		WHEN NOT MATCHED BY SOURCE AND tac.MemberID=@TmpMemberID THEN
			DELETE
			;
	END

	EXEC sp_CIC_SRCH_TAX_u NULL
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_TAX_Term_u] TO [cioc_login_role]
GO
