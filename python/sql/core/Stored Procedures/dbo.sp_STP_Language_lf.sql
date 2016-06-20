SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_Language_lf]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action: NO ACTION REQUIRED
*/

SELECT *
	FROM STP_Language
ORDER BY LanguageName

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_STP_Language_lf] TO [cioc_login_role]
GO
