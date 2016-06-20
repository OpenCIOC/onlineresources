SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_ExtraRadio_i]
	@NUM varchar(8),
	@ExtraRadioType varchar(100),
	@ExtraRadio bit,
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

SET @FieldID = NULL

SELECT @FieldID=FieldID
	FROM GBL_FieldOption
WHERE ExtraFieldType='r' AND FieldName=@ExtraRadioType

IF @FieldID IS NOT NULL BEGIN
	IF @ExtraRadio IS NULL BEGIN
		DELETE FROM CIC_BT_EXTRA_RADIO WHERE NUM=@NUM AND FieldName=@ExtraRadioType
	END ELSE BEGIN
		IF EXISTS(SELECT * FROM CIC_BT_EXTRA_RADIO WHERE NUM=@NUM AND FieldName=@ExtraRadioType) BEGIN
			UPDATE CIC_BT_EXTRA_RADIO
				SET [Value] = @ExtraRadio
			WHERE NUM=@NUM AND FieldName=@ExtraRadioType
		END ELSE BEGIN
			INSERT INTO CIC_BT_EXTRA_RADIO (
				FieldName,
				NUM,
				[Value]
			)
			SELECT	@ExtraRadioType,
					NUM,
					@ExtraRadio
				FROM GBL_BaseTable
			WHERE NUM=@NUM
		END
	END
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_ExtraRadio_i] TO [cioc_login_role]
GO
