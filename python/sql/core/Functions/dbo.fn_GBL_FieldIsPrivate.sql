SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_FieldIsPrivate](
	@ProfileID int,
	@FieldName varchar(100)
)
RETURNS bit WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

RETURN CASE
		WHEN @ProfileID IS NULL THEN 0
		WHEN EXISTS(SELECT * FROM GBL_PrivacyProfile_Fld pf
			INNER JOIN GBL_FieldOption fo ON pf.FieldID=fo.FieldID
			WHERE pf.ProfileID=@ProfileID AND fo.FieldName=@FieldName)
		THEN 1
		ELSE 0
	END
END

GO
GRANT EXECUTE ON  [dbo].[fn_GBL_FieldIsPrivate] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FieldIsPrivate] TO [cioc_login_role]
GO
