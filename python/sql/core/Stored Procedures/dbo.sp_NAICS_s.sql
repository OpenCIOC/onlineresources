SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_NAICS_s]
	@Code [varchar](6)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action: NO ACTION REQUIRED
*/

SELECT nc.*, (SELECT COUNT(*) FROM CIC_BT_NC WHERE Code=@Code) AS UsageCount
	FROM NAICS  nc
WHERE nc.Code = @Code

SELECT ncd.*, (SELECT Culture FROM STP_Language ln WHERE ln.LangID=ncd.LangID) AS Culture
	FROM NAICS_Description ncd
WHERE ncd.Code=@Code

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_NAICS_s] TO [cioc_login_role]
GO
