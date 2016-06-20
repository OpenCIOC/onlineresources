SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_MappingSystem_u]
	@MAP_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@NewWindow [bit],
	@DefaultProvince [char](2),
	@DefaultCountry [nvarchar](50),
	@Descriptions [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MappingSystemObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LabelObjectName nvarchar(100),
		@LinkObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@ProvinceObjectName nvarchar(100),
		@CountryObjectName nvarchar(100)

SET @MappingSystemObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Mapping System')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LabelObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Label')
SET @LinkObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Link')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @ProvinceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Province')
SET @CountryObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Country')


DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Name nvarchar(50) NULL,
	Label nvarchar(200) NULL,
	String varchar(255) NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Name,
	Label,
	String
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND ActiveRecord=1) AS LangID,
	N.value('Name[1]', 'nvarchar(50)') AS Name,
	N.value('Label[1]', 'nvarchar(200)') AS Label,
	N.value('String[1]', 'varchar(255)') AS String
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM GBL_MappingSystem map INNER JOIN GBL_MappingSystem_Name mapn ON map.MAP_ID=mapn.MAP_ID WHERE Name=nt.Name AND LangID=nt.LangID AND map.MAP_ID<>@MAP_ID)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

IF @MAP_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_MappingSystem WHERE MAP_ID=@MAP_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MAP_ID AS varchar), @MappingSystemObjectName)
END IF  @DefaultProvince IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProvinceObjectName, @MappingSystemObjectName)
END IF  @DefaultCountry IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CountryObjectName, @MappingSystemObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE Name IS NOT NULL AND Label IS NOT NULL AND String IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @MappingSystemObjectName)
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @MappingSystemObjectName)
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	IF @MAP_ID IS NULL BEGIN
		INSERT INTO GBL_MappingSystem (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			NewWindow,
			DefaultProvince,
			DefaultCountry
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@NewWindow,
			@DefaultProvince,
			@DefaultCountry
		)
		SELECT @MAP_ID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE GBL_MappingSystem
		SET	MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY,
			NewWindow		= @NewWindow,
			DefaultProvince	= @DefaultProvince,
			DefaultCountry	= @DefaultCountry
		WHERE MAP_ID = @MAP_ID	
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @MappingSystemObjectName, @ErrMsg
	

	IF @Error=0 AND @MAP_ID IS NOT NULL BEGIN
		DELETE mapn
		FROM GBL_MappingSystem_Name mapn
		WHERE mapn.MAP_ID=@MAP_ID
			AND EXISTS(SELECT * FROM @DescTable nt WHERE mapn.LangID=nt.LangID AND Name IS NULL)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @MappingSystemObjectName, @ErrMsg
		
		UPDATE mapn SET
			Name		= nt.Name,
			Label		= nt.Label,
			String		= nt.String
		FROM GBL_MappingSystem_Name mapn
		INNER JOIN @DescTable nt
			ON mapn.LangID=nt.LangID
		WHERE mapn.MAP_ID=@MAP_ID
	
		INSERT INTO GBL_MappingSystem_Name (
			MAP_ID,
			LangID,
			Name,
			Label,
			String
		) SELECT
			@MAP_ID,
			LangID,
			Name,
			Label,
			String
		FROM @DescTable nt
		WHERE NOT EXISTS(SELECT * FROM GBL_MappingSystem_Name WHERE MAP_ID=@MAP_ID AND LangID=nt.LangID) AND Name IS NOT NULL
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @MappingSystemObjectName, @ErrMsg
	END
END

RETURN @Error

SET NOCOUNT OFF









GO
GRANT EXECUTE ON  [dbo].[sp_GBL_MappingSystem_u] TO [cioc_login_role]
GO
