SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_UsageCountLogin](
	@MemberID int,
	@RSN int
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

DECLARE @returnVal int

SELECT @returnVal = COUNT(*)
	FROM CIC_Stats_RSN
WHERE MemberID=@MemberID
	AND RSN=@RSN
	AND [User_ID] IS NOT NULL

RETURN @returnVal

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_UsageCountLogin] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_UsageCountLogin] TO [cioc_login_role]
GO
