
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_CIC_NUMToExtraDropDown_Web](
	@FieldName varchar(100),
	@NUM varchar(8),
	@LangID smallint,
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS nvarchar(1000) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 26-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE @ExtraFieldName varchar(25)
SET @ExtraFieldName = REPLACE(@FieldName,'EXTRA_DROPDOWN_','')

IF @HTTPVals = '' SET @HTTPVals = NULL

DECLARE	@ExtraDropDown	nvarchar(200)

SELECT @ExtraDropDown = '<a href="' + @PathToStart + 'results.asp?EXD' + @ExtraFieldName + 'ID=' + CAST(exd.EXD_ID AS varchar)
		+ '&EXD=' + @ExtraFieldName
		+ CASE WHEN @HTTPVals IS NOT NULL THEN '&' + @HTTPVals ELSE '' END + '">' + ISNULL(Name,Code) + '</a>'
	FROM CIC_ExtraDropDown exd
	LEFT JOIN CIC_ExtraDropDown_Name exdn
		ON exd.EXD_ID=exdn.EXD_ID AND LangID=@LangID
	INNER JOIN dbo.CIC_BT_EXD pr
		ON pr.EXD_ID = exd.EXD_ID AND NUM=@NUM
WHERE FieldName=@FieldName

RETURN @ExtraDropDown

END


GO

GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToExtraDropDown_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToExtraDropDown_Web] TO [cioc_login_role]
GO
