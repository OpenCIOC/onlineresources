SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_CIC_DisplayExtraDropDown](
	@EXD_ID int,
	@FieldName varchar(100),
	@LangID smallint
)
RETURNS nvarchar(200) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 28-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@ExtraDropDown	nvarchar(200)

SELECT @ExtraDropDown = ISNULL(Name,Code)
	FROM CIC_ExtraDropDown exd
	LEFT JOIN CIC_ExtraDropDown_Name exdn
		ON exd.EXD_ID=exdn.EXD_ID AND LangID=@LangID
WHERE FieldName=@FieldName
	AND exd.EXD_ID=@EXD_ID

IF @ExtraDropDown = '' SET @ExtraDropDown = NULL

RETURN @ExtraDropDown

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayExtraDropDown] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayExtraDropDown] TO [cioc_login_role]
GO
