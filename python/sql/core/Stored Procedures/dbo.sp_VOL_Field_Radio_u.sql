SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Field_Radio_u]
	@MODIFIED_BY [varchar](50),
	@Data [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 06-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@FieldObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @DescTable TABLE (
	FieldID int NOT NULL,
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	CheckboxOnText nvarchar(20) NULL,
	CheckboxOffText nvarchar(20)
)

DECLARE @BadCulturesDesc nvarchar(max)

INSERT INTO @DescTable (
	FieldID,
	Culture,
	LangID,
	CheckboxOnText,
	CheckboxOffText
)
SELECT
	N.query('FieldID').value('/', 'int') AS FieldID,
	iq.*

FROM @Data.nodes('//Field') as T(N) CROSS APPLY 
	( SELECT 
		D.query('Culture').value('/', 'varchar(5)') AS Culture,
		(SELECT LangID FROM STP_Language sl WHERE sl.Culture = D.query('Culture').value('/', 'varchar(5)') AND ActiveRecord=1) AS LangID,
		CASE WHEN D.exist('CheckboxOnText')=1 THEN D.query('CheckboxOnText').value('/', 'nvarchar(50)') ELSE NULL END AS CheckboxOnText,
		CASE WHEN D.exist('CheckboxOffText')=1 THEN D.query('CheckboxOffText').value('/', 'nvarchar(50)') ELSE NULL END AS CheckboxOffText
			FROM N.nodes('DESCS/DESC') AS T2(D) ) iq 
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	UPDATE fod SET
		CheckboxOnText = nf.CheckboxOnText,
		CheckboxOffText = nf.CheckboxOffText,
		MODIFIED_BY = @MODIFIED_BY,
		MODIFIED_DATE = GETDATE()
	FROM VOL_FieldOption_Description fod
	INNER JOIN @DescTable nf
		ON fod.LangID=nf.LangID AND fod.FieldID=nf.FieldID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

	INSERT INTO VOL_FieldOption_Description (
		CREATED_BY,
		CREATED_DATE,
		MODIFIED_BY,
		MODIFIED_DATE,
		FieldID,
		LangID,
		CheckboxOnText,
		CheckboxOffText
	) SELECT 
		@MODIFIED_BY,
		GETDATE(),
		@MODIFIED_BY,
		GETDATE(),
		nf.FieldID,
		LangID,
		CheckboxOnText,
		CheckboxOffText
	FROM @DescTable nf
	INNER JOIN VOL_FieldOption fo
		ON fo.FieldID = nf.FieldID
	WHERE NOT EXISTS(SELECT * FROM VOL_FieldOption_Description WHERE FieldID=nf.FieldID AND LangID=nf.LangID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Field_Radio_u] TO [cioc_login_role]
GO
