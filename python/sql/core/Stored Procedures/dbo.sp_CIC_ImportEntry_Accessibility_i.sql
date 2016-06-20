SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Accessibility_i]
	@NUM varchar(8),
	@AccessibilityTypeEn nvarchar(200),
	@AccessibilityTypeFr nvarchar(200),
	@NotesEn nvarchar(255),
	@NotesFr nvarchar(255),
	@AC_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @HAS_ENGLISH bit,
		@HAS_FRENCH bit,
		@BT_AC_ID int

SET @HAS_ENGLISH = CASE WHEN @AccessibilityTypeEn IS NOT NULL
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=0) THEN 1 ELSE 0 END

SET @HAS_FRENCH = CASE WHEN @AccessibilityTypeFr IS NOT NULL
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=2) THEN 1 ELSE 0 END

SELECT TOP 1 @AC_ID = AC_ID
	FROM GBL_Accessibility_Name
WHERE [Name]=@AccessibilityTypeEn OR [Name]=@AccessibilityTypeFr
	ORDER BY CASE
		WHEN [Name]=@AccessibilityTypeEn AND LangID=0 THEN 0
		WHEN [Name]=@AccessibilityTypeFr AND LangID=2 THEN 1
		ELSE 2
	END

IF @AC_ID IS NOT NULL BEGIN
	INSERT INTO GBL_BT_AC (
		NUM,
		AC_ID
	)
	SELECT NUM, @AC_ID
		FROM GBL_BaseTable
	WHERE NUM=@NUM
		AND NOT EXISTS(SELECT * FROM GBL_BT_AC WHERE NUM=@NUM AND AC_ID=@AC_ID)
	
	SELECT @BT_AC_ID = BT_AC_ID
		FROM GBL_BT_AC
	WHERE NUM=@NUM AND AC_ID=@AC_ID
	
	IF @BT_AC_ID IS NOT NULL BEGIN
		IF @HAS_ENGLISH=1 BEGIN
			SET @NotesEn = RTRIM(LTRIM(@NotesEn))
			IF @NotesEn = '' SET @NotesEn = NULL
			IF @NotesEn IS NULL BEGIN
				DELETE FROM GBL_BT_AC_Notes WHERE BT_AC_ID=@BT_AC_ID AND LangID=0
			END ELSE BEGIN
				IF EXISTS(SELECT * FROM GBL_BT_AC_Notes WHERE BT_AC_ID=@BT_AC_ID AND LangID=0) BEGIN
					UPDATE GBL_BT_AC_Notes
						SET Notes = @NotesEn
					WHERE BT_AC_ID=@BT_AC_ID AND LangID=0
				END ELSE BEGIN
					INSERT INTO GBL_BT_AC_Notes (
						BT_AC_ID,
						LangID,
						Notes
					) VALUES (
						@BT_AC_ID,
						0,
						@NotesEn
					)
				END
			END
		END

		IF @HAS_FRENCH=1 BEGIN
			SET @NotesFr = RTRIM(LTRIM(@NotesFr))
			IF @NotesFr = '' SET @NotesFr = NULL
			IF @NotesFr IS NULL BEGIN
				DELETE FROM GBL_BT_AC_Notes WHERE BT_AC_ID=@BT_AC_ID AND LangID=0
			END ELSE BEGIN
				IF EXISTS(SELECT * FROM GBL_BT_AC_Notes WHERE BT_AC_ID=@BT_AC_ID AND LangID=2) BEGIN
					UPDATE GBL_BT_AC_Notes
						SET Notes = @NotesFr
					WHERE BT_AC_ID=@BT_AC_ID AND LangID=2
				END ELSE BEGIN
					INSERT INTO GBL_BT_AC_Notes (
						BT_AC_ID,
						LangID,
						Notes
					)
					VALUES (
						@BT_AC_ID,
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
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Accessibility_i] TO [cioc_login_role]
GO
