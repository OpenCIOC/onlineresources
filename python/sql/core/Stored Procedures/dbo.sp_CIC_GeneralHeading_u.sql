
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_GeneralHeading_u]
	@GH_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@SuperUserGlobal bit,
	@PB_ID [int],
	@Used [bit],
	@NonPublic [bit],
	@DisplayOrder [tinyint],
	@HeadingGroup [int],
	@TaxonomyName bit,
	@MustMatch xml = NULL,
	@MatchAny xml = NULL,
	@TaxonomyRestrict bit,
	@IconNameFull varchar(65),
	@Descriptions [xml],
	@RelatedHeadings [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 28-Apr-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@GeneralHeadingObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@OrderObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @GeneralHeadingObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('General Heading')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @OrderObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Order')

IF @GH_ID IS NOT NULL BEGIN
	SELECT @PB_ID=ISNULL(gh.PB_ID, @PB_ID), @Used = CASE WHEN Used IS NULL THEN Used ELSE @Used END
		FROM CIC_GeneralHeading gh
	WHERE gh.GH_ID=@GH_ID
END

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Name nvarchar(200) NULL
)

DECLARE @RelatedHeadingTable TABLE ( 
	GH_ID int NOT NULL
)

DECLARE @LinkTable TABLE (
	LinkID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	MatchID int,
	MatchAny bit NOT NULL,
	Link xml 
)

DECLARE @TermTable TABLE (
	LinkID int NOT NULL,
	Code varchar(21) NOT NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)
		
IF @Used IS NOT NULL OR @TaxonomyName=0 BEGIN
	INSERT INTO @DescTable (
		Culture,
		LangID,
		Name
	)
	SELECT
		N.value('Culture[1]', 'varchar(5)') AS Culture,
		(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
		N.value('Name[1]', 'nvarchar(200)') AS Name
	FROM @Descriptions.nodes('//DESC') as T(N)
	
	SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
	FROM @DescTable nt
	WHERE EXISTS(SELECT * FROM CIC_GeneralHeading gh INNER JOIN CIC_GeneralHeading_Name ghn ON gh.GH_ID=ghn.GH_ID WHERE Name=nt.Name AND LangID=nt.LangID AND (@GH_ID IS NULL OR gh.GH_ID<>@GH_ID) AND gh.PB_ID=@PB_ID)

	SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
	FROM @DescTable nt
	WHERE LangID IS NULL
END

INSERT INTO @RelatedHeadingTable (
	GH_ID
)
SELECT N.value('.', 'int') AS GH_ID
FROM @RelatedHeadings.nodes('//HEADING') AS T(N)

IF @Used IS NULL BEGIN

	IF @MatchAny IS NOT NULL BEGIN
		INSERT INTO @LinkTable (Link,MatchAny)
		SELECT N.query('.') AS Link, 1 AS MatchAny
		FROM @MatchAny.nodes('//terms/link') as T(N)
	END

	IF @MustMatch IS NOT NULL BEGIN
		INSERT INTO @LinkTable (Link,MatchAny)
		SELECT N.query('.') AS Link, 0 AS MatchAny
		FROM @MustMatch.nodes('//terms/link') as T(N)
	END

	IF EXISTS(SELECT * FROM @LinkTable) BEGIN
		INSERT INTO @TermTable (LinkID, Code)
		SELECT LinkID, N.value('.','varchar(21)') AS Code
		FROM @LinkTable
			CROSS APPLY Link.nodes('//link/code')AS T(N)
		INNER JOIN TAX_Term tm
			ON N.value('.','varchar(21)') = tm.Code
		
		DELETE lt
			FROM @LinkTable lt
			WHERE NOT EXISTS(SELECT * FROM @TermTable tt WHERE lt.LinkID=tt.LinkID)
			
		UPDATE lt
			SET MatchID = (SELECT TOP 1 ght.GH_TAX_ID
				FROM CIC_GeneralHeading_TAX ght
				WHERE lt.MatchAny=ght.MatchAny AND ght.GH_ID=@GH_ID
					AND NOT EXISTS(SELECT *
						FROM CIC_GeneralHeading_TAX_TM ghtm
						LEFT JOIN @TermTable tt
							ON ghtm.Code=tt.Code AND tt.LinkID=lt.LinkID
						WHERE ghtm.GH_TAX_ID=ght.GH_TAX_ID
							AND tt.LinkID IS NULL
						)
					AND NOT EXISTS(SELECT *
						FROM @TermTable tt
						LEFT JOIN CIC_GeneralHeading_TAX_TM ghtm
							ON tt.Code=ghtm.Code AND ghtm.GH_TAX_ID=ght.GH_TAX_ID
						WHERE tt.LinkID=lt.LinkID
							AND ghtm.GH_TAX_ID IS NULL
						)
				)
		FROM @LinkTable lt
	END

	SET @TaxonomyName = ISNULL(@TaxonomyName,0)
	SET @TaxonomyRestrict = ISNULL(@TaxonomyRestrict,0)
END ELSE BEGIN
	SET @TaxonomyName = 0
	SET @TaxonomyRestrict = 0
END

IF NOT EXISTS(SELECT * FROM STP_Icon WHERE Type + '-' + IconName = @IconNameFull) BEGIN
	SET @IconNameFull=NULL
END

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Heading ID exists ?
END ELSE IF @GH_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM CIC_GeneralHeading WHERE GH_ID=@GH_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@GH_ID AS varchar), @GeneralHeadingObjectName)
-- Heading belongs to Member ?
END ELSE IF @GH_ID IS NOT NULL AND NOT EXISTS(SELECT *
		FROM CIC_Publication pb INNER JOIN CIC_GeneralHeading gh ON pb.PB_ID=gh.PB_ID
		WHERE GH_ID=@GH_ID AND ((pb.MemberID IS NULL AND (@SuperUserGlobal=1 OR pb.CanEditHeadingsShared=1)) OR pb.MemberID=@MemberID)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Publication given ?
END ELSE IF @GH_ID IS NULL AND @PB_ID IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, @GeneralHeadingObjectName)
-- Publication exists ?
END ELSE IF @GH_ID IS NULL AND NOT EXISTS(SELECT * FROM CIC_Publication WHERE PB_ID=@PB_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PB_ID AS varchar), @PublicationObjectName)
-- Publication belongs to Member ?
END ELSE IF @GH_ID IS NULL AND NOT EXISTS(SELECT *
		FROM CIC_Publication pb WHERE PB_ID=@PB_ID AND (pb.MemberID IS NULL AND (@SuperUserGlobal=1 OR pb.CanEditHeadingsShared=1)) OR pb.MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Display Order given ?
END ELSE IF @DisplayOrder IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrderObjectName, @GeneralHeadingObjectName)
-- Duplicate language data given ?
END ELSE IF (@Used IS NOT NULL OR @TaxonomyName=0) AND (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name provided ?
END ELSE IF (@Used IS NOT NULL OR @TaxonomyName=0) AND NOT EXISTS(SELECT * FROM @DescTable WHERE Name IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @GeneralHeadingObjectName)
-- Name in use ?
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
-- Invalid language ?
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
-- Heading group exists ?
END ELSE IF @HeadingGroup IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_GeneralHeading_Group WHERE PB_ID=@PB_ID AND GroupID=@HeadingGroup) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@HeadingGroup AS varchar), cioc_shared.dbo.fn_SHR_STP_ObjectName('Group'))
END ELSE IF @Used IS NULL AND (SELECT COUNT(*) FROM @TermTable)=0 BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Taxonomy Term'), @GeneralHeadingObjectName)
END

IF @Error = 0 BEGIN
	IF @GH_ID IS NULL BEGIN
		INSERT INTO CIC_GeneralHeading (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			Used,
			NonPublic,
			DisplayOrder,
			HeadingGroup,
			TaxonomyName,
			TaxonomyRestrict,
			IconNameFull,
			PB_ID
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@Used,
			@NonPublic,
			@DisplayOrder,
			@HeadingGroup,
			@TaxonomyName,
			@TaxonomyRestrict,
			@IconNameFull,
			@PB_ID
		)
		SELECT @GH_ID = SCOPE_IDENTITY()
	END ELSE BEGIN
		IF EXISTS(SELECT * FROM CIC_BT_PB_GH WHERE GH_ID=@GH_ID AND @Used IS NOT NULL) BEGIN
			SET @Used=1
		END

		UPDATE CIC_GeneralHeading
		SET	MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY,
			Used			= CASE WHEN Used IS NULL THEN Used ELSE @Used END,
			NonPublic		= @NonPublic,
			DisplayOrder	= @DisplayOrder,
			HeadingGroup	= @HeadingGroup,
			TaxonomyName    = @TaxonomyName,
			TaxonomyRestrict= @TaxonomyRestrict,
			IconNameFull	= @IconNameFull
		WHERE GH_ID = @GH_ID	
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @GeneralHeadingObjectName, @ErrMsg

	IF @Error=0 AND @GH_ID IS NOT NULL BEGIN
		DELETE ghn
		FROM CIC_GeneralHeading_Name ghn
		WHERE ghn.GH_ID=@GH_ID
			AND EXISTS(SELECT * FROM @DescTable nt WHERE ghn.LangID=nt.LangID AND Name IS NULL)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @GeneralHeadingObjectName, @ErrMsg
		
		UPDATE ghn SET
			Name		= nt.Name
		FROM CIC_GeneralHeading_Name ghn
		INNER JOIN @DescTable nt
			ON ghn.LangID=nt.LangID
		WHERE ghn.GH_ID=@GH_ID
	
		INSERT INTO CIC_GeneralHeading_Name (
			GH_ID,
			LangID,
			Name
		) SELECT
			@GH_ID,
			LangID,
			Name
		FROM @DescTable nt
		WHERE NOT EXISTS(SELECT * FROM CIC_GeneralHeading_Name WHERE GH_ID=@GH_ID AND LangID=nt.LangID) AND Name IS NOT NULL
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @GeneralHeadingObjectName, @ErrMsg
		
		MERGE INTO CIC_GeneralHeading_Related AS ghr
		USING @RelatedHeadingTable AS nt
		ON ghr.GH_ID=@GH_ID AND nt.GH_ID=ghr.RelatedGH_ID
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (GH_ID, RelatedGH_ID) VALUES (@GH_ID, nt.GH_ID)
		WHEN NOT MATCHED BY SOURCE AND ghr.GH_ID=@GH_ID
			THEN DELETE ;	
	
		IF @Used IS NULL BEGIN
			DECLARE @GHTaxIDMap TABLE (
				GH_TAX_ID int,
				LinkID int
			)
		
			MERGE INTO CIC_GeneralHeading_TAX dst
			USING (SELECT LinkID, MatchID, MatchAny FROM @LinkTable) src
				ON dst.GH_TAX_ID=src.MatchID
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (GH_ID, MatchAny) VALUES (@GH_ID, src.MatchAny)
			WHEN NOT MATCHED BY SOURCE AND dst.GH_ID=@GH_ID THEN
				DELETE
			OUTPUT INSERTED.GH_TAX_ID, src.LinkID INTO @GHTaxIDMap (GH_TAX_ID, LinkID)
			;
			
			DELETE FROM @GHTaxIDMap WHERE GH_TAX_ID IS NULL

			INSERT INTO CIC_GeneralHeading_TAX_TM (GH_TAX_ID, Code)
				SELECT tm.GH_TAX_ID, tt.Code
					FROM @GHTaxIDMap tm
					INNER JOIN @TermTable tt
						ON tm.LinkID=tt.LinkID
		END ELSE BEGIN
			DELETE FROM CIC_GeneralHeading_TAX WHERE GH_ID=@GH_ID
		END
	END
END

RETURN @Error

SET NOCOUNT OFF









GO





GRANT EXECUTE ON  [dbo].[sp_CIC_GeneralHeading_u] TO [cioc_login_role]
GO
