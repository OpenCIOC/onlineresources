SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMVacancy_d]
	@BT_VUT_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

DELETE FROM CIC_BT_VUT WHERE BT_VUT_ID = @BT_VUT_ID

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMVacancy_d] TO [cioc_login_role]
GO
