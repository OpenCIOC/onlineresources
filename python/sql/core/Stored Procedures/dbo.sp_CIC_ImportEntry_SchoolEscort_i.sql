SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_SchoolEscort_i]
	@NUM varchar(8),
	@SchoolEn nvarchar(200),
	@SchoolFr nvarchar(200),
	@SchoolBoard nvarchar(100),
	@NotesEn nvarchar(255),
	@NotesFr nvarchar(255),
	@SCH_ID int OUTPUT
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
		@BT_SCH_ID int

SET @HAS_ENGLISH = CASE WHEN @SchoolEn IS NOT NULL
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=0) THEN 1 ELSE 0 END

SET @HAS_FRENCH = CASE WHEN @SchoolFr IS NOT NULL
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=2) THEN 1 ELSE 0 END

SELECT TOP 1 @SCH_ID = sch.SCH_ID
	FROM CCR_School sch
	INNER JOIN CCR_School_Name schn
		ON sch.SCH_ID=schn.SCH_ID
WHERE [Name]=@SchoolEn OR [Name]=@SchoolFr
	AND (@SchoolBoard=SchoolBoard OR (@SchoolBoard IS NULL AND SchoolBoard IS NULL))
	ORDER BY CASE
		WHEN [Name]=@SchoolEn AND LangID=0 THEN 0
		WHEN [Name]=@SchoolFr AND LangID=2 THEN 1
		ELSE 2
	END

IF @SCH_ID IS NOT NULL BEGIN
	EXEC sp_CIC_ImportEntry_CCR_Check_i @NUM

	INSERT INTO CCR_BT_SCH (
		NUM,
		SCH_ID,
		Escort
	)
	SELECT	NUM,
			@SCH_ID,
			1
		FROM GBL_BaseTable
	WHERE NUM=@NUM
		AND NOT EXISTS(SELECT * FROM CCR_BT_SCH WHERE NUM=@NUM AND SCH_ID=@SCH_ID)

	SELECT @BT_SCH_ID = BT_SCH_ID FROM CCR_BT_SCH WHERE NUM=@NUM AND SCH_ID=@SCH_ID

	UPDATE CCR_BT_SCH
		SET InArea = 1
	WHERE BT_SCH_ID=@BT_SCH_ID AND InArea=0

	IF @BT_SCH_ID IS NOT NULL BEGIN
		IF @HAS_ENGLISH=1 BEGIN
			EXEC sp_CIC_ImportEntry_CCRE_Check_i @NUM
			
			SET @NotesEn = RTRIM(LTRIM(@NotesEn))
			IF @NotesEn = '' SET @NotesEn = NULL
			IF @NotesEn IS NULL BEGIN
				DELETE FROM CCR_BT_SCH_Notes WHERE BT_SCH_ID=@BT_SCH_ID AND InAreaNotes IS NULL AND LangID=0
			END ELSE BEGIN
				IF EXISTS(SELECT * FROM CCR_BT_SCH_Notes WHERE BT_SCH_ID=@BT_SCH_ID AND LangID=0) BEGIN
					UPDATE CCR_BT_SCH_Notes
						SET EscortNotes = @NotesEn
					WHERE BT_SCH_ID=@BT_SCH_ID AND LangID=0
				END ELSE BEGIN
					INSERT INTO CCR_BT_SCH_Notes (
						BT_SCH_ID,
						LangID,
						EscortNotes
					) VALUES (
						@BT_SCH_ID,
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
				DELETE FROM CCR_BT_SCH_Notes WHERE BT_SCH_ID=@BT_SCH_ID AND InAreaNotes IS NULL AND LangID=2
			END ELSE BEGIN
				IF EXISTS(SELECT * FROM CCR_BT_SCH_Notes WHERE BT_SCH_ID=@BT_SCH_ID AND LangID=2) BEGIN
					UPDATE CCR_BT_SCH_Notes
						SET EscortNotes = @NotesFr
					WHERE BT_SCH_ID=@BT_SCH_ID AND LangID=2
				END ELSE BEGIN
					INSERT INTO CCR_BT_SCH_Notes (
						BT_SCH_ID,
						LangID,
						EscortNotes
					) VALUES (
						@BT_SCH_ID,
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
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_SchoolEscort_i] TO [cioc_login_role]
GO
