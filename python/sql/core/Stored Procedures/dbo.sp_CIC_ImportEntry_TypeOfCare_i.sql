SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_TypeOfCare_i]
	@NUM varchar(8),
	@TypeOfCareEn nvarchar(200),
	@TypeOfCareFr nvarchar(200),
	@NotesEn nvarchar(255),
	@NotesFr nvarchar(255),
	@TOC_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @HAS_ENGLISH bit,
		@HAS_FRENCH bit,
		@BT_TOC_ID int

SET @HAS_ENGLISH = CASE WHEN @TypeOfCareEn IS NOT NULL
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=0) THEN 1 ELSE 0 END

SET @HAS_FRENCH = CASE WHEN @TypeOfCareEn IS NOT NULL
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=2) THEN 1 ELSE 0 END

SELECT TOP 1 @TOC_ID = TOC_ID
	FROM CCR_TypeOfCare_Name
WHERE [Name]=@TypeOfCareEn OR [Name]=@TypeOfCareFr
	ORDER BY CASE
		WHEN [Name]=@TypeOfCareEn AND LangID=0 THEN 0
		WHEN [Name]=@TypeOfCareFr AND LangID=2 THEN 1
		ELSE 2
	END

IF @TOC_ID IS NOT NULL BEGIN
	INSERT INTO CCR_BT_TOC (
		NUM,
		TOC_ID
	)
	SELECT	NUM,
			@TOC_ID
		FROM GBL_BaseTable
	WHERE NUM=@NUM
		AND NOT EXISTS(SELECT * FROM CCR_BT_TOC WHERE NUM=@NUM AND TOC_ID=@TOC_ID)
	
	SELECT @BT_TOC_ID = BT_TOC_ID FROM CCR_BT_TOC WHERE NUM=@NUM AND TOC_ID=@TOC_ID
	
	IF @BT_TOC_ID IS NOT NULL BEGIN
		IF @HAS_ENGLISH=1 BEGIN
			EXEC sp_CIC_ImportEntry_CCRE_Check_i @NUM
		
			SET @NotesEn = RTRIM(LTRIM(@NotesEn))
			IF @NotesEn = '' SET @NotesEn = NULL
			IF @NotesEn IS NULL BEGIN
				DELETE FROM CCR_BT_TOC_Notes WHERE BT_TOC_ID=@BT_TOC_ID AND LangID=0
			END ELSE BEGIN
				IF EXISTS(SELECT * FROM CCR_BT_TOC_Notes WHERE BT_TOC_ID=@BT_TOC_ID AND LangID=0) BEGIN
					UPDATE CCR_BT_TOC_Notes
						SET Notes = @NotesEn
					WHERE BT_TOC_ID=@BT_TOC_ID AND LangID=0
				END ELSE BEGIN
					INSERT INTO CCR_BT_TOC_Notes (
						BT_TOC_ID,
						LangID,
						Notes
					) VALUES (
						@BT_TOC_ID,
						0,
						@NotesEn
					)
				END
			END
		END

		IF @HAS_FRENCH=1 BEGIN
			EXEC sp_CIC_ImportEntry_CCRF_Check_i @NUM
			
			SET @NotesFr = RTRIM(LTRIM(@NotesFr))
			IF @NotesFr = '' SET @NotesFr = NULL
			IF @NotesFr IS NULL BEGIN
				DELETE FROM CCR_BT_TOC_Notes WHERE BT_TOC_ID=@BT_TOC_ID AND LangID=2
			END ELSE BEGIN
				IF EXISTS(SELECT * FROM CCR_BT_TOC_Notes WHERE BT_TOC_ID=@BT_TOC_ID AND LangID=2) BEGIN
					UPDATE CCR_BT_TOC_Notes
						SET Notes = @NotesFr
					WHERE BT_TOC_ID=@BT_TOC_ID AND LangID=2
				END ELSE BEGIN
					INSERT INTO CCR_BT_TOC_Notes (
						BT_TOC_ID,
						LangID,
						Notes
					) VALUES (
						@BT_TOC_ID,
						2,
						@NotesFr
					)
				END
			END
		END
	END
END

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_TypeOfCare_i] TO [cioc_login_role]
GO
