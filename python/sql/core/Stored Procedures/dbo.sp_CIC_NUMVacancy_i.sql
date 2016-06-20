
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMVacancy_i]
	@NUM varchar(8),
	@VUT_ID int,
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

DECLARE @BT_VUT_ID int

IF @Capacity IS NOT NULL AND @Capacity > 0
		AND EXISTS(SELECT * FROM CIC_Vacancy_UnitType WHERE VUT_ID=@VUT_ID)
		AND EXISTS(SELECT * FROM GBL_BaseTable WHERE NUM=@NUM) BEGIN
	
	INSERT INTO CIC_BT_VUT (
		NUM,
		VUT_ID,
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

	IF EXISTS(SELECT * FROM CIC_BT_VUT WHERE BT_VUT_ID=@BT_VUT_ID) BEGIN
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

		INSERT INTO CIC_BT_VUT_TP (
			BT_VUT_ID,
			VTP_ID
		) SELECT DISTINCT
			@BT_VUT_ID,
			tm.ItemID
		FROM dbo.fn_GBL_ParseIntIDList(@VTPIDList,',') tm
		INNER JOIN CIC_Vacancy_TargetPop tp
			ON tm.ItemID = tp.VTP_ID

		DECLARE @GUID uniqueidentifier, @MemberID int
		SELECT @GUID = GUID, @MemberID=MemberID
		FROM CIC_BT_VUT pr
		INNER JOIN GBL_BaseTable bt
			ON bt.NUM = pr.NUM

		INSERT INTO CIC_BT_VUT_History
				(BT_VUT_ID, NUM, BT_VUT_GUID, VacancyChange, VacancyFinal, MODIFIED_DATE,
				 MODIFIED_BY, ServiceTitle, MemberID)
		VALUES	(@BT_VUT_ID, @NUM, @GUID, 0, @Vacancy, GETDATE(),
				 @MODIFIED_BY, @ServiceTitle, @MemberID)
	END
END

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_CIC_NUMVacancy_i] TO [cioc_login_role]
GO
