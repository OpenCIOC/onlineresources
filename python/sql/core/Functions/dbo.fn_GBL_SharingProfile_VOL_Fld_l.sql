SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fn_GBL_SharingProfile_VOL_Fld_l](
	@MemberID int,
	@ViewType int,
	@FieldID int
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	varchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ',','') + CAST(shp.ProfileID AS varchar)
	FROM GBL_SharingProfile shp
	INNER JOIN GBL_SharingProfile_VOL_Fld shpf
		ON shp.ProfileID=shpf.ProfileID
	INNER JOIN GBL_FieldOption fo
		ON shpf.FieldID=fo.FieldID AND fo.CanShare=1 AND fo.FieldID=@FieldID
WHERE shp.ShareMemberID=@MemberID
	AND shp.Active=1
	AND (shp.CanUseAnyView=1 OR EXISTS(SELECT * FROM GBL_SharingProfile_VOL_View shpv WHERE shpv.ProfileID=shp.ProfileID AND shpv.ViewType=@ViewType))

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_SharingProfile_VOL_Fld_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_SharingProfile_VOL_Fld_l] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_SharingProfile_VOL_Fld_l] TO [cioc_vol_search_role]
GO
