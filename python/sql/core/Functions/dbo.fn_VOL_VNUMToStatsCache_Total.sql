SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_VOL_VNUMToStatsCache_Total](
	@MemberID int,
	@VNUM varchar(10)
)
RETURNS [nvarchar](100) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@returnStr nvarchar(100)

SELECT @returnStr = cioc_shared.dbo.fn_SHR_GBL_UsageCount(CMP_USAGE_COUNT, CMP_USAGE_COUNT_DATE)
	FROM VOL_Opportunity_StatsCache stc
WHERE MemberID=@MemberID AND VNUM=@VNUM

IF @returnStr = '' SET @returnStr = NULL

RETURN ISNULL(@returnStr,cioc_shared.dbo.fn_SHR_GBL_UsageCount(0, (SELECT MAX(CMP_USAGE_COUNT_DATE) FROM VOL_Opportunity_StatsCache)))

END



GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToStatsCache_Total] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToStatsCache_Total] TO [cioc_vol_search_role]
GO
