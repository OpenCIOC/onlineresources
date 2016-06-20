SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_NAICS_FullExclusionUseCodes](
	@Exclusion_ID int
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + UseCode
	FROM NAICS_Exclusion_Use
WHERE Exclusion_ID=@Exclusion_ID
ORDER BY UseCode

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_NAICS_FullExclusionUseCodes] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_NAICS_FullExclusionUseCodes] TO [cioc_login_role]
GO
