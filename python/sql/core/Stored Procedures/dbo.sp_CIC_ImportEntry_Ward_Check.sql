SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Ward_Check]
	@WardNumber smallint,
	@MunicipalityEn nvarchar(200),
	@MunicipalityFr nvarchar(200),
	@ProvState nvarchar(100),
	@Country nvarchar(100),
	@WD_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 05-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @CM_ID int

SELECT TOP 1 @CM_ID = CM_ID
	FROM GBL_Community_Name cm
	LEFT JOIN GBL_ProvinceState pst
		ON cm.ProvinceStateCache=pst.ProvID
WHERE [Name] IN (@MunicipalityEn,@MunicipalityFr)
ORDER BY CASE
		WHEN [Name]=@MunicipalityEn AND LangID=0 THEN 0
		WHEN [Name]=@MunicipalityFr AND LangID=2 THEN 1
		ELSE 2
	END,
	CASE
		WHEN pst.NameOrCode=@ProvState AND pst.Country=@Country THEN 0
		WHEN @ProvState IS NULL AND @Country IS NULL AND pst.ProvID IS NULL THEN 1
		WHEN pst.Country=@Country THEN 2
		WHEN pst.NameOrCode=@ProvState THEN 3
		ELSE 4
	END

SELECT @WD_ID = WD_ID
	FROM CIC_Ward
WHERE WardNumber=@WardNumber
	AND ((Municipality IS NULL AND @CM_ID IS NULL) OR Municipality=@CM_ID)

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Ward_Check] TO [cioc_login_role]
GO
