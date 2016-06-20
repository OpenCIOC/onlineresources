SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_FiscalYearEnd_Check]
	@FiscalYearEndEn nvarchar(200),
	@FiscalYearEndFr nvarchar(200),
	@FYE_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT @FYE_ID = FYE_ID
	FROM CIC_FiscalYearEnd_Name
WHERE [Name]=@FiscalYearEndEn OR [Name]=@FiscalYearEndFr
	ORDER BY CASE
		WHEN [Name]=@FiscalYearEndEn AND LangID=0 THEN 0
		WHEN [Name]=@FiscalYearEndFr AND LangID=2 THEN 1
		ELSE 2
	END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_FiscalYearEnd_Check] TO [cioc_login_role]
GO
