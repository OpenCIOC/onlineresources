SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToVacancy_UnitType](
	@UnitTypeName nvarchar(100),
	@ServiceTitle nvarchar(100),
	@TargetPop nvarchar(max),
	@Capacity smallint,
	@FundedCapacity smallint,
	@Vacancy smallint,
	@HoursPerDay [decimal](6, 1),
	@DaysPerWeek [decimal](6, 1),
	@WeeksPerYear [decimal](6, 1),
	@FullTimeEquivalent [decimal](6, 1),
	@WaitList bit,
	@WaitListDate smalldatetime,
	@Notes nvarchar(max),
	@MODIFIED_DATE smalldatetime
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@newLine char(2),
		@returnStr	nvarchar(max)

SET @newLine = CHAR(13) + CHAR(10)

SET @returnStr = 
	/* Service Title */
	CASE
		WHEN @ServiceTitle IS NULL
		THEN ''
		ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Service') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + @ServiceTitle + @newLine
	END
	/* Capacity Details */
	+ cioc_shared.dbo.fn_SHR_STP_ObjectName('Capacity') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
	+ CAST(@Capacity as varchar) + ' ' + @UnitTypeName
	+ CASE WHEN @TargetPop IS NULL THEN '' ELSE ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('for /the plural') + ' ' + @TargetPop END
	+ CASE WHEN @FundedCapacity IS NULL THEN '' ELSE '; ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Funded Capacity of ') + CAST(@FundedCapacity as varchar) + ' ' + @UnitTypeName END
	+ '.' + @newLine +
	/* Vacancy */
	+ cioc_shared.dbo.fn_SHR_STP_ObjectName('Vacancy') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') 
	+ CASE
		WHEN @Vacancy IS NULL THEN ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Vacancy is unknown')
		WHEN @Vacancy=0 THEN ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('No vacancy')
		ELSE ' ' + CAST(@Vacancy as varchar) + ' ' + @UnitTypeName + ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('are available')
	END
	+ CASE 
		WHEN @MODIFIED_DATE IS NOT NULL THEN ' (' + cioc_shared.dbo.fn_SHR_STP_ObjectName('as of') + ' ' + cioc_shared.dbo.fn_SHR_GBL_DateString(@MODIFIED_DATE) + ')'
		ELSE ''
	END + '.'
	/* Misc Service Details */
	+ CASE 
		WHEN @HoursPerDay IS NULL AND @DaysPerWeek IS NULL AND @WeeksPerYear IS NULL AND @FullTimeEquivalent IS NULL
		THEN ''
		ELSE @newLine
			+ CASE
				WHEN @HoursPerDay IS NULL
				THEN ''
				ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Hours per day') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
					+ REPLACE(CAST(@HoursPerDay AS varchar),'.0','') + CASE WHEN @DaysPerWeek IS NULL AND @WeeksPerYear IS NULL AND @FullTimeEquivalent IS NULL THEN '' ELSE '; ' END
			END
			+ CASE
				WHEN @DaysPerWeek IS NULL
				THEN ''
				ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Days per week') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
					+ REPLACE(CAST(@DaysPerWeek AS varchar),'.0','') + CASE WHEN @WeeksPerYear IS NULL AND @FullTimeEquivalent IS NULL THEN '' ELSE '; ' END
			END
			+ CASE
				WHEN @WeeksPerYear IS NULL
				THEN ''
				ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Weeks per year') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
					+ REPLACE(CAST(@WeeksPerYear AS varchar),'.0','') + CASE WHEN @FullTimeEquivalent IS NULL THEN '' ELSE '; ' END
			END
			+ CASE
				WHEN @FullTimeEquivalent IS NULL
				THEN ''
				ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Full-time Equivalent') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
					+ REPLACE(CAST(@FullTimeEquivalent AS varchar),'.0','')
			END
			+ '.'
	END
	/* Wait List */
	+ CASE
		WHEN @WaitList=0 THEN @newLine + cioc_shared.dbo.fn_SHR_STP_ObjectName('A wait list is not available.')
		WHEN @WaitList=1 THEN @newLine + cioc_shared.dbo.fn_SHR_STP_ObjectName('A wait list is available') +
			CASE
				WHEN @WaitListDate IS NOT NULL THEN ' (' + cioc_shared.dbo.fn_SHR_GBL_DateString(@WaitListDate) + ').'
				ELSE '.'
			END
		ELSE ''
	END
	/* Notes */
	+ CASE 
		WHEN @Notes IS NULL
		THEN ''
		ELSE @newLine + cioc_shared.dbo.fn_SHR_STP_ObjectName('Notes') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') + @Notes
	END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END
GO
