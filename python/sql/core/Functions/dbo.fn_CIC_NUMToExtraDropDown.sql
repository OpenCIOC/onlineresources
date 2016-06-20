SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_CIC_NUMToExtraDropDown](
	@FieldName varchar(100),
	@NUM varchar(8),
	@LangID smallint
)
RETURNS nvarchar(200) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 26-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@ExtraDropDown	nvarchar(200)

SELECT @ExtraDropDown = ISNULL(Name,Code)
	FROM CIC_ExtraDropDown exd
	LEFT JOIN CIC_ExtraDropDown_Name exdn
		ON exd.EXD_ID=exdn.EXD_ID AND LangID=@LangID
	INNER JOIN dbo.CIC_BT_EXD pr
		ON pr.EXD_ID = exd.EXD_ID AND NUM=@NUM
WHERE FieldName=@FieldName

IF @ExtraDropDown = '' SET @ExtraDropDown = NULL

RETURN @ExtraDropDown

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToExtraDropDown] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToExtraDropDown] TO [cioc_login_role]
GO
