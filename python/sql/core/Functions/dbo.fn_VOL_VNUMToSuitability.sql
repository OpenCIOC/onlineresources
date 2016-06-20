SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToSuitability](
	@VNUM varchar(10)
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
		+ sbn.Name
		+ CASE WHEN prn.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') + prn.Notes END
	FROM VOL_OP_SB pr
	LEFT JOIN VOL_OP_SB_Notes prn
		ON pr.OP_SB_ID=prn.OP_SB_ID AND prn.LangID=@@LANGID
	INNER JOIN VOL_Suitability sb
		ON pr.SB_ID=sb.SB_ID
	INNER JOIN VOL_Suitability_Name sbn
		ON sb.SB_ID=sbn.SB_ID AND sbn.LangID=@@LANGID
WHERE pr.VNUM = @VNUM
ORDER BY sb.DisplayOrder, sbn.Name

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSuitability] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSuitability] TO [cioc_vol_search_role]
GO
