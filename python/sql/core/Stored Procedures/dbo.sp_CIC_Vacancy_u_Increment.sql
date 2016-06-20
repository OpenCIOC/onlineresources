
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Vacancy_u_Increment]
	@User_ID [int],
	@MODIFIED_BY varchar(50),
	@ViewType [int],
	@BT_VUT_ID [int],
	@Value [int],
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: CL
	Checked on: 26-Apr-2015
	Action: NEEDS HISTORY
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@UserObjectName	nvarchar(100),
		@ViewObjectName nvarchar(100),
		@VacancyObjectName nvarchar(100),
		@NameObjectName nvarchar(100)

SET @UserObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @VacancyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Vacancy')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')

DECLARE @NUM varchar(8), @MODIFIED_DATE datetime, @MemberID int

SELECT @NUM=bt.NUM, @MemberID=bt.MemberID FROM CIC_BT_VUT btvut INNER JOIN GBL_BaseTable bt ON bt.NUM = btvut.NUM
SET @MODIFIED_DATE = GETDATE()

-- Member ID given ?
IF @User_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Users WHERE User_ID=@User_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@User_ID AS varchar), @UserObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM CIC_BT_VUT WHERE BT_VUT_ID=@BT_VUT_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@BT_VUT_ID AS varchar), @VacancyObjectName)
END ELSE IF dbo.fn_CIC_CanUpdateVacancy(@NUM, @User_ID, @ViewType, @@LANGID, GETDATE()) != 1 BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @VacancyObjectName, NULL)
END

DECLARE @Change table (TargetCount int)
DECLARE @TargetCount int, @Capacity int, @Changed bit, @ServiceTitle nvarchar(100), @GUID uniqueidentifier
SET @Changed = 0
IF @Error=0 BEGIN
	BEGIN TRANSACTION
		UPDATE CIC_BT_VUT SET Vacancy=ISNULL(Vacancy, 0) + @Value, MODIFIED_DATE=GETDATE()
		OUTPUT Inserted.Vacancy INTO @Change
		WHERE BT_VUT_ID=@BT_VUT_ID
		
		SELECT @TargetCount = TargetCount FROM @Change

		SELECT @Capacity = Capacity, @ServiceTitle=ServiceTitle, @GUID=GUID
		FROM CIC_BT_VUT pr
		LEFT JOIN CIC_BT_VUT_Notes prn
			ON pr.BT_VUT_ID=prn.BT_VUT_ID
				AND prn.LangID=@@LANGID
		 WHERE pr.BT_VUT_ID=@BT_VUT_ID

		IF @TargetCount >=0 AND @TargetCount <= @Capacity BEGIN
			INSERT INTO CIC_BT_VUT_History
					(BT_VUT_ID, VacancyChange, VacancyFinal, MODIFIED_DATE, MODIFIED_BY, ServiceTitle, BT_VUT_GUID, MemberID, NUM)
			VALUES	(@BT_VUT_ID, @Value, @TargetCount, GETDATE(), @MODIFIED_BY, @ServiceTitle, @GUID, @MemberID, @NUM)
			SET @Changed = 1
			COMMIT TRANSACTION
		END ELSE BEGIN
			ROLLBACK TRANSACTION
		END


	IF @Changed = 0 BEGIN
		IF @TargetCount < 0 BEGIN
			SET @Error = 32 -- Not enough Vacancy
			SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
		END ELSE IF @TargetCount > @Capacity BEGIN
			SET @Error = 33 -- Not enough Capacity
			SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Capacity AS varchar), NULL)
		END
	END ELSE BEGIN
		
		EXEC sp_GBL_BaseTable_History_i_Field @MODIFIED_BY, @MODIFIED_DATE, @NUM, 'VACANCY_INFO', @User_ID, @ViewType, NULL 
		
	END

END

SELECT 
	 CASE
		WHEN Vacancy IS NULL THEN ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Vacancy is unknown')
		WHEN Vacancy=0 THEN ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('No vacancy')
		ELSE ' ' + CAST(Vacancy AS varchar) + ' ' + vutn.Name + ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('are available')
	END
	+ CASE 
		WHEN pr.MODIFIED_DATE IS NOT NULL THEN ' (' + cioc_shared.dbo.fn_SHR_STP_ObjectName('as of') + ' ' + cioc_shared.dbo.fn_SHR_GBL_DateString(pr.MODIFIED_DATE) + ')'
		ELSE ''
	END AS [Text],
	BT_VUT_ID
FROM CIC_BT_VUT pr
	INNER JOIN CIC_Vacancy_UnitType vut
		ON pr.VUT_ID=vut.VUT_ID
	LEFT JOIN CIC_Vacancy_UnitType_Name vutn
		ON vut.VUT_ID=vutn.VUT_ID
			AND vutn.LangID=(SELECT TOP 1 LangID FROM CIC_Vacancy_UnitType_Name WHERE VUT_ID=vut.VUT_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE BT_VUT_ID=@BT_VUT_ID


RETURN @Error

SET NOCOUNT OFF



GO


GRANT EXECUTE ON  [dbo].[sp_CIC_Vacancy_u_Increment] TO [cioc_login_role]
GO
