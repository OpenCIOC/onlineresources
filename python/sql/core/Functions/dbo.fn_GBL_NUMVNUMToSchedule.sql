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
		dbo.fn_GBL_ScheduleRow(
			START_DATE, END_DATE, START_TIME, END_TIME, RECURS_EVERY, RECURS_DAY_OF_WEEK,
			RECURS_WEEKDAY_1, RECURS_WEEKDAY_2, RECURS_WEEKDAY_3, RECURS_WEEKDAY_4, RECURS_WEEKDAY_5,
			RECURS_WEEKDAY_6, RECURS_WEEKDAY_7, RECURS_DAY_OF_MONTH, RECURS_XTH_WEEKDAY_OF_MONTH, Label
		)
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
