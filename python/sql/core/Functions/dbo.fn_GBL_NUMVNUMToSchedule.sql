SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMVNUMToSchedule](
	@NUM varchar(8) = NULL,
	@VNUM varchar(10) = NULL,
	@toweb bit = 0
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

DECLARE	@conStr	nvarchar(4),
		@returnStr	nvarchar(MAX),
		@seplen int

IF @toweb = 1 BEGIN
	SET @conStr = '<br>'
	SET @seplen = 4
END ELSE BEGIN
	SET @conStr = CHAR(13) + CHAR(10)
	SET @seplen = 2
END

SELECT @returnStr = STUFF(
	(SELECT @conStr + 
		CASE WHEN Label IS NOT NULL THEN
			Label + cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
		ELSE
			''
		END +
		CASE WHEN START_TIME IS NOT NULL THEN 
			cioc_shared.dbo.fn_SHR_GBL_TimeString(START_TIME) +
			CASE WHEN END_TIME IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' to ') + cioc_shared.dbo.fn_SHR_GBL_TimeString(END_TIME) 
			ELSE '' END
		ELSE 
		''
		END +
		CASE WHEN s.RECURS_EVERY != 0 THEN 
			CASE WHEN START_TIME IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' every ') ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('Every ') END + 
				-- multiple
				CASE WHEN RECURS_EVERY > 1 THEN CAST(RECURS_EVERY AS varchar) + CASE WHEN RECURS_DAY_OF_WEEK = 1 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' weeks') ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' months') END
				-- single
				ELSE CASE WHEN RECURS_DAY_OF_WEEK = 1 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('week') ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('month') END
				END
			+ cioc_shared.dbo.fn_SHR_STP_ObjectName(' on ') + 
				CASE WHEN RECURS_DAY_OF_MONTH IS NOT NULL OR RECURS_XTH_WEEKDAY_OF_MONTH IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' the ') + CAST(COALESCE(RECURS_DAY_OF_MONTH, RECURS_XTH_WEEKDAY_OF_MONTH)  AS varchar) +
					 CASE WHEN COALESCE(RECURS_DAY_OF_MONTH, RECURS_XTH_WEEKDAY_OF_MONTH) % 100 IN (11, 12, 13) THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('th')
					 WHEN COALESCE(RECURS_DAY_OF_MONTH, RECURS_XTH_WEEKDAY_OF_MONTH) % 10 = 1 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('st')
					 WHEN COALESCE(RECURS_DAY_OF_MONTH, RECURS_XTH_WEEKDAY_OF_MONTH) % 10 = 2 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('nd')
					 WHEN COALESCE(RECURS_DAY_OF_MONTH, RECURS_XTH_WEEKDAY_OF_MONTH) % 10 = 3 THEN cioc_shared.dbo.fn_SHR_STP_ObjectName('rd')
					 ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('th')
					 END + CASE WHEN RECURS_DAY_OF_MONTH IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' day') ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' week') END + cioc_shared.dbo.fn_SHR_STP_ObjectName(' of the month')
				ELSE
					''
				END +
				CASE WHEN RECURS_XTH_WEEKDAY_OF_MONTH IS NOT NULL OR RECURS_DAY_OF_WEEK = 1 THEN 
					CASE WHEN 1 IN (RECURS_WEEKDAY_1, RECURS_WEEKDAY_2, RECURS_WEEKDAY_3, RECURS_WEEKDAY_4, RECURS_WEEKDAY_5, RECURS_WEEKDAY_6, RECURS_WEEKDAY_7) THEN
						cioc_shared.dbo.fn_SHR_STP_ObjectName(' on ') + STUFF(
							(SELECT ', ' + CASE WHEN name = (SELECT TOP 1 name FROM 
									(VALUES 
										(cioc_shared.dbo.fn_SHR_STP_ObjectName('Monday'), RECURS_WEEKDAY_1, 1), 
										(cioc_shared.dbo.fn_SHR_STP_ObjectName('Tuesday'), RECURS_WEEKDAY_2, 2), 
										(cioc_shared.dbo.fn_SHR_STP_ObjectName('Wednesday'), RECURS_WEEKDAY_3, 3),
										(cioc_shared.dbo.fn_SHR_STP_ObjectName('Thursday'), RECURS_WEEKDAY_4, 4),
										(cioc_shared.dbo.fn_SHR_STP_ObjectName('Friday'), RECURS_WEEKDAY_5, 5), 
										(cioc_shared.dbo.fn_SHR_STP_ObjectName('Saturday'), RECURS_WEEKDAY_6, 6), 
										(cioc_shared.dbo.fn_SHR_STP_ObjectName('Sunday'), RECURS_WEEKDAY_7, 7)
									) AS c(name, incl, o) WHERE incl=1 ORDER BY o DESC) THEN 'and ' ELSE '' END + name
							FROM (VALUES
								(cioc_shared.dbo.fn_SHR_STP_ObjectName('Monday'), RECURS_WEEKDAY_1),
								(cioc_shared.dbo.fn_SHR_STP_ObjectName('Tuesday'), RECURS_WEEKDAY_2),
								(cioc_shared.dbo.fn_SHR_STP_ObjectName('Wednesday'), RECURS_WEEKDAY_3),
								(cioc_shared.dbo.fn_SHR_STP_ObjectName('Thursday'), RECURS_WEEKDAY_4),
								(cioc_shared.dbo.fn_SHR_STP_ObjectName('Friday'), RECURS_WEEKDAY_5),
								(cioc_shared.dbo.fn_SHR_STP_ObjectName('Saturday'), RECURS_WEEKDAY_6),
								(cioc_shared.dbo.fn_SHR_STP_ObjectName('Sunday'), RECURS_WEEKDAY_7)
								) AS d(name, incl)
							WHERE incl = 1
							FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)')
							,1, 2, '')
						
					ELSE
						''
					END
				ELSE
					''
				END + cioc_shared.dbo.fn_SHR_STP_ObjectName(' from ') + cioc_shared.dbo.fn_SHR_GBL_DateString(START_DATE) + CASE WHEN END_DATE IS NOT NULL AND START_DATE != END_DATE THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' to ') + cioc_shared.dbo.fn_SHR_GBL_DateString(END_DATE) ELSE '' END
		ELSE
			CASE WHEN END_DATE IS NOT NULL AND START_DATE != END_DATE THEN CASE WHEN START_TIME IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' from ') ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName('From ') END + cioc_shared.dbo.fn_SHR_GBL_DateString(START_DATE) + cioc_shared.dbo.fn_SHR_STP_ObjectName(' to ') + cioc_shared.dbo.fn_SHR_GBL_DateString(END_DATE) 
			ELSE CASE WHEN START_TIME IS NOT NULL THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(' on ') ELSE '' END + cioc_shared.dbo.fn_SHR_GBL_DateString(START_DATE) END
		END  

	 FROM GBL_Schedule s
	 LEFT JOIN GBL_Schedule_Name sn
		 ON sn.SchedID = s.SchedID AND LangID=@@LANGID
     WHERE (@NUM IS NOT NULL AND GblNUM=@NUM) OR (@VNUM IS NOT NULL AND VolVNUM=@VNUM)
	 ORDER BY START_DATE, START_TIME
	 FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)')
	 ,1, @seplen, '')

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMVNUMToSchedule] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMVNUMToSchedule] TO [cioc_vol_search_role]
GO
