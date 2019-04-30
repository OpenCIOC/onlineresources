SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_ScheduleRow](
	@START_DATE date,
	@END_DATE date,
	@START_TIME time(7),
	@END_TIME time(7),
	@RECURS_EVERY tinyint,
	@RECURS_DAY_OF_WEEK bit,
	@RECURS_WEEKDAY_1 bit,
	@RECURS_WEEKDAY_2 bit,
	@RECURS_WEEKDAY_3 bit,
	@RECURS_WEEKDAY_4 bit,
	@RECURS_WEEKDAY_5 bit,
	@RECURS_WEEKDAY_6 bit,
	@RECURS_WEEKDAY_7 bit,
	@RECURS_DAY_OF_MONTH tinyint,
	@RECURS_XTH_WEEKDAY_OF_MONTH tinyint,
	@Label nvarchar(200)
)
RETURNS nvarchar(MAX) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.7
	Checked by: CL
	Checked on: 02-Nov-2017
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(MAX)
DECLARE @days table (
		name nvarchar(100),
		incl bit,
		o tinyint
	)

INSERT INTO @days VALUES
	(cioc_shared.dbo.fn_SHR_STP_ObjectName('Sunday'), @RECURS_WEEKDAY_1, 1),
	(cioc_shared.dbo.fn_SHR_STP_ObjectName('Monday'), @RECURS_WEEKDAY_2, 2), 
	(cioc_shared.dbo.fn_SHR_STP_ObjectName('Tuesday'), @RECURS_WEEKDAY_3, 3), 
	(cioc_shared.dbo.fn_SHR_STP_ObjectName('Wednesday'), @RECURS_WEEKDAY_4, 4),
	(cioc_shared.dbo.fn_SHR_STP_ObjectName('Thursday'), @RECURS_WEEKDAY_5, 5),
	(cioc_shared.dbo.fn_SHR_STP_ObjectName('Friday'), @RECURS_WEEKDAY_6, 6), 
	(cioc_shared.dbo.fn_SHR_STP_ObjectName('Saturday'), @RECURS_WEEKDAY_7, 7)
						


SET @returnStr = (SELECT 
		CASE WHEN @Label IS NOT NULL THEN
			@Label + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
		ELSE
			''
		END  +
		CASE WHEN @RECURS_EVERY != 0 THEN 
				CASE WHEN @RECURS_DAY_OF_MONTH IS NOT NULL OR @RECURS_XTH_WEEKDAY_OF_MONTH IS NOT NULL THEN 
					cioc_shared.dbo.fn_SHR_STP_ObjectName('On the ') + CAST(COALESCE(@RECURS_DAY_OF_MONTH, @RECURS_XTH_WEEKDAY_OF_MONTH)  AS varchar) +
					 CASE WHEN COALESCE(@RECURS_DAY_OF_MONTH, @RECURS_XTH_WEEKDAY_OF_MONTH) % 100 IN (11, 12, 13) THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('th')
					 WHEN COALESCE(@RECURS_DAY_OF_MONTH, @RECURS_XTH_WEEKDAY_OF_MONTH) % 10 = 1 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('st')
					 WHEN COALESCE(@RECURS_DAY_OF_MONTH, @RECURS_XTH_WEEKDAY_OF_MONTH) % 10 = 2 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('nd')
					 WHEN COALESCE(@RECURS_DAY_OF_MONTH, @RECURS_XTH_WEEKDAY_OF_MONTH) % 10 = 3 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('rd')
					 ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('th')
					 END + CASE WHEN @RECURS_DAY_OF_MONTH IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' day of the month') ELSE ' ' END
				ELSE
					''
				END +
				CASE WHEN @RECURS_XTH_WEEKDAY_OF_MONTH IS NOT NULL OR @RECURS_DAY_OF_WEEK = 1 THEN 
					CASE WHEN 1 IN (@RECURS_WEEKDAY_1, @RECURS_WEEKDAY_2, @RECURS_WEEKDAY_3, @RECURS_WEEKDAY_4, @RECURS_WEEKDAY_5, @RECURS_WEEKDAY_6, @RECURS_WEEKDAY_7) THEN
						STUFF(
							(SELECT ', ' + CASE WHEN (SELECT COUNT(*) FROM @days WHERE incl=1) > 1 AND name = (SELECT TOP 1 name FROM 
										@days AS c WHERE incl=1 ORDER BY o DESC) THEN 'and ' ELSE '' END + name
							FROM @days AS d
							WHERE incl = 1
							FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)')
							,1, 2, '') + CASE WHEN @RECURS_XTH_WEEKDAY_OF_MONTH IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' of the month') ELSE '' END
					ELSE
						''
					END
				ELSE
					''
				END +
				CASE WHEN @RECURS_XTH_WEEKDAY_OF_MONTH IS NULL AND NOT (@RECURS_DAY_OF_MONTH IS NOT NULL AND @RECURS_EVERY = 1) THEN 
				cioc_shared.dbo.fn_SHR_STP_ObjectName(' every ') + 
				-- multiple
				CASE WHEN @RECURS_EVERY > 1 THEN CAST(@RECURS_EVERY AS varchar) + --CASE WHEN @RECURS_DAY_OF_WEEK = 1 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' weeks') ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' months') END
					 CASE WHEN @RECURS_EVERY % 100 IN (11, 12, 13) THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('th')
					 WHEN @RECURS_EVERY % 10 = 1 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('st')
					 WHEN @RECURS_EVERY % 10 = 2 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('nd')
					 WHEN @RECURS_EVERY % 10 = 3 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('rd')
					 ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('th')
					END + ' '
				-- single
				ELSE
				''
				END + CASE WHEN @RECURS_DAY_OF_WEEK = 1 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('week') ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('month') END
				ELSE '' END 
				+ cioc_shared.dbo.fn_SHR_STP_ObjectName(' from ')
		ELSE
			''
		END  + 
		CASE WHEN @END_DATE IS NOT NULL AND @START_DATE != @END_DATE THEN
		  cioc_shared.dbo.fn_SHR_GBL_DateString(@START_DATE) + cioc_shared.dbo.fn_SHR_STP_ObjectName(' to ') + cioc_shared.dbo.fn_SHR_GBL_DateString(@END_DATE) 
		ELSE
		  cioc_shared.dbo.fn_SHR_GBL_DateString(@START_DATE)
		END +
		CASE WHEN @START_TIME IS NOT NULL THEN 
			cioc_shared.dbo.fn_SHR_STP_ObjectName(', ') + cioc_shared.dbo.fn_SHR_GBL_TimeString(@START_TIME) +
			CASE WHEN @END_TIME IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' to ') + cioc_shared.dbo.fn_SHR_GBL_TimeString(@END_TIME) 
			ELSE '' END
		ELSE 
		''
		END
		)


IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
