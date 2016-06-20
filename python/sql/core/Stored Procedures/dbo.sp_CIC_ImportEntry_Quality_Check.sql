SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Quality_Check]
	@Quality char(1),
	@RQ_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT @RQ_ID = RQ_ID
	FROM CIC_Quality
WHERE Quality=@Quality

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Quality_Check] TO [cioc_login_role]
GO
