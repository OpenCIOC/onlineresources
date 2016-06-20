SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Funding_i]
	@NUM varchar(8),
	@FundingTypeEn nvarchar(200),
	@FundingTypeFr nvarchar(200),
	@NotesEn nvarchar(255),
	@NotesFr nvarchar(255),
	@FD_ID int OUTPUT
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
		@BT_FD_ID int

SET @HAS_ENGLISH = CASE WHEN @FundingTypeEn IS NOT NULL
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=0) THEN 1 ELSE 0 END

SET @HAS_FRENCH = CASE WHEN @FundingTypeFr IS NOT NULL
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=2) THEN 1 ELSE 0 END

SELECT TOP 1 @FD_ID = FD_ID
	FROM CIC_Funding_Name
WHERE [Name]=@FundingTypeEn OR [Name]=@FundingTypeFr
	ORDER BY CASE
		WHEN [Name]=@FundingTypeEn AND LangID=0 THEN 0
		WHEN [Name]=@FundingTypeFr AND LangID=2 THEN 1
		ELSE 2
	END

IF @FD_ID IS NOT NULL BEGIN
	EXEC sp_CIC_ImportEntry_CIC_Check_i @NUM

	INSERT INTO CIC_BT_FD (
		NUM,
		FD_ID
	)
	SELECT	NUM,
			@FD_ID
		FROM GBL_BaseTable
	WHERE NUM=@NUM
		AND NOT EXISTS(SELECT * FROM CIC_BT_FD WHERE NUM=@NUM AND FD_ID=@FD_ID)
	
	SELECT @BT_FD_ID = BT_FD_ID FROM CIC_BT_FD WHERE NUM=@NUM AND FD_ID=@FD_ID
	
	IF @BT_FD_ID IS NOT NULL BEGIN
		IF @HAS_ENGLISH=1 BEGIN
			EXEC sp_CIC_ImportEntry_CICE_Check_i @NUM
		
			SET @NotesEn = RTRIM(LTRIM(@NotesEn))
			IF @NotesEn = '' SET @NotesEn = NULL
			IF @NotesEn IS NULL BEGIN
				DELETE FROM CIC_BT_FD_Notes WHERE BT_FD_ID=@BT_FD_ID AND LangID=0
			END ELSE BEGIN
				IF EXISTS(SELECT * FROM CIC_BT_FD_Notes WHERE BT_FD_ID=@BT_FD_ID AND LangID=0) BEGIN
					UPDATE CIC_BT_FD_Notes
						SET Notes = @NotesEn
					WHERE BT_FD_ID=@BT_FD_ID AND LangID=0
				END ELSE BEGIN
					INSERT INTO CIC_BT_FD_Notes (
						BT_FD_ID,
						LangID,
						Notes
					) VALUES (
						@BT_FD_ID,
						0,
						@NotesEn
					)
				END
			END
		END

		IF @HAS_FRENCH=1 BEGIN
			EXEC sp_CIC_ImportEntry_CICF_Check_i @NUM
		
			SET @NotesFr = RTRIM(LTRIM(@NotesFr))
			IF @NotesFr = '' SET @NotesFr = NULL
			IF @NotesFr IS NULL BEGIN
				DELETE FROM CIC_BT_FD_Notes WHERE BT_FD_ID=@BT_FD_ID AND LangID=2
			END ELSE BEGIN
				IF EXISTS(SELECT * FROM CIC_BT_FD_Notes WHERE BT_FD_ID=@BT_FD_ID AND LangID=2) BEGIN
					UPDATE CIC_BT_FD_Notes
						SET Notes = @NotesFr
					WHERE BT_FD_ID=@BT_FD_ID AND LangID=2
				END ELSE BEGIN
					INSERT INTO CIC_BT_FD_Notes (
						BT_FD_ID,
						LangID,
						Notes
					) VALUES (
						@BT_FD_ID,
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
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Funding_i] TO [cioc_login_role]
GO
