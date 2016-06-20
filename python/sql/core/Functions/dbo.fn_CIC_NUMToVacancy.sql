
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToVacancy](
	@NUM varchar(8),
	@VACANCY_NOTES varchar(max),
	@WebEnable bit
)
RETURNS nvarchar(MAX) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr	nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = CHAR(13) + CHAR(10)

SELECT @returnStr =  COALESCE(@returnStr + @conStr + @conStr,'') 
		+ CASE WHEN @WebEnable=0
			THEN dbo.fn_CIC_NUMToVacancy_UnitType(
				UnitName,
				ServiceTitle,
				TargetPopulations,
				Capacity,
				FundedCapacity,
				Vacancy,
				HoursPerDay,
				DaysPerWeek,
				WeeksPerYear,
				FullTimeEquivalent,
				WaitList,
				WaitListDate,
				Notes,
				MODIFIED_DATE
			)
			ELSE dbo.fn_CIC_NUMToVacancy_UnitType_Web(
				UnitName,
				ServiceTitle,
				TargetPopulations,
				Capacity,
				FundedCapacity,
				Vacancy,
				HoursPerDay,
				DaysPerWeek,
				WeeksPerYear,
				FullTimeEquivalent,
				WaitList,
				WaitListDate,
				Notes,
				MODIFIED_DATE,
				BT_VUT_ID
			)
		END
	FROM dbo.fn_CIC_NUMToVacancy_UnitType_rst(@NUM)

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @VACANCY_NOTES IS NOT NULL BEGIN
	SELECT @returnStr = @returnStr + @conStr + @conStr + @VACANCY_NOTES
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO

GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToVacancy] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToVacancy] TO [cioc_login_role]
GO
