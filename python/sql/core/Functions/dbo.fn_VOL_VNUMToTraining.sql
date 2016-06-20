SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToTraining](
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
		+ trnn.Name
		+ CASE WHEN prn.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') + prn.Notes END
	FROM VOL_OP_TRN pr
	LEFT JOIN VOL_OP_TRN_Notes prn
		ON pr.OP_TRN_ID=prn.OP_TRN_ID AND prn.LangID=@@LANGID
	INNER JOIN VOL_Training trn
		ON pr.TRN_ID=trn.TRN_ID
	INNER JOIN VOL_Training_Name trnn
		ON trn.TRN_ID=trnn.TRN_ID AND trnn.LangID=@@LANGID
WHERE pr.VNUM = @VNUM
ORDER BY trn.DisplayOrder, trnn.Name

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @Notes IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Notes
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToTraining] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToTraining] TO [cioc_vol_search_role]
GO
