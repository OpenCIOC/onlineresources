SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_FullStreetDir](
	@StreetType nvarchar(20),
	@StreetDir char(1)
)
RETURNS nvarchar(20) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Jan-2012
	Action: NO ACTION REQUIRED
	Notes: Should this accept a @LangID Parameter?
*/

DECLARE	@StreetTypeLangID smallint,
		@returnStr nvarchar(20)

SET @StreetTypeLangID = @@LANGID

SELECT TOP 1 @StreetTypeLangID = LangID FROM GBL_StreetType
	WHERE StreetType=@StreetType
ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID

IF @StreetDir IS NOT NULL BEGIN
	SELECT @StreetDir = ISNULL(sdn.Name,sd.Dir)
		FROM GBL_StreetDir sd
		INNER JOIN GBL_StreetDir_Name sdn
			ON sd.Dir=sdn.Dir AND LangID=@StreetTypeLangID
	WHERE sd.Dir=@StreetDir
END

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_FullStreetDir] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullStreetDir] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullStreetDir] TO [cioc_vol_search_role]
GO
