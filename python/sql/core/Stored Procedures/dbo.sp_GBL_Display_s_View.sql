SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Display_s_View]
	@ViewType int,
	@Domain tinyint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @DD_ID int

SELECT @DD_ID = DD_ID
	FROM GBL_Display
WHERE @ViewType = CASE WHEN @Domain=1 THEN ViewTypeCIC ELSE ViewTypeVOL END

SELECT *
	FROM GBL_Display
WHERE DD_ID=@DD_ID

IF @Domain = 1 BEGIN
	SELECT FieldID
		FROM GBL_Display_Fld
	WHERE DD_ID=@DD_ID
END ELSE BEGIN
	SELECT FieldID
		FROM VOL_Display_Fld
	WHERE DD_ID=@DD_ID
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Display_s_View] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Display_s_View] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_Display_s_View] TO [cioc_vol_search_role]
GO
