SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_GHIDToTaxTerms_Link](
	@GH_TAX_ID int,
	@LangID smallint
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 30-Sep-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	varchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ' ~ ','') + Term
	FROM fn_CIC_GHIDToTaxTerms_Link_rst(@GH_TAX_ID,@LangID)
ORDER BY Code

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_GHIDToTaxTerms_Link] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_GHIDToTaxTerms_Link] TO [cioc_login_role]
GO
