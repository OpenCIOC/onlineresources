SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_DisplayServiceName](
	@NUM varchar(8),
	@LangID smallint,
	@IncludeOrg bit
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
SELECT @OrgName = CASE WHEN @IncludeOrg=0
		THEN ISNULL(STUFF(
				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
				COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,''),
				1, 2, ''
			), ISNULL(
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
		ELSE ISNULL(
			STUFF(
				COALESCE(', ' + btd.ORG_LEVEL_1,'') +
				COALESCE(', ' + btd.ORG_LEVEL_2,'') +
				COALESCE(', ' + btd.ORG_LEVEL_3,'') +
				COALESCE(', ' + btd.ORG_LEVEL_4,'') +
				COALESCE(', ' + btd.ORG_LEVEL_5,'') +
				CASE WHEN btd.SERVICE_NAME_LEVEL_1=btd.ORG_LEVEL_1
						OR btd.LOCATION_NAME=btd.SERVICE_NAME_LEVEL_1 THEN ''
					ELSE COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') END +
				CASE WHEN btd.SERVICE_NAME_LEVEL_2=btd.ORG_LEVEL_1
						OR btd.LOCATION_NAME=btd.SERVICE_NAME_LEVEL_2 THEN ''
					ELSE COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'') END,
				1, 2, ''
			)
			,'(' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ')'
		)
		END
	FROM GBL_BaseTable_Description btd
WHERE btd.NUM=@NUM
	AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)

RETURN @OrgName

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayServiceName] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayServiceName] TO [cioc_login_role]
GO
