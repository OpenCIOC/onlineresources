SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMToFormerOrg](
	@NUM varchar(8),
	@LangID smallint
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr	nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID)

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + FORMER_ORG 
		+ CASE WHEN DATE_OF_CHANGE IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' (',@LangID) + DATE_OF_CHANGE COLLATE Latin1_General_100_CS_AS + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(')',@LangID) END
	FROM GBL_BT_FORMERORG
WHERE LangID=@LangID AND NUM=@NUM
ORDER BY FORMER_ORG

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToFormerOrg] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToFormerOrg] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToFormerOrg] TO [cioc_vol_search_role]
GO
