
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_Interest_u]
	@AI_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@Code varchar(20),
	@Descriptions [xml],
	@Groups [xml],
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

DECLARE	@CodeObjectName nvarchar(100),
		@InterestObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@GroupObjectName nvarchar(100)

SET @CodeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Code')
SET @InterestObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Interest')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @GroupObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Group')

DECLARE @DescTable table (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Name nvarchar(200) NULL
)

DECLARE @GroupTable table (
	IG_ID int NOT NULL
)

DECLARE @UsedNames nvarchar(MAX),
		@BadCultures nvarchar(MAX)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Name
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND ActiveRecord=1) AS LangID,
	N.value('Name[1]', 'nvarchar(200)') AS Name
FROM @Descriptions.nodes('//DESC') AS T(N)

INSERT INTO @GroupTable
	( IG_ID )
SELECT 
	N.value('.', 'int') AS ViewType
FROM @Groups.nodes('//GROUP') AS T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @GroupObjectName, @ErrMsg



SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM VOL_Interest ai INNER JOIN VOL_Interest_Name ain ON ai.AI_ID=ain.AI_ID WHERE Name=nt.Name AND LangID=nt.LangID AND (@AI_ID IS NULL OR ai.AI_ID<>@AI_ID))

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

IF @AI_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM VOL_Interest WHERE AI_ID=@AI_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@AI_ID AS varchar), @InterestObjectName)
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @InterestObjectName)
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END ELSE IF @Code IS NOT NULL AND EXISTS(SELECT * FROM VOL_Interest WHERE Code=@Code AND (@AI_ID IS NULL OR AI_ID <> @AI_ID)) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Code, @CodeObjectName)
END

IF @Error = 0 BEGIN
	IF @AI_ID IS NULL BEGIN
		INSERT INTO VOL_Interest (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			Code
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@Code
		)
		SELECT @AI_ID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE VOL_Interest
		SET	MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY,
			Code			= @Code
		WHERE AI_ID = @AI_ID	
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @InterestObjectName, @ErrMsg
	

	IF @Error=0 AND @AI_ID IS NOT NULL BEGIN
		DELETE ain
		FROM VOL_Interest_Name ain
		WHERE ain.AI_ID=@AI_ID
			AND EXISTS(SELECT * FROM @DescTable nt WHERE ain.LangID=nt.LangID AND Name IS NULL)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @InterestObjectName, @ErrMsg
		
		UPDATE ain SET
			Name		= nt.Name
		FROM VOL_Interest_Name ain
		INNER JOIN @DescTable nt
			ON ain.LangID=nt.LangID
		WHERE ain.AI_ID=@AI_ID
	
		INSERT INTO VOL_Interest_Name (
			AI_ID,
			LangID,
			Name
		) SELECT
			@AI_ID,
			LangID,
			Name
		FROM @DescTable nt
		WHERE NOT EXISTS(SELECT * FROM VOL_Interest_Name WHERE AI_ID=@AI_ID AND LangID=nt.LangID) AND Name IS NOT NULL
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @InterestObjectName, @ErrMsg
		
		MERGE INTO VOL_AI_IG as aiig
		USING (SELECT IG_ID FROM @GroupTable) nt
		ON @AI_ID=aiig.AI_ID AND nt.IG_ID=aiig.IG_ID
		WHEN NOT MATCHED BY TARGET 
			THEN INSERT (AI_ID, IG_ID) VALUES (@AI_ID, nt.IG_ID)
		WHEN NOT MATCHED BY SOURCE AND aiig.AI_ID = @AI_ID
			THEN DELETE ;
	END

END

RETURN @Error

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_u] TO [cioc_login_role]
GO
