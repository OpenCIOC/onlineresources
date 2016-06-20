SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_XML_Distribution_List]
	@ProfileID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 26-Jan-2012
	Action: NO ACTION REQUIRED
*/

SELECT (SELECT (SELECT DistCode AS '@V'
			FROM CIC_Distribution dst
			INNER JOIN CIC_ExportProfile_Dist ed
				ON dst.DST_ID = ed.DST_ID
		WHERE ed.ProfileID = @ProfileID
		FOR XML PATH('CD'), TYPE
		)
	FOR XML PATH('DIST_CODE_LIST')
	) AS DIST_CODE_LIST

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_XML_Distribution_List] TO [cioc_login_role]
GO
