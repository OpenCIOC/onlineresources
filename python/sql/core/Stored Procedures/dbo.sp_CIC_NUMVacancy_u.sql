
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMVacancy_u]
	@BT_VUT_ID int,
	@Capacity int,
	@FundedCapacity int,
	@LastVacancyChange int,
	@Vacancy int,
	@HoursPerDay [decimal](6, 1),
	@DaysPerWeek [decimal](6, 1),
	@WeeksPerYear [decimal](6, 1),
	@FullTimeEquivalent [decimal](6, 1),
	@WaitList bit,
	@WaitListDate smalldatetime,
	@ServiceTitle nvarchar(100),
	@Notes nvarchar(2000),
	@MODIFIED_DATE smalldatetime,
	@MODIFIED_BY varchar(50),
	@VTPIDList varchar(MAX),
	@VacancyWarning nvarchar(MAX) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Change table (old int)
IF @Capacity IS NOT NULL AND @Capacity > 0 BEGIN
	IF EXISTS(SELECT * FROM CIC_BT_VUT WHERE BT_VUT_ID=@BT_VUT_ID) BEGIN
		UPDATE CIC_BT_VUT SET 
			Capacity			= @Capacity,
			FundedCapacity		= @FundedCapacity,
			Vacancy				= @Vacancy,
			HoursPerDay			= @HoursPerDay,
			DaysPerWeek			= @DaysPerWeek,
			WeeksPerYear		= @WeeksPerYear,
			FullTimeEquivalent	= @FullTimeEquivalent,
			WaitList			= @WaitList,
			WaitListDate		= @WaitListDate,
			MODIFIED_DATE		= @MODIFIED_DATE
		OUTPUT Deleted.Vacancy INTO @Change
		WHERE BT_VUT_ID = @BT_VUT_ID

		IF NOT EXISTS(SELECT * FROM CIC_BT_VUT_Notes WHERE BT_VUT_ID=@BT_VUT_ID AND LangID=@@LANGID) BEGIN
			INSERT INTO CIC_BT_VUT_Notes (
				BT_VUT_ID,
				LangID,
				ServiceTitle,
				Notes
			)
			VALUES (
				@BT_VUT_ID,
				@@LANGID,
				@ServiceTitle,
				@Notes
			)
		END ELSE BEGIN
			UPDATE CIC_BT_VUT_Notes SET 
				ServiceTitle		= @ServiceTitle,
				Notes				= @Notes
			WHERE BT_VUT_ID=@BT_VUT_ID
				AND LangID=@@LANGID
		END

		DECLARE @tmpVTPIDs table(VTP_ID int)
		INSERT INTO @tmpVTPIDs SELECT DISTINCT tm.*
			FROM dbo.fn_GBL_ParseIntIDList(@VTPIDList,',') tm
			INNER JOIN CIC_Vacancy_TargetPop tp ON tm.ItemID = tp.VTP_ID
		DELETE pr
			FROM CIC_BT_VUT_TP pr
			LEFT JOIN @tmpVTPIDs tm
				ON pr.VTP_ID = tm.VTP_ID
		WHERE tm.VTP_ID IS NULL AND BT_VUT_ID=@BT_VUT_ID
		INSERT INTO CIC_BT_VUT_TP (BT_VUT_ID, VTP_ID) SELECT BT_VUT_ID=@BT_VUT_ID, tm.VTP_ID
			FROM @tmpVTPIDs tm
		WHERE NOT EXISTS(SELECT * FROM CIC_BT_VUT_TP pr WHERE BT_VUT_ID=@BT_VUT_ID AND pr.VTP_ID=tm.VTP_ID)

		DECLARE @GUID uniqueidentifier, @MemberID int, @NUM varchar(8), @LastChangeDate datetime2(0), @Value int
		SELECT @GUID = GUID, @MemberID=MemberID, @NUM=bt.NUM
		FROM CIC_BT_VUT pr
		INNER JOIN GBL_BaseTable bt
			ON bt.NUM = pr.NUM

		IF @LastVacancyChange IS NOT NULL BEGIN
			SELECT @LastChangeDate = MODIFIED_DATE FROM CIC_BT_VUT_History WHERE BT_VUT_HIST_ID=@LastVacancyChange
		END
		SELECT @VacancyWarning=(
			SELECT *
			FROM CIC_BT_VUT_History WHERE BT_VUT_ID=@BT_VUT_ID AND MODIFIED_DATE > ISNULL(@LastChangeDate, '1990-01-01') AND BT_VUT_HIST_ID > ISNULL(@LastVacancyChange, 0)
			ORDER BY MODIFIED_DATE DESC, BT_VUT_HIST_ID DESC
			FOR XML PATH('Change'), ROOT('CHANGES')
		) 

		SELECT @Value = @Vacancy - old FROM @Change

		IF @Value <> 0 BEGIN
			INSERT INTO CIC_BT_VUT_History
					(BT_VUT_ID, NUM, BT_VUT_GUID, VacancyChange, VacancyFinal, MODIFIED_DATE,
					 MODIFIED_BY, ServiceTitle, MemberID)
			VALUES	(@BT_VUT_ID, @NUM, @GUID, @Value, @Vacancy, GETDATE(),
					 @MODIFIED_BY, @ServiceTitle, @MemberID)
		END

	END
END ELSE BEGIN
	EXEC sp_CIC_NUMVacancy_d @BT_VUT_ID
END

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_NUMVacancy_u] TO [cioc_login_role]
GO
