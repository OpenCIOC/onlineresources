SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMToAccessibility](
	@NUM varchar(8),
	@Notes nvarchar(max),
	@LangID smallint
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr	nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID)

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + acn.Name
		+ CASE WHEN prn.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' - ',@LangID) + prn.Notes END
	FROM GBL_BT_AC pr
	LEFT JOIN GBL_BT_AC_Notes prn
		ON pr.BT_AC_ID=prn.BT_AC_ID AND prn.LangID=@LangID
	INNER JOIN GBL_Accessibility ac
		ON pr.AC_ID = ac.AC_ID
	INNER JOIN GBL_Accessibility_Name acn
		ON ac.AC_ID=acn.AC_ID AND acn.LangID=@LangID
WHERE NUM = @NUM
ORDER BY ac.DisplayOrder, acn.Name

IF @returnStr IS NULL SET @returnStr = ''

IF @returnStr = '' SET @conStr = ''

IF @Notes IS NOT NULL BEGIN
	SELECT @returnStr = @returnStr + @conStr + @Notes
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToAccessibility] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToAccessibility] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToAccessibility] TO [cioc_vol_search_role]
GO
