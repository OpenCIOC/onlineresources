SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_VNUMToReferrals](
	@MemberID int,
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

DECLARE @returnVal int

SELECT @returnVal = COUNT(*)
	FROM VOL_OP_Referral
WHERE VNUM=@VNUM
	AND (@MemberID IS NULL OR MemberID=@MemberID)

RETURN @returnVal

END


GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToReferrals] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToReferrals] TO [cioc_vol_search_role]
GO
