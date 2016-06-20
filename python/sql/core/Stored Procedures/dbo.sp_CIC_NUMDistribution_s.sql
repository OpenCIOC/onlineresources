SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMDistribution_s]
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 19-Oct-2012
	Action: NO ACTION REQUIRED
*/

SELECT dst.DST_ID, dst.DistCode, dstn.Name AS DistName
	FROM CIC_Distribution dst
	INNER JOIN CIC_BT_DST pr
		ON dst.DST_ID = pr.DST_ID
	LEFT JOIN CIC_Distribution_Name dstn
		ON dst.DST_ID=dstn.DST_ID AND LangID=@@LANGID
WHERE NUM = @NUM
ORDER BY dst.DistCode

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMDistribution_s] TO [cioc_login_role]
GO
