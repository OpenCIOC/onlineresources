SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_PrivacyProfile_Fld_l](
	@FieldID int
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 02-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	varchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ',','') + CAST(ProfileID AS varchar)
	FROM GBL_PrivacyProfile_Fld pfld
	INNER JOIN GBL_FieldOption fo
		ON pfld.FieldID=fo.FieldID AND fo.CanUsePrivacy=1 AND fo.FieldID=@FieldID

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END



GO
GRANT EXECUTE ON  [dbo].[fn_GBL_PrivacyProfile_Fld_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_PrivacyProfile_Fld_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_PrivacyProfile_Fld_l] TO [cioc_vol_search_role]
GO
