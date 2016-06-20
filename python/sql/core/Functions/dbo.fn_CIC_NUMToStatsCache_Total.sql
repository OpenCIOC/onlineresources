SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_NUMToStatsCache_Total](
	@MemberID int,
	@NUM [varchar](8)
)
RETURNS [nvarchar](100) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 31-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr nvarchar(100)

SELECT @returnStr = cioc_shared.dbo.fn_SHR_GBL_UsageCount(CMP_USAGE_COUNT, CMP_USAGE_COUNT_DATE)
	FROM GBL_BaseTable_StatsCache stc
WHERE MemberID=@MemberID AND NUM=@NUM

IF @returnStr = '' SET @returnStr = NULL

RETURN ISNULL(@returnStr,cioc_shared.dbo.fn_SHR_GBL_UsageCount(0, (SELECT MAX(CMP_USAGE_COUNT_DATE) FROM GBL_BaseTable_StatsCache)))

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToStatsCache_Total] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToStatsCache_Total] TO [cioc_login_role]
GO
