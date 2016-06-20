SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_DisplayFullOrgName_Agency_2_Web](
	@NUM varchar(8),
	@ORG_LEVEL_1 nvarchar(200),
	@ORG_LEVEL_2 nvarchar(200),
	@ORG_LEVEL_3 nvarchar(200),
	@ORG_LEVEL_4 nvarchar(200),
	@ORG_LEVEL_5 nvarchar(200),
	@LOCATION_NAME nvarchar(200),
	@SERVICE_NAME_LEVEL_1 nvarchar(200),
	@SERVICE_NAME_LEVEL_2 nvarchar(200),
	@ViewType int,
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS nvarchar(2000) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 02-Oct-2013
	Action: NO ACTION REQUIRED
*/



DECLARE @ParentOrgName nvarchar(1000)
SELECT @ParentOrgName = dbo.fn_GBL_DisplayFullOrgName_Agency_2(@NUM,@ORG_LEVEL_1,@ORG_LEVEL_2,@ORG_LEVEL_3,@ORG_LEVEL_4,@ORG_LEVEL_5,@LOCATION_NAME,@SERVICE_NAME_LEVEL_1,@SERVICE_NAME_LEVEL_2)

RETURN CASE
	WHEN dbo.fn_CIC_RecordInView(@NUM,@ViewType,@@LANGID,0,GETDATE())=1
	THEN cioc_shared.dbo.fn_SHR_GBL_Link_Record(@NUM,@ParentOrgName,@HTTPVals,@PathToStart)
	ELSE @ParentOrgName END
END




GO
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_Agency_2_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_Agency_2_Web] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_Agency_2_Web] TO [cioc_vol_search_role]
GO
