SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_DisplayLocationName](
	@NUM varchar(8),
	@LangID smallint
)
RETURNS nvarchar(1500) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 16-Jul-2015
	Action: NO ACTION REQUIRED
*/

DECLARE @OrgName nvarchar(1500)
SELECT @OrgName = ISNULL(btd.LOCATION_NAME,
			ISNULL(
				STUFF(
					COALESCE(btd.ORG_LEVEL_1,'') +
					COALESCE(', ' + btd.ORG_LEVEL_2,'') +
					COALESCE(', ' + btd.ORG_LEVEL_3,'') +
					COALESCE(', ' + btd.ORG_LEVEL_4,'') +
					COALESCE(', ' + btd.ORG_LEVEL_5,''),
					1, 0, ''
				)
				,'(' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ')'
			)
		)
	FROM GBL_BaseTable_Description btd
WHERE btd.NUM=@NUM
	AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)

RETURN @OrgName

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayLocationName] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayLocationName] TO [cioc_login_role]
GO
