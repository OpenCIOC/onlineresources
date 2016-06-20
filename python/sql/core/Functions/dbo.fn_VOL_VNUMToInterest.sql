SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToInterest](
	@VNUM varchar(10),
	@LangID smallint
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

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID)

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + ai.InterestName
	FROM dbo.fn_VOL_VNUMToInterest_rst(@VNUM, @LangID) ai

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToInterest] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToInterest] TO [cioc_vol_search_role]
GO
