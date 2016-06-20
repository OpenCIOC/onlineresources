SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_ServiceLevel_i]
	@NUM varchar(8),
	@ServiceLevelCode tinyint,
	@SL_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT @SL_ID = SL_ID
	FROM CIC_ServiceLevel
WHERE	ServiceLevelCode=@ServiceLevelCode

IF @SL_ID IS NOT NULL BEGIN
	EXEC sp_CIC_ImportEntry_CIC_Check_i @NUM

	INSERT INTO CIC_BT_SL (
		NUM,
		SL_ID
	)
	SELECT	NUM,
			@SL_ID
		FROM GBL_BaseTable
	WHERE NUM=@NUM
		AND NOT EXISTS(SELECT * FROM CIC_BT_SL WHERE NUM=@NUM AND SL_ID=@SL_ID)
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_ServiceLevel_i] TO [cioc_login_role]
GO
