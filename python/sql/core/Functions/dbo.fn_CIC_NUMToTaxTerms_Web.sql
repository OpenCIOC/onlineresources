SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToTaxTerms_Web](
	@NUM varchar(8),
	@LinkAll bit,
	@LangID smallint,
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 08-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + LinkedTerm
	FROM dbo.fn_CIC_NUMToTaxTerms_rst(@NUM,1,@LinkAll,@LangID,@HTTPVals,@PathToStart)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToTaxTerms_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToTaxTerms_Web] TO [cioc_login_role]
GO
