SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_VOL_DisplayMinHoursPer](
	@HPER_ID [int],
	@LangID [smallint]
)
RETURNS [nvarchar](200) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 05-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@MinHoursPer	nvarchar(200)

SELECT @MinHoursPer = hpern.Name
	FROM VOL_MinHoursPer_Name hpern
WHERE hpern.HPER_ID=@HPER_ID AND LangID=@LangID

IF @MinHoursPer = '' SET @MinHoursPer = NULL

RETURN @MinHoursPer

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_DisplayMinHoursPer] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_VOL_DisplayMinHoursPer] TO [cioc_vol_search_role]
GO
