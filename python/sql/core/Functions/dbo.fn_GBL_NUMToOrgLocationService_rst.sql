SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GBL_NUMToOrgLocationService_rst](
	@NUM varchar(8)
)
RETURNS @OrgLocationService TABLE (
	[OLS_ID] int NULL,
	[OrgLocationService] nvarchar(100) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 20-Jan-2013
	Action: NO ACTION REQUIRED
*/

INSERT INTO @OrgLocationService
SELECT ols.OLS_ID, ISNULL(olsn.Name,ols.Code)
	FROM GBL_BT_OLS pr
	INNER JOIN GBL_OrgLocationService ols
		ON pr.OLS_ID=ols.OLS_ID
	LEFT JOIN GBL_OrgLocationService_Name olsn
		ON ols.OLS_ID=olsn.OLS_ID AND LangID=@@LANGID
WHERE NUM=@NUM
ORDER BY ols.DisplayOrder, olsn.Name

RETURN

END

GO
