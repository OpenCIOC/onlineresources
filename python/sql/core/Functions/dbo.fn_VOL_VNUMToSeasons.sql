SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToSeasons](
	@VNUM varchar(10),
	@Notes nvarchar(max)
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

DECLARE	@conStr	nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') 
		+ ssnn.Name
		+ CASE WHEN prn.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') + prn.Notes END
	FROM VOL_OP_SSN pr
	LEFT JOIN VOL_OP_SSN_Notes prn
		ON pr.OP_SSN_ID=prn.OP_SSN_ID AND prn.LangID=@@LANGID
	INNER JOIN VOL_Seasons ssn
		ON pr.SSN_ID=ssn.SSN_ID
	INNER JOIN VOL_Seasons_Name ssnn
		ON ssn.SSN_ID=ssnn.SSN_ID AND ssnn.LangID=@@LANGID
WHERE pr.VNUM = @VNUM
ORDER BY ssn.DisplayOrder, ssnn.Name

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @Notes IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Notes
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSeasons] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSeasons] TO [cioc_vol_search_role]
GO
