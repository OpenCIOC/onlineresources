SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMVNUMToSchedule_u](
	@NUM varchar(8) = NULL,
	@VNUM varchar(10) = NULL
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
		@returnStr	nvarchar(MAX)

SET @conStr = CHAR(13) + CHAR(10)

SELECT @returnStr = CAST(
	(SELECT SchedID,
			cioc_shared.dbo.fn_SHR_GBL_DateString(START_DATE) AS START_DATE,
			cioc_shared.dbo.fn_SHR_GBL_DateString(END_DATE) AS END_DATE,
			cioc_shared.dbo.fn_SHR_GBL_TimeString(START_TIME) AS START_TIME,
			cioc_shared.dbo.fn_SHR_GBL_TimeString(END_TIME) AS END_TIME,
			RECURS_EVERY,
			RECURS_DAY_OF_WEEK,
			RECURS_WEEKDAY_1,
			RECURS_WEEKDAY_2,
			RECURS_WEEKDAY_3,
			RECURS_WEEKDAY_4,
			RECURS_WEEKDAY_5,
			RECURS_WEEKDAY_6,
			RECURS_WEEKDAY_7,
			RECURS_DAY_OF_MONTH,
			RECURS_XTH_WEEKDAY_OF_MONTH,
			Label
	 FROM (SELECT 
		s.SchedID,
		s.START_DATE,
		s.END_DATE,
		s.START_TIME,
		s.END_TIME,
		s.RECURS_EVERY,
		s.RECURS_DAY_OF_WEEK,
		s.RECURS_WEEKDAY_1,
		s.RECURS_WEEKDAY_2,
		s.RECURS_WEEKDAY_3,
		s.RECURS_WEEKDAY_4,
		s.RECURS_WEEKDAY_5,
		s.RECURS_WEEKDAY_6,
		s.RECURS_WEEKDAY_7,
		s.RECURS_DAY_OF_MONTH,
		s.RECURS_XTH_WEEKDAY_OF_MONTH,
		sn.Label
	 FROM GBL_Schedule s
	 LEFT JOIN GBL_Schedule_Name sn
		 ON sn.SchedID = s.SchedID AND LangID=@@LANGID
     WHERE (@NUM IS NOT NULL AND GblNUM=@NUM) OR (@VNUM IS NOT NULL AND VolVNUM=@VNUM)) AS SCHEDULE ORDER BY START_DATE, START_TIME  FOR XML AUTO, ROOT('SCHEDULES'))
AS nvarchar(max)) 

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMVNUMToSchedule_u] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMVNUMToSchedule_u] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMVNUMToSchedule_u] TO [cioc_vol_search_role]
GO
