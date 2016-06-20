SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_XML_Distribution]
	@NUM varchar(8),
	@ProfileID int,
	@DistList varchar(max) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 26-Jan-2012
	Action: NO ACTION REQUIRED
*/

SET @DistList =  (SELECT
		(SELECT DistCode AS '@V'
			FROM CIC_BT_DST pr
			INNER JOIN CIC_Distribution dst
				ON pr.DST_ID = dst.DST_ID
			INNER JOIN CIC_ExportProfile_Dist ed
				ON dst.DST_ID = ed.DST_ID
			WHERE pr.NUM = @NUM
				AND ed.ProfileID = @ProfileID
			FOR XML PATH('CD'), TYPE)
	FOR XML PATH('DISTRIBUTION'))

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_XML_Distribution] TO [cioc_login_role]
GO
