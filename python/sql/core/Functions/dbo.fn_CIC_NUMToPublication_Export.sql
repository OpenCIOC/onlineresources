SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_NUMToPublication_Export](
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

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + PubCode
	FROM CIC_BT_PB pr
	INNER JOIN CIC_Publication pb
		ON pr.PB_ID = pb.PB_ID
	INNER JOIN CIC_ExportProfile_Pub epp
		ON pb.PB_ID=epp.PB_ID AND epp.ProfileID=@ProfileID
WHERE NUM=@NUM
ORDER BY PubCode

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToPublication_Export] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToPublication_Export] TO [cioc_login_role]
GO
