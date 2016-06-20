SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_FullWard](
	@WD_ID smallint
)
RETURNS nvarchar(600) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@WardNumber int,
		@WardName nvarchar(255),
		@Municipality nvarchar(255),
		@returnStr nvarchar(600)

SET @returnStr = ''

IF @WD_ID IS NOT NULL BEGIN
	SELECT	@WardNumber = wd.WardNumber,
			@WardName = wdn.Name,
			@Municipality = dbo.fn_GBL_DisplayCommunity(Municipality,@@LANGID)
		FROM CIC_Ward wd
		LEFT JOIN CIC_Ward_Name wdn
			ON wd.WD_ID=wdn.WD_ID AND wdn.LangID=@@LANGID
	WHERE wd.WD_ID = @WD_ID

	SET @returnStr = CASE WHEN @Municipality IS NOT NULL THEN @Municipality + ' ' ELSE '' END
		+ cioc_shared.dbo.fn_SHR_STP_ObjectName('Ward') + ' ' + CAST(@WardNumber AS varchar)

	IF @WardName IS NOT NULL BEGIN
		SET @returnStr = @WardName + ' ('+ @returnStr + ')'
	END
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_FullWard] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_FullWard] TO [cioc_login_role]
GO
