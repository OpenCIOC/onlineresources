SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMToMappingSystem](
	@NUM varchar(8)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + mapn.Label
	FROM GBL_BT_MAP pr
	INNER JOIN GBL_MappingSystem map
		ON pr.MAP_ID = map.MAP_ID
	INNER JOIN GBL_MappingSystem_Name mapn
		ON map.MAP_ID=mapn.MAP_ID AND LangID=@@LANGID
WHERE NUM = @NUM
ORDER BY mapn.Label

IF @returnStr = '' SET @returnStr = NULL

IF @returnStr IS NULL SET @returnStr = cioc_shared.dbo.fn_SHR_STP_ObjectName('Do Not Map')

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToMappingSystem] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToMappingSystem] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToMappingSystem] TO [cioc_vol_search_role]
GO
