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
	(SELECT * FROM (SELECT 
		s.SchedID,
		cioc_shared.dbo.fn_SHR_GBL_DateString(s.START_DATE) AS START_DATE,
		cioc_shared.dbo.fn_SHR_GBL_DateString(s.END_DATE) AS END_DATE,
		cioc_shared.dbo.fn_SHR_GBL_TimeString(s.START_TIME) AS START_TIME,
		cioc_shared.dbo.fn_SHR_GBL_TimeString(s.END_TIME) AS END_TIME,
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
     WHERE (@NUM IS NOT NULL AND GblNUM=@NUM) OR (@VNUM IS NOT NULL AND VolVNUM=@VNUM)) AS SCHEDULE FOR XML AUTO, ROOT('SCHEDULES'))
AS nvarchar(max)) 

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMVNUMToSchedule_u] TO [cioc_login_role]
GO
