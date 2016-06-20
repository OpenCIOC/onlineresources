
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Template_Layout_u]
	@LayoutID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@AgencyCode [char](3),
	@Owner [char](3),
	@FullSSLCompatible bit,
	@LayoutType [varchar](10),
	@LayoutCSS [varchar](max),
	@LayoutCSSURL [varchar](200),
	@AlmostStandardsMode [bit],
	@UseFontAwesome[bit],
	@UseFullCIOCBootstrap [bit],
	@Descriptions [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 02-Feb-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@LayoutObjectName nvarchar(100),
		@LayoutTypeObjectName nvarchar(100),
		@AgencyObjectName nvarchar(100),
		@CSSObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @LayoutObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Template Layout')
SET @LayoutTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Layout Type')
SET @AgencyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency')
SET @CSSObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CSS')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	LayoutName varchar(150) NULL,
	LayoutHTML varchar(max) NULL,
	LayoutHTMLURL varchar(200) NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	LayoutName,
	LayoutHTML,
	LayoutHTMLURL
)
SELECT
	N.query('LANG').value('/', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.query('LANG').value('/', 'varchar(5)') AND Active=1) AS LangID,
	N.value('LayoutName[1]', 'nvarchar(150)') AS LayoutName,
	N.value('LayoutHTML[1]', 'nvarchar(max)') AS LayoutHTML,
	N.value('LayoutHTMLURL[1]', 'nvarchar(200)') AS LayoutHTMLURL
FROM @Descriptions.nodes('//DESC') as T(N)

UPDATE @DescTable
	SET LayoutName = (SELECT TOP 1 LayoutName FROM @DescTable WHERE LayoutName IS NOT NULL ORDER BY LangID)
WHERE LayoutName IS NULL

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + LayoutName
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM GBL_Template_Layout tl INNER JOIN GBL_Template_Layout_Description tld ON tl.LayoutID=tld.LayoutID WHERE LayoutName=nt.LayoutName AND LangID=nt.LangID AND tl.LayoutID<>@LayoutID AND tl.MemberID=@MemberID)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
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
-- Layout exists ?
END ELSE IF @LayoutID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_Template_Layout WHERE LayoutID=@LayoutID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@LayoutID AS varchar), @LayoutObjectName)
-- Not a System Layout ?
END ELSE IF @LayoutID IS NOT NULL AND EXISTS (SELECT * FROM GBL_Template_Layout WHERE LayoutID=@LayoutID AND SystemLayout=1) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('System Layout'), NULL)
-- Layout belongs to Member ?
END ELSE IF @LayoutID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_Template_Layout WHERE LayoutID=@LayoutID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Agency exists ?
END ELSE IF @Owner IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Agency WHERE AgencyCode=@Owner) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Owner, @AgencyObjectName)
-- Ownership OK ?
END ELSE IF @LayoutID IS NOT NULL AND @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Template_Layout WHERE LayoutID=@LayoutID AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LayoutObjectName, NULL)
-- Layout Type given ?
END ELSE IF @LayoutID IS NULL AND @LayoutType IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LayoutTypeObjectName, @LayoutObjectName)
-- Layout Type exists ?
END ELSE IF @LayoutID IS NULL AND NOT EXISTS(SELECT * FROM GBL_Template_Layout_Type WHERE LayoutType=@LayoutType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LayoutType, @LayoutTypeObjectName)
-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @LayoutObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE LayoutName IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @LayoutObjectName)
-- Name in use ?
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
-- Invalid language ?
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	IF @LayoutID IS NULL BEGIN
		INSERT INTO GBL_Template_Layout (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			Owner,
			FullSSLCompatible,
			LayoutType,
			LayoutCSS,
			LayoutCSSURL,
			LayoutCSSVersionDate,
			AlmostStandardsMode,
			UseFontAwesome,
			UseFullCIOCBootstrap
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@Owner,
			@FullSSLCompatible,
			@LayoutType,
			@LayoutCSS,
			@LayoutCSSURL,
			GETDATE(),
			@AlmostStandardsMode,
			@UseFontAwesome,
			@UseFullCIOCBootstrap
		)
		SELECT @LayoutID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE GBL_Template_Layout
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			Owner				= @Owner,
			FullSSLCompatible	= @FullSSLCompatible,
			LayoutCSS			= @LayoutCSS,
			LayoutCSSURL		= @LayoutCSSURL,
			AlmostStandardsMode = @AlmostStandardsMode,
			UseFontAwesome		= @UseFontAwesome,
			UseFullCIOCBootstrap	= ISNULL(@UseFullCIOCBootstrap,@UseFullCIOCBootstrap)
		WHERE LayoutID = @LayoutID	
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @LayoutObjectName, @ErrMsg
	

	IF @Error=0 AND @LayoutID IS NOT NULL BEGIN
		DELETE tld
		FROM GBL_Template_Layout_Description tld
		WHERE tld.LayoutID=@LayoutID
			AND NOT EXISTS(SELECT * FROM @DescTable nt WHERE tld.LangID=nt.LangID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @LayoutObjectName, @ErrMsg
		
		UPDATE tld SET
			LayoutName		= nt.LayoutName,
			LayoutHTML		= nt.LayoutHTML,
			LayoutHTMLURL	= nt.LayoutHTMLURL
		FROM GBL_Template_Layout_Description tld
		INNER JOIN @DescTable nt
			ON tld.LangID=nt.LangID
		WHERE tld.LayoutID=@LayoutID
	
		INSERT INTO GBL_Template_Layout_Description (
			LayoutID,
			LangID,
			LayoutName,
			LayoutHTML,
			LayoutHTMLURL
		) SELECT
			@LayoutID,
			LangID,
			LayoutName,
			LayoutHTML,
			LayoutHTMLURL
		FROM @DescTable nt
		WHERE NOT EXISTS(SELECT * FROM GBL_Template_Layout_Description WHERE LayoutID=@LayoutID AND LangID=nt.LangID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @LayoutObjectName, @ErrMsg
	END
END

RETURN @Error

SET NOCOUNT OFF















GO




GRANT EXECUTE ON  [dbo].[sp_GBL_Template_Layout_u] TO [cioc_login_role]
GO
