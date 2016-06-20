SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_VacancyInfo_i]
	@NUM varchar(8),
	@HAS_ENGLISH bit,
	@HAS_FRENCH bit,
	@GUID [uniqueidentifier],
	@ServiceTitleEn nvarchar(100),
	@ServiceTitleFr nvarchar(100),
	@UnitTypeNameEn nvarchar(100),
	@UnitTypeNameFr nvarchar(100),
	@Capacity int,
	@FundedCapacity int,
	@Vacancy int,
	@HoursPerDay [decimal](6, 1),
	@DaysPerWeek [decimal](6, 1),
	@WeeksPerYear [decimal](6, 1),
	@FullTimeEquivalent [decimal](6, 1),
	@WaitList bit,
	@WaitListDate smalldatetime,
	@NotesEn nvarchar(2000),
	@NotesFr nvarchar(2000),
	@MODIFIED_DATE smalldatetime,
	@TargetPopulations [xml],
	@BT_VUT_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @TargetPopListEn nvarchar(max),
		@TargetPopListFr nvarchar(max), 
		@VUT_ID int

DECLARE @TargetPop TABLE(
	VTP_ID int,
	TargetPopEn nvarchar(100),
	TargetPopFr nvarchar(100)
)

SET @HAS_ENGLISH = CASE WHEN @HAS_ENGLISH=1
		AND EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=@NUM AND LangID=0) THEN 1 ELSE 0 END
SET @HAS_FRENCH = CASE WHEN @HAS_FRENCH=1
		AND EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=@NUM AND LangID=2) THEN 1 ELSE 0 END

SELECT TOP 1 @VUT_ID = VUT_ID
	FROM CIC_Vacancy_UnitType_Name vutn
WHERE [Name]=@UnitTypeNameEn OR [Name]=@UnitTypeNameFr
	ORDER BY CASE
		WHEN [Name]=@UnitTypeNameEn AND LangID=0 THEN 0
		WHEN [Name]=@UnitTypeNameFr AND LangID=2 THEN 1
		ELSE 2
	END

INSERT INTO @TargetPop
SELECT DISTINCT vtpn.VTP_ID, ISNULL(x.TargetPopulationEn,x.TargetPopulationFr), ISNULL(x.TargetPopulationFr,x.TargetPopulationEn)
	FROM (SELECT
			N.value('@NM', 'nvarchar(100)') as TargetPopulationEn,
			N.value('@NMF', 'nvarchar(100)') as TargetPopulationFr
		FROM @TargetPopulations.nodes('/UNIT/TP') as T(N)) x
	LEFT JOIN CIC_Vacancy_TargetPop_Name vtpn
		ON ((vtpn.Name=x.TargetPopulationEn AND vtpn.LangID=0)
			OR (vtpn.Name=x.TargetPopulationFr AND vtpn.LangID IN (0,2)))

IF @VUT_ID IS NOT NULL BEGIN
	IF @HAS_ENGLISH=1 BEGIN
		SET @ServiceTitleEn = RTRIM(LTRIM(@ServiceTitleEn))
		IF @ServiceTitleEn = '' SET @ServiceTitleEn = NULL
		
		SET @NotesEn = RTRIM(LTRIM(@NotesEn))
		IF @NotesEn = '' SET @NotesEn = NULL
		SELECT @TargetPopListEn = COALESCE(@TargetPopListEn + ', ', '') + TargetPopEn FROM @TargetPop WHERE VTP_ID IS NULL
		IF @TargetPopListEn IS NOT NULL BEGIN
			SET @NotesEn = 'Also serves: ' + @TargetPopListEn + CASE WHEN @NotesEn IS NULL THEN '' ELSE ' ; ' END + ISNULL(@NotesEn, '')
		END
		IF @NotesEn = '' SET @NotesEn = NULL
	END

	IF @HAS_FRENCH=1 BEGIN
		SET @ServiceTitleFr = RTRIM(LTRIM(@ServiceTitleFr))
		IF @ServiceTitleFr = '' SET @ServiceTitleFr = NULL
		SET @NotesFr = RTRIM(LTRIM(@NotesFr))
		IF @NotesFr = '' SET @NotesFr = NULL
		SELECT @TargetPopListFr = COALESCE(@TargetPopListFr + ', ', '') + TargetPopFr FROM @TargetPop WHERE VTP_ID IS NULL
		IF @TargetPopListFr IS NOT NULL BEGIN
			SET @NotesFr = 'Aussi : ' + @TargetPopListFr + CASE WHEN @NotesFr IS NULL THEN '' ELSE ' ; ' END + ISNULL(@NotesFr, '')
		END
		IF @NotesFr = '' SET @NotesFr = NULL
	END
		
	SELECT @BT_VUT_ID = BT_VUT_ID FROM CIC_BT_VUT WHERE GUID=@GUID

	IF @BT_VUT_ID IS NULL BEGIN
		EXEC dbo.sp_CIC_ImportEntry_CIC_Check_i @NUM

		INSERT INTO CIC_BT_VUT (
			NUM,
			VUT_ID,
			GUID,
			Capacity,
			FundedCapacity,
			Vacancy,
			HoursPerDay,
			DaysPerWeek,
			WeeksPerYear,
			FullTimeEquivalent,
			WaitList,
			WaitListDate,
			MODIFIED_DATE
		) VALUES (
			@NUM,
			@VUT_ID,
			@GUID,
			@Capacity,
			@FundedCapacity,
			@Vacancy,
			@HoursPerDay,
			@DaysPerWeek,
			@WeeksPerYear,
			@FullTimeEquivalent,
			@WaitList,
			@WaitListDate,
			@MODIFIED_DATE
		)
		SET @BT_VUT_ID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE CIC_BT_VUT SET
			VUT_ID			= @VUT_ID,
			Capacity		= @Capacity,
			FundedCapacity	= @FundedCapacity,
			Vacancy			= @Vacancy,
			HoursPerDay		= @HoursPerDay,
			DaysPerWeek		= @DaysPerWeek,
			WeeksPerYear	= @WeeksPerYear,
			FullTimeEquivalent	= @FullTimeEquivalent,
			WaitList		= @WaitList,
			WaitListDate	= @WaitListDate,
			MODIFIED_DATE	= @MODIFIED_DATE
		WHERE BT_VUT_ID=@BT_VUT_ID
			AND (
				Capacity<>@Capacity
				OR (FundedCapacity<>@FundedCapacity OR (FundedCapacity IS NULL AND @FundedCapacity IS NOT NULL) OR (FundedCapacity IS NOT NULL AND @FundedCapacity IS NULL))
				OR (Vacancy<>@Vacancy OR (Vacancy IS NULL AND @Vacancy IS NOT NULL) OR (Vacancy IS NOT NULL AND @Vacancy IS NULL))
				OR (HoursPerDay<>@HoursPerDay OR (HoursPerDay IS NULL AND @HoursPerDay IS NOT NULL) OR (HoursPerDay IS NOT NULL AND @HoursPerDay IS NULL))
				OR (DaysPerWeek<>@DaysPerWeek OR (DaysPerWeek IS NULL AND @DaysPerWeek IS NOT NULL) OR (DaysPerWeek IS NOT NULL AND @DaysPerWeek IS NULL))
				OR (WeeksPerYear<>@WeeksPerYear OR (WeeksPerYear IS NULL AND @WeeksPerYear IS NOT NULL) OR (WeeksPerYear IS NOT NULL AND @WeeksPerYear IS NULL))
				OR (FullTimeEquivalent<>@FullTimeEquivalent OR (FullTimeEquivalent IS NULL AND @FullTimeEquivalent IS NOT NULL) OR (FullTimeEquivalent IS NOT NULL AND @FullTimeEquivalent IS NULL))
				OR (WaitList<>@WaitList OR (WaitList IS NULL AND @WaitList IS NOT NULL) OR (WaitList IS NOT NULL AND @WaitList IS NULL))
				OR (WaitListDate<>@WaitListDate OR (WaitListDate IS NULL AND @WaitListDate IS NOT NULL) OR (WaitListDate IS NOT NULL AND @WaitListDate IS NULL))
				OR (MODIFIED_DATE<>@MODIFIED_DATE OR (MODIFIED_DATE IS NULL AND @MODIFIED_DATE IS NOT NULL) OR (MODIFIED_DATE IS NOT NULL AND @MODIFIED_DATE IS NULL))
			)
	END

	IF @BT_VUT_ID IS NOT NULL BEGIN

		IF @HAS_ENGLISH=1 AND (@NotesEn IS NOT NULL OR @ServiceTitleEn IS NOT NULL) BEGIN
			IF NOT EXISTS(SELECT * FROM CIC_BT_VUT_Notes WHERE BT_VUT_ID=@BT_VUT_ID AND LangID=0) BEGIN
				INSERT INTO CIC_BT_VUT_Notes (
					BT_VUT_ID,
					LangID,
					ServiceTitle,
					Notes
				) VALUES (
					@BT_VUT_ID,
					0,
					@ServiceTitleEn,
					@NotesEn
				)
			END ELSE BEGIN
				UPDATE CIC_BT_VUT_Notes SET
					ServiceTitle = @ServiceTitleEn,
					Notes = @NotesEn
				WHERE BT_VUT_ID=@BT_VUT_ID AND LangID=0
					AND (
						(ServiceTitle<>@ServiceTitleEn OR (ServiceTitle IS NULL AND @ServiceTitleEn IS NOT NULL) OR (ServiceTitle IS NOT NULL AND @ServiceTitleEn IS NULL))
						OR (Notes=@NotesEn OR (Notes IS NULL AND @NotesEn IS NOT NULL) OR (Notes IS NOT NULL AND @NotesEn IS NULL))
						)
			END
		END ELSE BEGIN
			DELETE FROM CIC_BT_VUT_Notes WHERE BT_VUT_ID=@BT_VUT_ID AND LangID=0
		END

		IF @HAS_FRENCH=1 AND (@NotesFr IS NOT NULL OR @ServiceTitleFr IS NOT NULL) BEGIN
			IF NOT EXISTS(SELECT * FROM CIC_BT_VUT_Notes WHERE BT_VUT_ID=@BT_VUT_ID AND LangID=2) BEGIN
				INSERT INTO CIC_BT_VUT_Notes (
					BT_VUT_ID,
					LangID,
					ServiceTitle,
					Notes
				) VALUES (
					@BT_VUT_ID,
					2,
					@ServiceTitleFr,
					@NotesFr
				)
			END ELSE BEGIN
				UPDATE CIC_BT_VUT_Notes SET
					ServiceTitle = @ServiceTitleFr,
					Notes = @NotesFr
				WHERE BT_VUT_ID=@BT_VUT_ID AND LangID=2
					AND (
						(ServiceTitle<>@ServiceTitleFr OR (ServiceTitle IS NULL AND @ServiceTitleFr IS NOT NULL) OR (ServiceTitle IS NOT NULL AND @ServiceTitleFr IS NULL))
						OR (Notes=@NotesFr OR (Notes IS NULL AND @NotesFr IS NOT NULL) OR (Notes IS NOT NULL AND @NotesFr IS NULL))
						)
			END
		END ELSE BEGIN
			DELETE FROM CIC_BT_VUT_Notes WHERE BT_VUT_ID=@BT_VUT_ID AND LangID=2
		END

		INSERT INTO CIC_BT_VUT_TP 
			SELECT @BT_VUT_ID AS BT_VUT_ID, VTP_ID 
			FROM @TargetPop tp
			WHERE VTP_ID IS NOT NULL 
				AND NOT EXISTS(SELECT * FROM CIC_BT_VUT_TP WHERE BT_VUT_ID=@BT_VUT_ID AND VTP_ID=tp.VTP_ID)
	
		DELETE vtp FROM CIC_BT_VUT_TP vtp WHERE BT_VUT_ID=@BT_VUT_ID AND NOT EXISTS(SELECT * FROM @TargetPop WHERE VTP_ID=vtp.VTP_ID)
	END

END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_VacancyInfo_i] TO [cioc_login_role]
GO
