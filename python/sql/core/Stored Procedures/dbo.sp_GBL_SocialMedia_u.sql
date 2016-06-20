
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_SocialMedia_u]
	@SM_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@DefaultName [nvarchar](100),
	@GeneralURL [varchar](200),
	@IconURL16 varchar(200),
	@IconURL24 varchar(200),
	@Active [bit],
	@Descriptions [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@SocialMediaObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@IconURL16ObjectName nvarchar(100),
		@IconURL24ObjectName nvarchar(100)


SET @SocialMediaObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Social Media Type')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @IconURL16ObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('16px Icon URL')
SET @IconURL24ObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('24px Icon URL')


DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Name nvarchar(50) NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Name
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND ActiveRecord=1) AS LangID,
	N.value('Name[1]', 'nvarchar(50)') AS Name
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM GBL_SocialMedia sm INNER JOIN GBL_SocialMedia_Name smn ON sm.SM_ID=smn.SM_ID WHERE Name=nt.Name AND LangID=nt.LangID AND sm.SM_ID<>@SM_ID)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

IF @SM_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_SocialMedia WHERE SM_ID=@SM_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SM_ID AS varchar), @SocialMediaObjectName)
END ELSE IF  @DefaultName IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @SocialMediaObjectName)
END ELSE IF  @IconURL16 IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @IconURL16ObjectName, @SocialMediaObjectName)
END ELSE IF  @IconURL24 IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @IconURL24ObjectName, @SocialMediaObjectName)
END ELSE IF EXISTS(SELECT * FROM GBL_SocialMedia WHERE (@SM_ID IS NULL OR SM_ID<>@SM_ID) AND IconURL16=@IconURL16) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @IconURL16, @IconURL16ObjectName)
END ELSE IF EXISTS(SELECT * FROM GBL_SocialMedia WHERE (@SM_ID IS NULL OR SM_ID<>@SM_ID) AND IconURL24=@IconURL24) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @IconURL24, @IconURL24ObjectName)
END ELSE IF EXISTS(SELECT * FROM GBL_SocialMedia WHERE (@SM_ID IS NULL OR SM_ID<>@SM_ID) AND DefaultName=@DefaultName) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @SocialMediaObjectName)
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	IF @SM_ID IS NULL BEGIN
		INSERT INTO GBL_SocialMedia (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			DefaultName,
			GeneralURL,
			IconURL16,
			IconURL24,
			Active
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@DefaultName,
			@GeneralURL,
			@IconURL16,
			@IconURL24,
			@Active
		)
		SELECT @SM_ID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE GBL_SocialMedia
		SET	MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY,
			DefaultName		= @DefaultName,
			GeneralURL		= @GeneralURL,
			IconURL16		= @IconURL16,
			IconURL24		= @IconURL24,
			Active			= @Active
		WHERE SM_ID = @SM_ID	
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SocialMediaObjectName, @ErrMsg
	

	IF @Error=0 AND @SM_ID IS NOT NULL BEGIN
		DELETE smn
		FROM GBL_SocialMedia_Name smn
		WHERE smn.SM_ID=@SM_ID
			AND EXISTS(SELECT * FROM @DescTable nt WHERE smn.LangID=nt.LangID AND Name IS NULL)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SocialMediaObjectName, @ErrMsg
		
		UPDATE smn SET
			Name		= nt.Name
		FROM GBL_SocialMedia_Name smn
		INNER JOIN @DescTable nt
			ON smn.LangID=nt.LangID
		WHERE smn.SM_ID=@SM_ID
	
		INSERT INTO GBL_SocialMedia_Name (
			SM_ID,
			LangID,
			Name
		) SELECT
			@SM_ID,
			LangID,
			Name
		FROM @DescTable nt
		WHERE NOT EXISTS(SELECT * FROM GBL_SocialMedia_Name WHERE SM_ID=@SM_ID AND LangID=nt.LangID) AND Name IS NOT NULL
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SocialMediaObjectName, @ErrMsg
	END
END

RETURN @Error

SET NOCOUNT OFF











GO

GRANT EXECUTE ON  [dbo].[sp_GBL_SocialMedia_u] TO [cioc_login_role]
GO
