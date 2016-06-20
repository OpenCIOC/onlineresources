SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_BusRoutes_i]
	@NUM varchar(8),
	@RouteNumber varchar(20),
	@RouteNameEn nvarchar(200),
	@RouteNameFr nvarchar(200),
	@MunicipalityEn nvarchar(200),
	@MunicipalityFr nvarchar(200),
	@BR_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 10-Jun-2014
	Action: NO ACTION REQUIRED
*/

DECLARE @BT_BR_ID int,
		@CM_ID int

SELECT TOP 1 @CM_ID = CM_ID
	FROM GBL_Community_Name
WHERE [Name]=@MunicipalityEn OR [Name]=@MunicipalityFr
	ORDER BY CASE
		WHEN [Name]=@MunicipalityEn AND LangID=0 THEN 0
		WHEN [Name]=@MunicipalityFr AND LangID=2 THEN 1
		ELSE 2
	END

SELECT TOP 1 @BR_ID = BR_ID
	FROM CIC_BusRoute br
WHERE	(
			RouteNumber=@RouteNumber
			OR (RouteNumber IS NULL AND @RouteNumber IS NULL AND (@RouteNameEn IS NOT NULL OR @RouteNameFr IS NOT NULL))
		)
		AND (
			Municipality=@CM_ID
			OR (Municipality IS NULL AND @CM_ID IS NULL)
		)
		AND (@RouteNameEn IS NULL OR EXISTS(SELECT * FROM CIC_BusRoute_Name WHERE BR_ID=br.BR_ID AND [Name]=@RouteNameEn AND LangID=0))
		AND (@RouteNameFr IS NULL OR EXISTS(SELECT * FROM CIC_BusRoute_Name WHERE BR_ID=br.BR_ID AND [Name]=@RouteNameFr AND LangID IN (0,2)))

IF @BR_ID IS NOT NULL BEGIN
	EXEC sp_CIC_ImportEntry_CIC_Check_i @NUM

	INSERT INTO CIC_BT_BR (
		NUM,
		BR_ID
	)
	SELECT NUM, @BR_ID
		FROM GBL_BaseTable
	WHERE NUM=@NUM
		AND NOT EXISTS(SELECT * FROM CIC_BT_BR WHERE NUM=@NUM AND BR_ID=@BR_ID)
	
END

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_BusRoutes_i] TO [cioc_login_role]
GO
