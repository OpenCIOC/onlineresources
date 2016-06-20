SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_ExtraWWW_i]
	@NUM varchar(8),
	@HAS_ENGLISH bit,
	@HAS_FRENCH bit,
	@ExtraWWWType varchar(100),
	@ExtraWWWEn nvarchar(200),
	@ExtraWWWFr nvarchar(200),
	@FieldID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action: NO ACTION REQUIRED
*/

SET @ExtraWWWEn = RTRIM(LTRIM(@ExtraWWWEn))
IF @ExtraWWWEn = '' SET @ExtraWWWEn = NULL
SET @ExtraWWWFr = RTRIM(LTRIM(@ExtraWWWFr))
IF @ExtraWWWFr = '' SET @ExtraWWWFr = NULL

SET @FieldID = NULL

SELECT @FieldID=FieldID
	FROM GBL_FieldOption
WHERE ExtraFieldType='w' AND FieldName=@ExtraWWWType

IF @FieldID IS NOT NULL BEGIN
	IF @HAS_ENGLISH=1 BEGIN
		IF @ExtraWWWEn IS NULL BEGIN
			DELETE FROM CIC_BT_EXTRA_WWW WHERE NUM=@NUM AND [LangID]=0 AND FieldName=@ExtraWWWType
		END ELSE BEGIN
			IF EXISTS(SELECT * FROM CIC_BT_EXTRA_WWW WHERE NUM=@NUM AND [LangID]=0 AND FieldName=@ExtraWWWType) BEGIN
				UPDATE CIC_BT_EXTRA_WWW
					SET [Value] = @ExtraWWWEn
				WHERE NUM=@NUM AND [LangID]=0 AND FieldName=@ExtraWWWType
			END ELSE BEGIN
				INSERT INTO CIC_BT_EXTRA_WWW (
					FieldName,
					NUM,
					[LangID],
					[Value]
				)
				SELECT	@ExtraWWWType,
						NUM,
						LangID,
						@ExtraWWWEn
					FROM GBL_BaseTable_Description
				WHERE NUM=@NUM AND LangID=0
			END
		END
	END
	IF @HAS_FRENCH=1 BEGIN
		IF @ExtraWWWFr IS NULL BEGIN
			DELETE FROM CIC_BT_EXTRA_WWW WHERE NUM=@NUM AND [LangID]=2 AND FieldName=@ExtraWWWType
		END ELSE BEGIN
			IF EXISTS(SELECT * FROM CIC_BT_EXTRA_WWW WHERE NUM=@NUM AND [LangID]=2 AND FieldName=@ExtraWWWType) BEGIN
				UPDATE CIC_BT_EXTRA_WWW
					SET [Value] = @ExtraWWWFr
				WHERE NUM=@NUM AND [LangID]=2 AND FieldName=@ExtraWWWType
			END ELSE BEGIN
				INSERT INTO CIC_BT_EXTRA_WWW (
					FieldName,
					NUM,
					[LangID],
					[Value]
				)
				SELECT	@ExtraWWWType,
						NUM,
						LangID,
						@ExtraWWWFr
					FROM GBL_BaseTable_Description
				WHERE NUM=@NUM AND LangID=2
			END
		END
	END
END

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_ExtraWWW_i] TO [cioc_login_role]
GO
