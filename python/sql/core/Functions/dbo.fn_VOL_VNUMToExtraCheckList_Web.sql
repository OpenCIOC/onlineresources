SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_VOL_VNUMToExtraCheckList_Web](
	@FieldName varchar(100),
	@VNUM varchar(10),
	@LangID smallint,
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS nvarchar(MAX) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6.2
	Checked by: KL
	Checked on: 17-Feb-2015
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
	FROM dbo.fn_VOL_VNUMToExtraCheckList_rst(@FieldName, @VNUM, @LangID) exc

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToExtraCheckList_Web] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToExtraCheckList_Web] TO [cioc_vol_search_role]
GO
