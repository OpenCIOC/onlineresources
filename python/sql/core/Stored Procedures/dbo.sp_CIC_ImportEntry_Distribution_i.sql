SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Distribution_i]
	@NUM varchar(8),
	@Code varchar(20),
	@DST_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT @DST_ID = DST_ID
	FROM CIC_ImportEntry_Dist
WHERE Code=@Code

IF @DST_ID IS NOT NULL BEGIN
	EXEC dbo.sp_CIC_ImportEntry_CIC_Check_i @NUM
	INSERT INTO CIC_BT_DST (
		NUM,
		DST_ID
	)
	SELECT	NUM,
			@DST_ID
		FROM GBL_BaseTable
	WHERE NUM=@NUM
		AND NOT EXISTS(SELECT * FROM CIC_BT_DST WHERE NUM=@NUM AND DST_ID=@DST_ID)
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Distribution_i] TO [cioc_login_role]
GO
