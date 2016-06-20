
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_DisplayFullOrgName_2](
	@NUM varchar(8),
	@ORG_LEVEL_1 nvarchar(200),
	@ORG_LEVEL_2 nvarchar(200),
	@ORG_LEVEL_3 nvarchar(200),
	@ORG_LEVEL_4 nvarchar(200),
	@ORG_LEVEL_5 nvarchar(200),
	@LOCATION_NAME nvarchar(200),
	@SERVICE_NAME_LEVEL_1 nvarchar(200),
	@SERVICE_NAME_LEVEL_2 nvarchar(200),
	@DISPLAY_LOCATION_NAME bit,
	@DISPLAY_ORG_NAME bit
)
RETURNS nvarchar(1500) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6.1
	Checked by: CL
	Checked on: 31-Oct-2014
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
				CASE WHEN @LOCATION_NAME=@ORG_LEVEL_1 OR (@DISPLAY_LOCATION_NAME=0 AND (@SERVICE_NAME_LEVEL_1 IS NOT NULL OR @DISPLAY_ORG_NAME=0)) THEN ''
					ELSE COALESCE(', ' + @LOCATION_NAME,'') END +
				CASE WHEN @SERVICE_NAME_LEVEL_1=@ORG_LEVEL_1
						OR @LOCATION_NAME=@SERVICE_NAME_LEVEL_1 THEN ''
					ELSE COALESCE(', ' + @SERVICE_NAME_LEVEL_1,'') END +
				CASE WHEN @SERVICE_NAME_LEVEL_2=@ORG_LEVEL_1
						OR @LOCATION_NAME=@SERVICE_NAME_LEVEL_2 THEN ''
					ELSE COALESCE(', ' + @SERVICE_NAME_LEVEL_2,'') END,
				1, 0, ''
			)
			,'(' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ')'
		)

RETURN @OrgName

END


GO

GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_2] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_2] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_2] TO [cioc_vol_search_role]
GO
