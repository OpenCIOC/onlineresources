SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [dbo].[fn_VOL_DisplayExtraDropDown](
	@EXD_ID int,
	@FieldName varchar(100),
	@LangID smallint
)
RETURNS nvarchar(200) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 25-Feb-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@ExtraDropDown	nvarchar(200)

SELECT @ExtraDropDown = ISNULL(Name,Code)
	FROM VOL_ExtraDropDown exd
	LEFT JOIN VOL_ExtraDropDown_Name exdn
		ON exd.EXD_ID=exdn.EXD_ID AND LangID=@LangID
WHERE FieldName=@FieldName
	AND exd.EXD_ID=@EXD_ID

IF @ExtraDropDown = '' SET @ExtraDropDown = NULL

RETURN @ExtraDropDown

END


GO
GRANT EXECUTE ON  [dbo].[fn_VOL_DisplayExtraDropDown] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_DisplayExtraDropDown] TO [cioc_vol_search_role]
GO
