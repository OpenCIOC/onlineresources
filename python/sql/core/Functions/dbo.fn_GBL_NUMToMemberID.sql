SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[fn_GBL_NUMToMemberID](
	@NUM varchar(8)
)
RETURNS int WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 31-Jan-2012
	Action: NO ACTION REQUIRED
*/

RETURN (SELECT MemberID FROM GBL_BaseTable WHERE NUM=@NUM)

END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToMemberID] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToMemberID] TO [cioc_login_role]
GO
