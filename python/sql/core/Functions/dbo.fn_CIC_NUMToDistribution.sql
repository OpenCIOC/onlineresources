SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToDistribution](
	@MemberID int,
	@NUM varchar(8)
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 11-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	varchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ' ; ','') + DistCode
	FROM CIC_BT_DST pr
	INNER JOIN CIC_Distribution dst
		ON pr.DST_ID = dst.DST_ID
			AND (MemberID IS NULL OR @MemberID IS NULL OR MemberID=@MemberID)
			AND NOT EXISTS(SELECT * FROM CIC_Distribution_InactiveByMember WHERE DST_ID=dst.DST_ID AND MemberID=@MemberID)
WHERE NUM = @NUM
ORDER BY DistCode
IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr
END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToDistribution] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToDistribution] TO [cioc_login_role]
GO
