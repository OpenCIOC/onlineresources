SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMBusRoute_s]
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 10-Jun-2014
	Action: NO ACTION REQUIRED
*/

SELECT br.BR_ID, br.RouteNumber, brn.Name AS RouteName, ISNULL(cmn.Display,cmn.Name) AS Municipality 
	FROM CIC_BusRoute br
	LEFT JOIN CIC_BusRoute_Name brn
		ON br.BR_ID=brn.BR_ID
			AND brn.LangID=(SELECT TOP 1 LangID FROM CIC_BusRoute_Name WHERE BR_ID=br.BR_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN CIC_BT_BR pr
		ON br.BR_ID = pr.BR_ID AND pr.NUM=@NUM
	LEFT JOIN GBL_Community_Name cmn
		ON br.Municipality = cmn.CM_ID
			AND cmn.LangID = (SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
ORDER BY br.DisplayOrder, br.RouteNumber, brn.Name

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMBusRoute_s] TO [cioc_login_role]
GO
