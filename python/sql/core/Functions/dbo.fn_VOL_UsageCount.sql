SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_UsageCount](
	@MemberID int,
	@OP_ID int
)
RETURNS int WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Feb-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @returnVal int

SELECT @returnVal = COUNT(*)
	FROM VOL_Stats_OPID
WHERE MemberID=@MemberID
	AND OP_ID=@OP_ID

RETURN @returnVal

END


GO
GRANT EXECUTE ON  [dbo].[fn_VOL_UsageCount] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_UsageCount] TO [cioc_vol_search_role]
GO
