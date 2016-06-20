SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToPublication_Web](
	@MemberID int,
	@NUM varchar(8),
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 31-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + cioc_shared.dbo.fn_SHR_CIC_Link_Publication(pb.PB_ID,pb.PubCode,@HTTPVals,@PathToStart)
	FROM CIC_BT_PB pr
	INNER JOIN CIC_Publication pb
		ON pr.PB_ID = pb.PB_ID
			AND (MemberID IS NULL OR @MemberID IS NULL OR MemberID=@MemberID)
			AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE PB_ID=pb.PB_ID AND MemberID=@MemberID)
WHERE NUM = @NUM
ORDER BY PubCode

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToPublication_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToPublication_Web] TO [cioc_login_role]
GO
