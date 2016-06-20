SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_VOL_VNUMToExtraCheckList](
	@FieldName varchar(100),
	@VNUM varchar(10),
	@LangID smallint
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

DECLARE	@returnStr	nvarchar(MAX)

SELECT @returnStr =  COALESCE(@returnStr + ' ; ','') + exc.ExtraCheckList
	FROM dbo.fn_VOL_VNUMToExtraCheckList_rst(@FieldName, @VNUM, @LangID) exc

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToExtraCheckList] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_VNUMToExtraCheckList] TO [cioc_vol_search_role]
GO
