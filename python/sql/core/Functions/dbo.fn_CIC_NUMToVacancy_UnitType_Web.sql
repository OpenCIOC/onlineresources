
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToVacancy_UnitType_Web](
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
	@MODIFIED_DATE smalldatetime,
	@BT_VUT_ID int
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6.3
	Checked by: CL
	Checked on: 04-Apr-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(MAX)

SET @returnStr = '<table border="1" class="BasicBorder cell-padding-2">'
	/* Service Title */
	+ CASE
		WHEN @ServiceTitle IS NULL
		THEN ''
		ELSE '<tr><th colspan="2" class="TitleBoxSm" style="text-align:left">'
			+ cioc_shared.dbo.fn_SHR_STP_ObjectName('Service') + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
			+ @ServiceTitle
			+ '</th></tr>'
	END
	/* Capacity Details */
	+ '<tr><td class="FieldLabelLeftClr">' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Capacity') + '</td><td>'
	+ CAST(@Capacity AS varchar) + ' ' + @UnitTypeName
	+ CASE WHEN @TargetPop IS NULL THEN '' ELSE ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('for /the plural') + ' ' + @TargetPop END
	+ CASE WHEN @FundedCapacity IS NULL THEN '' ELSE '; ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Funded Capacity of ') + CAST(@FundedCapacity AS varchar) + ' ' + @UnitTypeName END
	+ '.</td></tr>'
	/* Vacancy */
	+ '<tr><td class="FieldLabelLeftClr">' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Vacancy') + '</td><td><span class="vacancy-count" data-vut-id="' + CAST(@BT_VUT_ID AS varchar) + '" id="vacancy-count-' + CAST(@BT_VUT_ID AS varchar) + '">'
	+ CASE
		WHEN @Vacancy IS NULL THEN ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Vacancy is unknown')
		WHEN @Vacancy=0 THEN ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('No vacancy')
		ELSE ' ' + CAST(@Vacancy AS varchar) + ' ' + @UnitTypeName + ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName('are available')
	END
	+ CASE 
		WHEN @MODIFIED_DATE IS NOT NULL THEN ' (' + cioc_shared.dbo.fn_SHR_STP_ObjectName('as of') + ' ' + cioc_shared.dbo.fn_SHR_GBL_DateString(@MODIFIED_DATE) + ')'
		ELSE ''
	END + '.</span></td></tr>'
	/* Misc Service Details */
	+ CASE 
		WHEN @HoursPerDay IS NULL AND @DaysPerWeek IS NULL AND @WeeksPerYear IS NULL AND @FullTimeEquivalent IS NULL
		THEN ''
		ELSE '<tr><td class="FieldLabelLeftClr">' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Other Details') + '</td><td>'
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
			+ '</td></tr>'
	END
	/* Wait List */
	+ CASE
		WHEN @WaitList IS NULL
		THEN ''
		ELSE '<tr><td class="FieldLabelLeftClr">' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Wait List') + '</td><td>'
			+ CASE
				WHEN @WaitList=0 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('A wait list is not available.')
				WHEN @WaitList=1 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('A wait list is available') +
					CASE
						WHEN @WaitListDate IS NOT NULL THEN ' (' + cioc_shared.dbo.fn_SHR_GBL_DateString(@WaitListDate) + ').'
						ELSE '.'
					END
				ELSE ''
			END
	END + '</td></tr>'
	/* Notes */
	+ CASE 
		WHEN @Notes IS NULL
		THEN ''
		ELSE '<tr><td class="FieldLabelLeftClr">' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Notes') + '</td><td>'
			+ @Notes
			+ '</td></tr>'
	END
	+ '</table>'

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO


GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToVacancy_UnitType_Web] TO [cioc_login_role]
GO
