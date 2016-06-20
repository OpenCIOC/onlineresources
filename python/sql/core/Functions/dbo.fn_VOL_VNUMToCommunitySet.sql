SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToCommunitySet](
	@VNUM varchar(10)
)
RETURNS [varchar](max) WITH EXECUTE AS CALLER
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
		+  frn.SetName
	FROM VOL_OP_CommunitySet pr
	INNER JOIN VOL_CommunitySet fr
		ON pr.CommunitySetID = fr.CommunitySetID
	INNER JOIN VOL_CommunitySet_Name frn
		ON fr.CommunitySetID=frn.CommunitySetID AND LangID=(SELECT TOP 1 LangID FROM VOL_CommunitySet_Name WHERE frn.CommunitySetID=CommunitySetID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE VNUM = @VNUM
ORDER BY frn.SetName

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToCommunitySet] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToCommunitySet] TO [cioc_vol_search_role]
GO
