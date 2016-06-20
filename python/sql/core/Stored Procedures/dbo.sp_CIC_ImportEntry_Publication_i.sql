SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Publication_i]
	@NUM varchar(8),
	@Code varchar(20),
	@DescriptionEn nvarchar(max),
	@DescriptionFr nvarchar(max),
	@PB_ID int OUTPUT,
	@BT_PB_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT @PB_ID = PB_ID FROM CIC_ImportEntry_Pub WHERE Code=@Code

IF @PB_ID IS NOT NULL BEGIN
	SELECT @BT_PB_ID=BT_PB_ID FROM CIC_BT_PB WHERE NUM=@NUM AND PB_ID=@PB_ID
	IF @BT_PB_ID IS NULL BEGIN
		EXEC dbo.sp_CIC_ImportEntry_CIC_Check_i @NUM
		
		INSERT INTO CIC_BT_PB (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			NUM,
			PB_ID
		)
		SELECT GETDATE(),
				'(Import)',
				GETDATE(),
				'(Import)',
				NUM,
				@PB_ID
			FROM GBL_BaseTable
		WHERE NUM=@NUM
		
		SET @BT_PB_ID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE CIC_BT_PB SET
			MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= '(Import)'
		WHERE BT_PB_ID=@BT_PB_ID
	END

	IF @BT_PB_ID IS NOT NULL BEGIN
		SET @DescriptionEn = RTRIM(LTRIM(@DescriptionEn))
		IF @DescriptionEn='' SET @DescriptionEn = NULL
		IF @DescriptionEn IS NOT NULL AND EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=0) BEGIN
			IF NOT EXISTS(SELECT * FROM CIC_BT_PB_Description WHERE BT_PB_ID=@BT_PB_ID AND LangID=0) BEGIN
				INSERT INTO CIC_BT_PB_Description (
					BT_PB_ID,
					LangID,
					Description
				)
				VALUES (
					@BT_PB_ID,
					0,
					@DescriptionEn
				)
			END ELSE BEGIN
				UPDATE CIC_BT_PB_Description SET Description = @DescriptionEn WHERE BT_PB_ID=@BT_PB_ID AND LangID=0
			END
		END

		SET @DescriptionFr = RTRIM(LTRIM(@DescriptionFr))
		IF @DescriptionFr='' SET @DescriptionFr = NULL
		IF @DescriptionFr IS NOT NULL AND EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=2) BEGIN
			IF NOT EXISTS(SELECT * FROM CIC_BT_PB_Description WHERE BT_PB_ID=@BT_PB_ID AND LangID=2) BEGIN
				INSERT INTO CIC_BT_PB_Description (
					BT_PB_ID,
					LangID,
					Description
				)
				VALUES (
					@BT_PB_ID,
					2,
					@DescriptionFr
				)
			END ELSE BEGIN
				UPDATE CIC_BT_PB_Description SET Description = @DescriptionFr WHERE BT_PB_ID=@BT_PB_ID AND LangID=2
			END
		END
	END

END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Publication_i] TO [cioc_login_role]
GO
