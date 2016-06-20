SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE FUNCTION [dbo].[fn_VOL_VNUMToMemberID](
	@VNUM varchar(10)
)
RETURNS int WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

RETURN (SELECT MemberID FROM VOL_Opportunity WHERE VNUM=@VNUM)

END



GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToMemberID] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToMemberID] TO [cioc_vol_search_role]
GO
