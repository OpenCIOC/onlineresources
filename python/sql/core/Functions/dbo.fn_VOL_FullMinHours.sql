SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_FullMinHours](
	@MinHours [float],
	@MinHoursPer [int]
)
RETURNS [nvarchar](100) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 05-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @returnStr nvarchar(100)

DECLARE @MinHoursPerStr nvarchar(30)

SELECT @MinHoursPerStr = [Name]
	FROM VOL_MinHoursPer_Name hper
WHERE HPER_ID = @MinHoursPer
	AND LangID=(SELECT TOP 1 LangID FROM VOL_MinHoursPer_Name WHERE HPER_ID=hper.HPER_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)


IF @MinHours IS NOT NULL BEGIN
	SET @returnStr = cioc_shared.dbo.fn_SHR_GBL_FloatString(@MinHours)
	IF @MinHoursPerStr IS NOT NULL BEGIN
		IF @MinHoursPerStr = cioc_shared.dbo.fn_SHR_STP_ObjectName('Total')
			SET @returnStr = @returnStr + cioc_shared.dbo.fn_SHR_STP_ObjectName(' (') + @MinHoursPerStr + cioc_shared.dbo.fn_SHR_STP_ObjectName(')')
		ELSE
			SET @returnStr = @returnStr + cioc_shared.dbo.fn_SHR_STP_ObjectName(' / ') + @MinHoursPerStr
	END
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_FullMinHours] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_FullMinHours] TO [cioc_vol_search_role]
GO
