SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_ExtraText_i]
	@NUM varchar(8),
	@HAS_ENGLISH bit,
	@HAS_FRENCH bit,
	@ExtraTextType varchar(100),
	@ExtraTextEn nvarchar(max),
	@ExtraTextFr nvarchar(max),
	@FieldID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
*/

SET @ExtraTextEn = RTRIM(LTRIM(@ExtraTextEn))
IF @ExtraTextEn = '' SET @ExtraTextEn = NULL
SET @ExtraTextFr = RTRIM(LTRIM(@ExtraTextFr))
IF @ExtraTextFr = '' SET @ExtraTextFr = NULL

SET @FieldID = NULL

SELECT @FieldID=FieldID
	FROM GBL_FieldOption
WHERE ExtraFieldType='t' AND FieldName=@ExtraTextType

IF @FieldID IS NOT NULL BEGIN
	IF @HAS_ENGLISH=1 BEGIN
		IF @ExtraTextEn IS NULL BEGIN
			DELETE FROM CIC_BT_EXTRA_TEXT WHERE NUM=@NUM AND [LangID]=0 AND FieldName=@ExtraTextType
		END ELSE BEGIN
			EXEC sp_CIC_ImportEntry_CICE_Check_i @NUM
			
			IF EXISTS(SELECT * FROM CIC_BT_EXTRA_TEXT WHERE NUM=@NUM AND [LangID]=0 AND FieldName=@ExtraTextType) BEGIN
				UPDATE CIC_BT_EXTRA_TEXT
					SET [Value] = @ExtraTextEn
				WHERE NUM=@NUM AND [LangID]=0 AND FieldName=@ExtraTextType
			END ELSE BEGIN
				INSERT INTO CIC_BT_EXTRA_TEXT (
					FieldName,
					NUM,
					[LangID],
					[Value]
				)
				SELECT	@ExtraTextType,
						NUM,
						LangID,
						@ExtraTextEn
					FROM GBL_BaseTable_Description
				WHERE NUM=@NUM AND LangID=0
			END
		END
	END
	IF @HAS_FRENCH=1 BEGIN
		IF @ExtraTextFr IS NULL BEGIN
			DELETE FROM CIC_BT_EXTRA_TEXT WHERE NUM=@NUM AND [LangID]=2 AND FieldName=@ExtraTextType
		END ELSE BEGIN
			EXEC sp_CIC_ImportEntry_CICF_Check_i @NUM
			IF EXISTS(SELECT * FROM CIC_BT_EXTRA_TEXT WHERE NUM=@NUM AND [LangID]=2 AND FieldName=@ExtraTextType) BEGIN
				UPDATE CIC_BT_EXTRA_TEXT
					SET [Value] = @ExtraTextFr
				WHERE NUM=@NUM AND [LangID]=2 AND FieldName=@ExtraTextType
			END ELSE BEGIN
				INSERT INTO CIC_BT_EXTRA_TEXT (
					FieldName,
					NUM,
					[LangID],
					[Value]
				)
				SELECT	@ExtraTextType,
						NUM,
						LangID,
						@ExtraTextFr
					FROM GBL_BaseTable_Description
				WHERE NUM=@NUM AND LangID=2
			END
		END
	END
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_ExtraText_i] TO [cioc_login_role]
GO
