SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToFunding](
	@NUM varchar(8),
	@Notes nvarchar(max),
	@LangID smallint
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jul-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID)

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') 
		+ fdn.Name
		+ CASE WHEN prn.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' - ',@LangID) + prn.Notes END
	FROM CIC_BT_FD pr
	LEFT JOIN CIC_BT_FD_Notes prn
		ON pr.BT_FD_ID=prn.BT_FD_ID AND prn.LangID=@LangID
	INNER JOIN CIC_Funding fd
		ON pr.FD_ID=fd.FD_ID
	INNER JOIN CIC_Funding_Name fdn
		ON fd.FD_ID=fdn.FD_ID AND fdn.LangID=@LangID
	WHERE NUM = @NUM
ORDER BY fd.DisplayOrder, fdn.Name

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @Notes IS NOT NULL BEGIN
	SELECT @returnStr = @returnStr + @conStr + @Notes
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToFunding] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToFunding] TO [cioc_login_role]
GO
