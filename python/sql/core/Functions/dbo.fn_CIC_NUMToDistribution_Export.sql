SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToDistribution_Export](
	@NUM varchar(8),
	@ProfileID int
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	varchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ' ; ','') + DistCode
	FROM CIC_BT_DST pr
	INNER JOIN CIC_Distribution ds
		ON pr.DST_ID = ds.DST_ID
	INNER JOIN CIC_ExportProfile_Dist epd
		ON ds.DST_ID=epd.DST_ID AND epd.ProfileID=@ProfileID
WHERE NUM = @NUM
ORDER BY DistCode

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToDistribution_Export] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToDistribution_Export] TO [cioc_login_role]
GO
