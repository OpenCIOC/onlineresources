SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_AreasServed_i]
	@NUM varchar(8),
	@CommunityEn nvarchar(200),
	@CommunityFr nvarchar(200),
	@AuthCommunity nvarchar(200),
	@ProvState nvarchar(100),
	@Country nvarchar(100),
	@NotesEn nvarchar(255),
	@NotesFr nvarchar(255),
	@CM_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 05-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @HAS_ENGLISH bit,
		@HAS_FRENCH bit,
		@BT_CM_ID int

SET @HAS_ENGLISH = CASE WHEN @CommunityEn IS NOT NULL
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=0) THEN 1 ELSE 0 END

SET @HAS_FRENCH = CASE WHEN @CommunityFr IS NOT NULL
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=2) THEN 1 ELSE 0 END

SELECT TOP 1 @CM_ID = CM_ID
	FROM GBL_Community_Name cm
	LEFT JOIN GBL_ProvinceState pst
		ON cm.ProvinceStateCache=pst.ProvID
WHERE [Name] IN (@CommunityEn,@CommunityFr)
ORDER BY CASE
		WHEN [Name]=@CommunityEn AND LangID=0 THEN 0
		WHEN [Name]=@CommunityFr AND LangID=2 THEN 1
		ELSE 2
	END,
	CASE
		WHEN pst.NameOrCode=@ProvState AND pst.Country=@Country THEN 0
		WHEN @ProvState IS NULL AND @Country IS NULL AND pst.ProvID IS NULL THEN 1
		WHEN pst.Country=@Country THEN 2
		WHEN pst.NameOrCode=@ProvState THEN 3
		ELSE 4
	END

IF @CM_ID IS NULL AND @AuthCommunity IS NOT NULL BEGIN
	SELECT TOP 1 @CM_ID = CM_ID
		FROM GBL_Community_Name
	WHERE [Name]=@AuthCommunity
	ORDER BY LangID
	
	IF @CM_ID IS NOT NULL BEGIN
		IF @HAS_ENGLISH=1 BEGIN
			SET @NotesEn = @CommunityEn + CASE WHEN @NotesEn IS NULL THEN '' ELSE ', ' END + ISNULL(@NotesEn,'')
		END
		IF @HAS_FRENCH=1 BEGIN
			SET @NotesFr = @CommunityFr + CASE WHEN @NotesFr IS NULL THEN '' ELSE ', ' END + ISNULL(@NotesFr,'')
		END
	END
END

IF @CM_ID IS NOT NULL BEGIN
	INSERT INTO CIC_BT_CM (
		NUM,
		CM_ID
	)
	SELECT NUM, @CM_ID
		FROM GBL_BaseTable
	WHERE NUM=@NUM
		AND NOT EXISTS(SELECT * FROM CIC_BT_CM WHERE NUM=@NUM AND CM_ID=@CM_ID)
	
	SELECT @BT_CM_ID = BT_CM_ID FROM CIC_BT_CM WHERE NUM=@NUM AND CM_ID=@CM_ID
	
	IF @BT_CM_ID IS NOT NULL BEGIN
		IF @HAS_ENGLISH=1 BEGIN
			SET @NotesEn = RTRIM(LTRIM(@NotesEn))
			IF @NotesEn = '' SET @NotesEn = NULL
			IF @NotesEn IS NULL BEGIN
				DELETE FROM CIC_BT_CM_Notes WHERE BT_CM_ID=@BT_CM_ID AND LangID=0
			END ELSE BEGIN
				IF EXISTS(SELECT * FROM CIC_BT_CM_Notes WHERE BT_CM_ID=@BT_CM_ID AND LangID=0) BEGIN
					UPDATE CIC_BT_CM_Notes
						SET Notes = @NotesEn
					WHERE BT_CM_ID=@BT_CM_ID AND LangID=0
				END ELSE BEGIN
					INSERT INTO CIC_BT_CM_Notes (
						BT_CM_ID,
						LangID,
						Notes
					) VALUES (
						@BT_CM_ID,
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
				DELETE FROM CIC_BT_CM_Notes WHERE BT_CM_ID=@BT_CM_ID AND LangID=2
			END ELSE BEGIN
				IF EXISTS(SELECT * FROM CIC_BT_CM_Notes WHERE BT_CM_ID=@BT_CM_ID AND LangID=2) BEGIN
					UPDATE CIC_BT_CM_Notes
						SET Notes = @NotesFr
					WHERE BT_CM_ID=@BT_CM_ID AND LangID=2
				END ELSE BEGIN
					INSERT INTO CIC_BT_CM_Notes (
						BT_CM_ID,
						LangID,
						Notes
					) VALUES (
						@BT_CM_ID,
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
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_AreasServed_i] TO [cioc_login_role]
GO
