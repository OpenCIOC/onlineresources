SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_AIRS_Export_ICarolSource] 
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked by: CL
	Checked on: 01-Dec-2019
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

SELECT NUM AS RECORD_NUM FROM CIC_BaseTable WHERE SOURCE_FROM_ICAROL=1

RETURN @Error

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_GBL_AIRS_Export_ICarolSource] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_GBL_AIRS_Export_ICarolSource] TO [cioc_login_role]
GO
