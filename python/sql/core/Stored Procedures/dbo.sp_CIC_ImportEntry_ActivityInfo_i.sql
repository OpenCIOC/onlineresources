SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_ActivityInfo_i]
	@NUM varchar(8),
	@HAS_ENGLISH bit,
	@HAS_FRENCH bit,
	@GUID [uniqueidentifier],
	@ActivityNameEn nvarchar(100),
	@ActivityNameFr nvarchar(100),
	@ActivityDescriptionEn nvarchar(2000),
	@ActivityDescriptionFr nvarchar(2000),
	@ActivityStatusEn nvarchar(100),
	@ActivityStatusFr nvarchar(100),
	@NotesEn nvarchar(2000),
	@NotesFr nvarchar(2000),
	@BT_ACT_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
	Notes: Should accept Activity data as xml
*/

Declare @ASTAT_ID int

SET @HAS_ENGLISH = CASE WHEN @HAS_ENGLISH=1
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=@NUM AND LangID=0) THEN 1 ELSE 0 END
SET @HAS_FRENCH = CASE WHEN @HAS_FRENCH=1
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=@NUM AND LangID=2) THEN 1 ELSE 0 END

IF @HAS_ENGLISH=1 BEGIN
	SET @ActivityNameEn = RTRIM(LTRIM(@ActivityNameEn))
	IF @ActivityNameEn = '' SET @ActivityNameEn = NULL
	SET @NotesEn = RTRIM(LTRIM(@NotesEn))
	IF @NotesEn = '' SET @NotesEn = NULL
	SET @ActivityStatusEn = RTRIM(LTRIM(@ActivityStatusEn))
	IF @ActivityStatusEn = '' SET @ActivityStatusEn = NULL
	SELECT @ASTAT_ID=ASTAT_ID FROM CIC_Activity_Status_Name WHERE LangID=0 AND Name=@ActivityStatusEn
END

IF @HAS_FRENCH=1 BEGIN
	SET @ActivityNameFr = RTRIM(LTRIM(@ActivityNameFr))
	IF @ActivityNameFr = '' SET @ActivityNameFr = NULL
	SET @NotesFr = RTRIM(LTRIM(@NotesFr))
	IF @NotesFr = '' SET @NotesFr = NULL
	SET @ActivityStatusEn = RTRIM(LTRIM(@ActivityStatusEn))
	IF @ActivityStatusEn = '' SET @ActivityStatusEn = NULL
	IF @ASTAT_ID IS NULL BEGIN
		SELECT @ASTAT_ID=ASTAT_ID FROM CIC_Activity_Status_Name WHERE LangID=2 AND Name=@ActivityStatusFr
	END
END
	
SELECT @BT_ACT_ID = BT_ACT_ID
	FROM CIC_BT_ACT
WHERE GUID=@GUID

IF @BT_ACT_ID IS NULL BEGIN
	EXEC dbo.sp_CIC_ImportEntry_CIC_Check_i @NUM

	INSERT INTO CIC_BT_ACT (
		NUM,
		GUID,
		ASTAT_ID
	)
	SELECT NUM,
			@GUID,
			@ASTAT_ID
		FROM GBL_BaseTable
	WHERE NUM=@NUM
	
	SET @BT_ACT_ID = SCOPE_IDENTITY()
END ELSE BEGIN
	UPDATE CIC_BT_ACT SET
		ASTAT_ID=@ASTAT_ID
	WHERE BT_ACT_ID=@BT_ACT_ID
		AND (
			ASTAT_ID<>@ASTAT_ID
			OR (ASTAT_ID IS NULL AND @ASTAT_ID IS NOT NULL)
			OR (ASTAT_ID IS NOT NULL AND @ASTAT_ID IS NULL)	
		)
END

IF @BT_ACT_ID IS NOT NULL BEGIN
	IF @HAS_ENGLISH=1 AND (@NotesEn IS NOT NULL OR @ActivityNameEn IS NOT NULL OR @ActivityDescriptionEn IS NOT NULL) BEGIN
		IF NOT EXISTS(SELECT * FROM CIC_BT_ACT_Notes WHERE BT_ACT_ID=@BT_ACT_ID AND LangID=0) BEGIN
			INSERT INTO CIC_BT_ACT_Notes (
				BT_ACT_ID,
				LangID,
				ActivityName,
				ActivityDescription,
				Notes
			) VALUES (
				@BT_ACT_ID,
				0,
				@ActivityNameEn,
				@ActivityDescriptionEn,
				@NotesEn
			)
		END ELSE BEGIN
			UPDATE CIC_BT_ACT_Notes
				SET ActivityName = @ActivityNameEn,
					ActivityDescription = @ActivityDescriptionEn,
					Notes = @NotesEn
			WHERE BT_ACT_ID=@BT_ACT_ID
				AND LangID=0
				AND (
					(ActivityName<>@ActivityNameEn OR (ActivityName IS NULL AND @ActivityNameEn IS NOT NULL) OR (ActivityName IS NOT NULL AND @ActivityNameEn IS NULL))
					OR (ActivityDescription<>@ActivityDescriptionEn OR (ActivityDescription IS NULL AND @ActivityDescriptionEn IS NOT NULL) OR (ActivityDescription IS NOT NULL AND @ActivityDescriptionEn IS NULL))
					OR (Notes=@NotesEn OR (Notes IS NULL AND @NotesEn IS NOT NULL) OR (Notes IS NOT NULL AND @NotesEn IS NULL))
				)
		END
	END ELSE BEGIN
		DELETE FROM CIC_BT_ACT_Notes WHERE BT_ACT_ID=@BT_ACT_ID AND LangID=0
	END

	IF @HAS_FRENCH=1 AND (@NotesFr IS NOT NULL OR @ActivityNameFr IS NOT NULL OR @ActivityDescriptionFr IS NOT NULL) BEGIN
		IF NOT EXISTS(SELECT * FROM CIC_BT_ACT_Notes WHERE BT_ACT_ID=@BT_ACT_ID AND LangID=2) BEGIN
			INSERT INTO CIC_BT_ACT_Notes (
				BT_ACT_ID,
				LangID,
				ActivityName,
				ActivityDescription,
				Notes
			) VALUES (
				@BT_ACT_ID,
				2,
				@ActivityNameFr,
				@ActivityDescriptionFr,
				@NotesFr
			)
		END ELSE BEGIN
			UPDATE CIC_BT_ACT_Notes
				SET	ActivityName = @ActivityNameFr,
					ActivityDescription = @ActivityDescriptionFr,
					Notes = @NotesFr
			WHERE BT_ACT_ID=@BT_ACT_ID
				AND LangID=2
				AND (
					(ActivityName<>@ActivityNameFr OR (ActivityName IS NULL AND @ActivityNameFr IS NOT NULL) OR (ActivityName IS NOT NULL AND @ActivityNameFr IS NULL))
					OR (ActivityDescription<>@ActivityDescriptionFr OR (ActivityDescription IS NULL AND @ActivityDescriptionFr IS NOT NULL) OR (ActivityDescription IS NOT NULL AND @ActivityDescriptionFr IS NULL))
					OR (Notes=@NotesFr OR (Notes IS NULL AND @NotesFr IS NOT NULL) OR (Notes IS NOT NULL AND @NotesFr IS NULL))
				)
		END
	END ELSE BEGIN
		DELETE FROM CIC_BT_ACT_Notes WHERE BT_ACT_ID=@BT_ACT_ID AND LangID=2
	END
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_ActivityInfo_i] TO [cioc_login_role]
GO
