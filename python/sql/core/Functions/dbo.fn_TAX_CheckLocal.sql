SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fn_TAX_CheckLocal](
	@CdLocal varchar(1),
	@Authorized bit
)
RETURNS bit WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

RETURN CASE WHEN (@CdLocal='L' AND @Authorized=0) OR (@CdLocal IS NULL AND @Authorized=1) THEN 0 ELSE -1 END

END

GO
GRANT EXECUTE ON  [dbo].[fn_TAX_CheckLocal] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_TAX_CheckLocal] TO [cioc_login_role]
GO
