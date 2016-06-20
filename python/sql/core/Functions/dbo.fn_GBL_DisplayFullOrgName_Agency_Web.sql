SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GBL_DisplayFullOrgName_Agency_Web](
	@NUM varchar(8),
	@LangID smallint,
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
	Checked on: 01-Oct-2013
	Action: NO ACTION REQUIRED
*/



DECLARE @ParentOrgName nvarchar(1000)
SELECT @ParentOrgName = dbo.fn_GBL_DisplayFullOrgName_Agency(@NUM,@LangID)

RETURN CASE
	WHEN dbo.fn_CIC_RecordInView(@NUM,@ViewType,@@LANGID,0,GETDATE())=1
	THEN cioc_shared.dbo.fn_SHR_GBL_Link_Record(@NUM,@ParentOrgName,@HTTPVals,@PathToStart)
	ELSE @ParentOrgName END
END




GO
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_Agency_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_Agency_Web] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_DisplayFullOrgName_Agency_Web] TO [cioc_vol_search_role]
GO
