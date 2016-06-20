SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_VOL_VNUMToSkill_Web](
	@VNUM varchar(10),
	@Notes nvarchar(max),
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
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
		+ cioc_shared.dbo.fn_SHR_VOL_Link_Skill(sk.SK_ID,skn.Name,@HTTPVals,@PathToStart)
		+ CASE WHEN prn.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName(' - ') + prn.Notes END
	FROM VOL_OP_SK pr
	LEFT JOIN VOL_OP_SK_Notes prn
		ON pr.OP_SK_ID=prn.OP_SK_ID AND prn.LangID=@@LANGID
	INNER JOIN VOL_Skill sk
		ON pr.SK_ID=sk.SK_ID
	INNER JOIN VOL_Skill_Name skn
		ON sk.SK_ID=skn.SK_ID AND skn.LangID=@@LANGID
WHERE pr.VNUM = @VNUM
ORDER BY sk.DisplayOrder, skn.Name

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @Notes IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Notes
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END



GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSkill_Web] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToSkill_Web] TO [cioc_vol_search_role]
GO
