
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_CIC_NUMToExtraCheckList_Web](
	@FieldName varchar(100),
	@NUM varchar(8),
	@LangID smallint,
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
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

DECLARE @ExtraFieldName varchar(25)
SET @ExtraFieldName = REPLACE(@FieldName,'EXTRA_CHECKLIST_','')

IF @HTTPVals = '' SET @HTTPVals = NULL

DECLARE	@returnStr	nvarchar(MAX)

SELECT @returnStr =  COALESCE(@returnStr + ' ; ','')
		+ '<a href="' + @PathToStart + 'results.asp?EXC' + @ExtraFieldName + 'ID=' + CAST(exc.EXC_ID AS varchar)
		+ '&EXC=' + @ExtraFieldName
		+ CASE WHEN @HTTPVals IS NOT NULL THEN '&' + @HTTPVals ELSE '' END + '">' + exc.ExtraCheckList + '</a>'
	FROM dbo.fn_CIC_NUMToExtraCheckList_rst(@FieldName, @NUM, @LangID) exc

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END






GO

GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToExtraCheckList_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToExtraCheckList_Web] TO [cioc_login_role]
GO
