SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_ExtraDate_i]
	@NUM varchar(8),
	@ExtraDateType varchar(100),
	@ExtraDate smalldatetime,
	@FieldID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 01-Dec-2013
	Action: NO ACTION REQUIRED
*/

SET @FieldID = NULL

SELECT @FieldID=FieldID FROM GBL_FieldOption WHERE ExtraFieldType IN ('a','d') AND FieldName=@ExtraDateType

IF @FieldID IS NOT NULL BEGIN
	IF @ExtraDate IS NULL BEGIN
		DELETE FROM CIC_BT_EXTRA_DATE WHERE NUM=@NUM AND FieldName=@ExtraDateType
	END ELSE BEGIN
		IF EXISTS(SELECT * FROM CIC_BT_EXTRA_DATE WHERE NUM=@NUM AND FieldName=@ExtraDateType) BEGIN
			UPDATE CIC_BT_EXTRA_DATE
				SET [Value] = @ExtraDate
			WHERE NUM=@NUM AND FieldName=@ExtraDateType
		END ELSE BEGIN
			INSERT INTO CIC_BT_EXTRA_DATE (
				FieldName,
				NUM,
				[Value]
			)
			SELECT	@ExtraDateType,
					NUM,
					@ExtraDate
				FROM GBL_BaseTable
			WHERE NUM=@NUM
		END
	END
END

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_ExtraDate_i] TO [cioc_login_role]
GO
