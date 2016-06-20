SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToNAICS_Web](
	@NUM [varchar](8),
	@HTTPVals [varchar](500),
	@PathToStart [varchar](50)
)
RETURNS [varchar](max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + 
		cioc_shared.dbo.fn_SHR_NAICS_Link_Code(nc.Code,ncd.Classification,@HTTPVals,@PathToStart)
	FROM CIC_BT_NC pr
	INNER JOIN NAICS nc
		ON pr.Code = nc.Code
	INNER JOIN NAICS_Description ncd
		ON nc.Code=ncd.Code AND LangID=(SELECT TOP 1 LangID FROM NAICS_Description WHERE Code=ncd.Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)
WHERE NUM = @NUM

ORDER BY nc.Code

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToNAICS_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToNAICS_Web] TO [cioc_login_role]
GO
