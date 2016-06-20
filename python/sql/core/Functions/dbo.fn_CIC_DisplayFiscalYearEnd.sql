SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_DisplayFiscalYearEnd](
	@FYE_ID int,
	@LangID smallint
)
RETURNS nvarchar(200) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@FiscalYearEnd	nvarchar(200)

SELECT @FiscalYearEnd = fyen.Name
	FROM CIC_FiscalYearEnd fye
	INNER JOIN CIC_FiscalYearEnd_Name fyen
		ON fye.FYE_ID=fyen.FYE_ID AND LangID=@LangID
WHERE fye.FYE_ID=@FYE_ID

IF @FiscalYearEnd = '' SET @FiscalYearEnd = NULL

RETURN @FiscalYearEnd

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayFiscalYearEnd] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayFiscalYearEnd] TO [cioc_login_role]
GO
