SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_ImportEntry_Distributions](
	@EF_ID int
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	varchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ',','') + CAST(DST_ID AS varchar) FROM CIC_ImportEntry_Dist WHERE EF_ID=@EF_ID

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_ImportEntry_Distributions] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_ImportEntry_Distributions] TO [cioc_login_role]
GO
