SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_GHIDToTaxTerms](
	@GH_ID int,
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

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID)

SELECT @returnStr =  COALESCE(@returnStr + ' ; ','') + LinkedTerm
	FROM dbo.fn_CIC_GHIDToTaxTerms_rst(@GH_ID,@LangID)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END



GO
GRANT EXECUTE ON  [dbo].[fn_CIC_GHIDToTaxTerms] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_GHIDToTaxTerms] TO [cioc_login_role]
GO
