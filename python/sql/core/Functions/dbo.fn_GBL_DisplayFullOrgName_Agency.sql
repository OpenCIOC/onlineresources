SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_DisplayFullOrgName_Agency](
	@NUM varchar(8),
	@LangID smallint
)
RETURNS nvarchar(1500) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 06-Oct-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @OrgName nvarchar(1500)
SELECT @OrgName = ISNULL(
			STUFF(
				COALESCE(btd.ORG_LEVEL_1,'') +
				COALESCE(', ' + btd.ORG_LEVEL_2,'') +
				COALESCE(', ' + btd.ORG_LEVEL_3,'') +
				COALESCE(', ' + btd.ORG_LEVEL_4,'') +
				COALESCE(', ' + btd.ORG_LEVEL_5,'') +
				CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code='AGENCY' WHERE pr.NUM=@NUM)
					THEN ''
					ELSE CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('SERVICE','TOPIC') WHERE pr.NUM=@NUM)
						THEN '' ELSE COALESCE(', ' + btd.LOCATION_NAME,'') END +
						COALESCE(', ' + btd.SERVICE_NAME_LEVEL_1,'') +
						COALESCE(', ' + btd.SERVICE_NAME_LEVEL_2,'')
					END,
				1, 0, ''
			)
			,'(' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ')'
		)
	FROM GBL_BaseTable_Description btd
WHERE btd.NUM=@NUM
	AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)

RETURN @OrgName

END




GO
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_Agency] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_Agency] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_Agency] TO [cioc_vol_search_role]
GO
