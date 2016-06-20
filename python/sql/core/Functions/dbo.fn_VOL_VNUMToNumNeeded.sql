SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToNumNeeded](
	@VNUM varchar(10),
	@totalNeeded smallint,
	@numNotes nvarchar(4000)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@returnStr nvarchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ' ; ','') 
		+ Community
		+ CASE WHEN NUM_NEEDED IS NOT NULL AND NUM_NEEDED > 0
			THEN cioc_shared.dbo.fn_SHR_STP_ObjectName(': ') +  CAST(NUM_NEEDED AS varchar) + ' ' + cioc_shared.dbo.fn_SHR_STP_ObjectName(' individual(s)')
			ELSE ''
			END
	FROM dbo.fn_VOL_VNUMToNumNeeded_rst(@VNUM)

IF @totalNeeded IS NOT NULL BEGIN
	IF @returnStr IS NULL BEGIN
		SET @returnStr = ''
	END ELSE BEGIN
		SET @returnStr = @returnStr + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	END
	SET @returnStr = @returnStr + CAST(@totalNeeded AS varchar) + cioc_shared.dbo.fn_SHR_STP_ObjectName(' individual(s) needed in total.')
END

IF @numNotes IS NOT NULL BEGIN
	IF @returnStr IS NULL BEGIN
		SET @returnStr = ''
	END ELSE BEGIN
		SET @returnStr = @returnStr + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
	END
	SET @returnStr = @returnStr  + @numNotes
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToNumNeeded] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToNumNeeded] TO [cioc_vol_search_role]
GO
