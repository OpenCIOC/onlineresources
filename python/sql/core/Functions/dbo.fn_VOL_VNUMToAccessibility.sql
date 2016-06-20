SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToAccessibility](
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

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'')
		+ acn.Name
		+ CASE WHEN prn.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') + prn.Notes END
	FROM VOL_OP_AC pr
	LEFT JOIN VOL_OP_AC_Notes prn
		ON pr.OP_AC_ID=prn.OP_AC_ID AND prn.LangID=@@LANGID
	INNER JOIN GBL_Accessibility ac
		ON pr.AC_ID = ac.AC_ID
	INNER JOIN GBL_Accessibility_Name acn
		ON ac.AC_ID=acn.AC_ID AND acn.LangID=@@LANGID
WHERE pr.VNUM = @VNUM
ORDER BY ac.DisplayOrder, acn.Name

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @Notes IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Notes
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToAccessibility] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToAccessibility] TO [cioc_vol_search_role]
GO
