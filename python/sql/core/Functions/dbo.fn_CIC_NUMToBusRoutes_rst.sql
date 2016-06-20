SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToBusRoutes_rst](
	@NUM varchar(8)
)
RETURNS @BusRoutes TABLE (
	[BR_ID] int NULL,
	[RouteNumber] varchar(20) COLLATE Latin1_General_100_CI_AI NULL,
	[RouteName] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 10-Jun-2014
	Action: NO ACTION REQUIRED
*/

INSERT INTO @BusRoutes
SELECT br.BR_ID, br.RouteNumber, brn.Name As RouteName
	FROM CIC_BT_BR pr
	INNER JOIN CIC_BusRoute br
		ON pr.BR_ID = br.BR_ID
	LEFT JOIN CIC_BusRoute_Name brn
		ON br.BR_ID=brn.BR_ID AND brn.LangID=@@LANGID
WHERE NUM = @NUM
ORDER BY DisplayOrder, br.RouteNumber, brn.Name

RETURN

END

GO
