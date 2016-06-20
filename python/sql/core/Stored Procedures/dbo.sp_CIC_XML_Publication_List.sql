SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_XML_Publication_List]
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

SELECT (SELECT (SELECT PubCode AS '@V'
			FROM CIC_Publication pb
			INNER JOIN CIC_ExportProfile_Pub ep
				ON pb.PB_ID = ep.PB_ID
		WHERE ep.ProfileID = @ProfileID
		FOR XML PATH('CD'), TYPE
		)
	FOR XML PATH('PUB_CODE_LIST')
	) AS PUB_CODE_LIST

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_XML_Publication_List] TO [cioc_login_role]
GO
