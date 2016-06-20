SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_DisplayFullOrgName_Agency_2](
	@NUM varchar(8),
	@ORG_LEVEL_1 nvarchar(200),
	@ORG_LEVEL_2 nvarchar(200),
	@ORG_LEVEL_3 nvarchar(200),
	@ORG_LEVEL_4 nvarchar(200),
	@ORG_LEVEL_5 nvarchar(200),
	@LOCATION_NAME nvarchar(200),
	@SERVICE_NAME_LEVEL_1 nvarchar(200),
	@SERVICE_NAME_LEVEL_2 nvarchar(200)
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
SET @OrgName = ISNULL(
			STUFF(
				COALESCE(@ORG_LEVEL_1,'') +
				COALESCE(', ' + @ORG_LEVEL_2,'') +
				COALESCE(', ' + @ORG_LEVEL_3,'') +
				COALESCE(', ' + @ORG_LEVEL_4,'') +
				COALESCE(', ' + @ORG_LEVEL_5,'') +
				CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code='AGENCY' WHERE pr.NUM=@NUM)
					THEN ''
					ELSE CASE WHEN EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code IN ('SERVICE','TOPIC') WHERE pr.NUM=@NUM)
						THEN '' ELSE COALESCE(', ' + @LOCATION_NAME,'') END +
						COALESCE(', ' + @SERVICE_NAME_LEVEL_1,'') +
						COALESCE(', ' + @SERVICE_NAME_LEVEL_2,'')
					END,
				1, 0, ''
			)
			,'(' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ')'
		)

RETURN @OrgName

END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_Agency_2] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_Agency_2] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_Agency_2] TO [cioc_vol_search_role]
GO
