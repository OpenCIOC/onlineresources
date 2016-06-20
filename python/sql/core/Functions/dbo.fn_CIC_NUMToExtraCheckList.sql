SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_NUMToExtraCheckList](
	@FieldName varchar(100),
	@NUM varchar(8),
	@LangID smallint
)
RETURNS nvarchar(MAX) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 26-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(MAX)

SELECT @returnStr =  COALESCE(@returnStr + ' ; ','') + exc.ExtraCheckList
	FROM dbo.fn_CIC_NUMToExtraCheckList_rst(@FieldName, @NUM, @LangID) exc

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END




GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToExtraCheckList] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToExtraCheckList] TO [cioc_login_role]
GO
