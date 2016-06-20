SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_O211_XML_DateFormat](
	@Date smalldatetime
)
RETURNS varchar(20) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr varchar(20)

IF @Date IS NOT NULL BEGIN
	SET @returnStr = REPLACE(LTRIM(RTRIM(CONVERT(varchar,@Date,6))), ' ', '-')
END

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_O211_XML_DateFormat] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_O211_XML_DateFormat] TO [cioc_login_role]
GO
