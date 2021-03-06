SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Feedback_u_NUM]
	@FB_ID int,
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 06-Jan-2012
	Action: NO ACTION REQUIRED
*/

IF EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.NUM=@NUM) BEGIN
	UPDATE GBL_FeedbackEntry
		SET NUM=@NUM
	WHERE @FB_ID=FB_ID
		AND NUM IS NULL
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Feedback_u_NUM] TO [cioc_login_role]
GO
