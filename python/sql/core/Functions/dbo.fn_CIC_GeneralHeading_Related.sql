SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_GeneralHeading_Related](
	@GH_ID int,
	@RelatedCon nvarchar(10),
	@NonPublic bit,
	@AnyLanguage bit
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(max)

SELECT @returnStr =  COALESCE(@returnStr + @RelatedCon,'') + GeneralHeading
	FROM dbo.fn_CIC_GeneralHeading_Related_rst(@GH_ID,@NonPublic,@AnyLanguage)
ORDER BY GeneralHeading

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_GeneralHeading_Related] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_GeneralHeading_Related] TO [cioc_login_role]
GO
