SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Accreditation_Check]
	@AccreditationEn nvarchar(200),
	@AccreditationFr nvarchar(200),
	@ACR_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT TOP 1 @ACR_ID = ACR_ID
	FROM CIC_Accreditation_Name
WHERE [Name]=@AccreditationEn OR [Name]=@AccreditationFr
	ORDER BY CASE
		WHEN [Name]=@AccreditationEn AND LangID=0 THEN 0
		WHEN [Name]=@AccreditationFr AND LangID=2 THEN 1
		ELSE 2
	END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Accreditation_Check] TO [cioc_login_role]
GO
