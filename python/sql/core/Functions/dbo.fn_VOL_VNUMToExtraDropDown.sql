SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_VOL_VNUMToExtraDropDown](
	@FieldName varchar(100),
	@VNUM varchar(10),
	@LangID smallint
)
RETURNS nvarchar(200) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.6.2
	Checked by: KL
	Checked on: 17-Feb-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@ExtraDropDown	nvarchar(200)

SELECT @ExtraDropDown = ISNULL(Name,Code)
	FROM VOL_ExtraDropDown exd
	LEFT JOIN VOL_ExtraDropDown_Name exdn
		ON exd.EXD_ID=exdn.EXD_ID AND LangID=@LangID
	INNER JOIN dbo.VOL_OP_EXD pr
		ON pr.EXD_ID = exd.EXD_ID AND VNUM=@VNUM
WHERE FieldName=@FieldName

IF @ExtraDropDown = '' SET @ExtraDropDown = NULL

RETURN @ExtraDropDown

END



GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToExtraDropDown] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToExtraDropDown] TO [cioc_vol_search_role]
GO
