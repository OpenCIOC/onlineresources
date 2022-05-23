SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_ExtraEmail_i]
	@NUM varchar(8),
	@HAS_ENGLISH bit,
	@HAS_FRENCH bit,
	@ExtraEmailType varchar(100),
	@ExtraEmailEn varchar(100),
	@ExtraEmailFr varchar(100),
	@FieldID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

SET @ExtraEmailEn = RTRIM(LTRIM(@ExtraEmailEn))
IF @ExtraEmailEn = '' SET @ExtraEmailEn = NULL
SET @ExtraEmailFr = RTRIM(LTRIM(@ExtraEmailFr))
IF @ExtraEmailFr = '' SET @ExtraEmailFr = NULL

SET @FieldID = NULL

SELECT @FieldID=FieldID
	FROM GBL_FieldOption
WHERE ExtraFieldType='e' AND FieldName=@ExtraEmailType

IF @FieldID IS NOT NULL BEGIN
	IF @HAS_ENGLISH=1 BEGIN
		EXEC sp_CIC_ImportEntry_CICE_Check_i @NUM
		
		IF @ExtraEmailEn IS NULL BEGIN
			DELETE FROM CIC_BT_EXTRA_EMAIL WHERE NUM=@NUM AND [LangID]=0 AND FieldName=@ExtraEmailType
		END ELSE BEGIN
			IF EXISTS(SELECT * FROM CIC_BT_EXTRA_EMAIL WHERE NUM=@NUM AND [LangID]=0 AND FieldName=@ExtraEmailType) BEGIN
				UPDATE CIC_BT_EXTRA_EMAIL
					SET [Value] = @ExtraEmailEn
				WHERE NUM=@NUM AND [LangID]=0 AND FieldName=@ExtraEmailType
			END ELSE BEGIN
				INSERT INTO CIC_BT_EXTRA_EMAIL (
					FieldName,
					NUM,
					[LangID],
					[Value]
				)
				SELECT	@ExtraEmailType,
						NUM,
						LangID,
						@ExtraEmailEn
					FROM GBL_BaseTable_Description
				WHERE NUM=@NUM AND LangID=0
			END
		END
	END
	IF @HAS_FRENCH=1 BEGIN
		EXEC sp_CIC_ImportEntry_CICF_Check_i @NUM
		
		IF @ExtraEmailEn IS NULL BEGIN
			DELETE FROM CIC_BT_EXTRA_EMAIL WHERE NUM=@NUM AND [LangID]=2 AND FieldName=@ExtraEmailType
		END ELSE BEGIN
			IF EXISTS(SELECT * FROM CIC_BT_EXTRA_EMAIL WHERE NUM=@NUM AND [LangID]=2 AND FieldName=@ExtraEmailType) BEGIN
				UPDATE CIC_BT_EXTRA_EMAIL
					SET [Value] = @ExtraEmailFr
				WHERE NUM=@NUM AND [LangID]=2 AND FieldName=@ExtraEmailType
			END ELSE BEGIN
				INSERT INTO CIC_BT_EXTRA_EMAIL (
					FieldName,
					NUM,
					[LangID],
					[Value]
				)
				SELECT	@ExtraEmailType,
						NUM,
						LangID,
						@ExtraEmailFr
					FROM GBL_BaseTable_Description
				WHERE NUM=@NUM AND LangID=2
			END
		END
	END
END

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_ExtraEmail_i] TO [cioc_login_role]
GO
