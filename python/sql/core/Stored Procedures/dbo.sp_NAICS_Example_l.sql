SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_NAICS_Example_l]
	@Code [varchar](6),
	@AllLangs bit = 1
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action: NO ACTION REQUIRED
*/

SELECT Description
	FROM NAICS_Example
WHERE Code=@Code AND (@AllLangs=1 OR LangID=@@LANGID)

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_NAICS_Example_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_NAICS_Example_l] TO [cioc_login_role]
GO
