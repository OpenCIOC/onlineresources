SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Display_s_User]
	@User_ID int,
	@Domain tinyint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @DD_ID int
SELECT @DD_ID = DD_ID
	FROM GBL_Display
WHERE [User_ID]=@User_ID AND [Domain]=@Domain

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
GRANT EXECUTE ON  [dbo].[sp_GBL_Display_s_User] TO [cioc_login_role]
GO
